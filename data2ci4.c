#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFF_SIZE 1000  // tamanho do buffer de linha de arquivo

char flag_eof = 0;

int extrair_paleta(char * s, unsigned char paleta[16]) { 
        int n = 0; 
        char *fim; 
        while (*s && n < 16) { 
                unsigned long v = strtoul(s, &fim, 10); 
                if (fim == s) { 
                        s++; /* não havia número aqui */ 
                        continue; 
                } 
                if (v > 255) return n;
                paleta[n++] = (unsigned char)v; 
                s = fim; 
        } 
        return n; 
}

int ler_paleta(char* nome, unsigned char paleta[]){
        FILE * arquivo = fopen(nome, "rb");
        if (!arquivo) {
                printf("ERRO: Arquivo %s não encontrado.\n", nome);
                exit(1);
        }

        char buffer[BUFF_SIZE];
        char* enderecopaleta;           // endereco de onde os bytes de paleta comecam na linha
 
        // vai estar como
        // label: .word w, h .byte c1 c2 c3 c4 ... c(w*h)
        // entao vamos encontrar onde as cores comecam

        char* statusfgets;
        do {
                statusfgets = fgets(buffer, BUFF_SIZE, arquivo);
                enderecopaleta = strstr(buffer, ".byte");
                if (statusfgets == NULL && !enderecopaleta) goto ler_paleta_erro;
        } while (!enderecopaleta);

        // extrai todos os bytes de todas as linhas
        int n = 0;
        do {
                n += extrair_paleta(buffer, paleta + n);
        } while (n < 16 && fgets(buffer, BUFF_SIZE, arquivo));
        fclose(arquivo);
        return n;

        ler_paleta_erro:
        printf("ERRO: Arquivo de paleta malformado.\n");
        fclose(arquivo);
        exit(1);
}

long int proximo_numero(FILE * arquivo){
        flag_eof = 0;
        char digitos[5] = "\0\0\0\0\0";
        char caractere;
        unsigned char negativo = 0; // se o numero eh negativo ou nao
        int digito = 1; // em qual digito (do LSD para o MSD) estamos atualmente
        do{
                caractere = fgetc(arquivo);
        }while(caractere != EOF && (caractere < '0' || caractere > '9') && caractere != '-');
        if (caractere == EOF) {
                flag_eof = 1;
                return 0;
        }
        if (caractere == '-') {
                digitos[0] = '-';
        } // comeca o numero como negativo
        else digitos[0] = caractere; // pega o valor numero do digito encontrado

        int valor_digito;
        while(1){
                caractere = fgetc(arquivo);
                if (caractere < '0' || caractere > '9') {
                        if (digitos[0] == '0' && (caractere == 'x' || caractere == 'X')) goto proximo_hexa;
                        return strtol(digitos, NULL, 10);
                }
                digitos[digito] = caractere;
                digito++;
        }

        proximo_hexa:
        digito = 0;
        while(1){
                caractere = fgetc(arquivo);
                if ((caractere > '9' || caractere < '0') &&
                    (caractere > 'F' || caractere < 'A') &&
                    (caractere > 'f' || caractere < 'a')) 
                        return strtol(digitos, NULL, 16);
                digitos[digito] = caractere;
                digito++;
        }

}

char idx_paleta(unsigned char cor, unsigned char paleta[], size_t * paleta_tamanho, int paleta_fornecida){
        char idx = -1;
        for (int i = 0; i < *paleta_tamanho; i++){
                if (cor == paleta[i]) {
                        idx = i;
                        break;
                }
        }
        if (idx == -1 && *paleta_tamanho < 16 && !paleta_fornecida) {
                paleta[*paleta_tamanho] = cor;
                idx = *paleta_tamanho;
                (*paleta_tamanho)++;
        }
        return idx;
}

void criar_arquivo_ci4(char nomedata[], char nomeci4[], unsigned char paleta[], int paleta_fornecida, size_t * paleta_tamanho){
        FILE * data = fopen(nomedata, "rb");
        if (!data) goto abrir_arquivo_data_erro;
        FILE * ci4 = fopen(nomeci4, "w");
        if (!ci4) goto criar_arquivo_ci4_erro;

        char buffer[BUFF_SIZE];
        char label[BUFF_SIZE];
        char * labeladdr;
        char * enderecoword;
        char* statusfgets;
        do {
                statusfgets = fgets(buffer, BUFF_SIZE, data);
                enderecoword = strstr(buffer, ".word");
                labeladdr = strstr(buffer, ":");
                
                if (labeladdr) {
                        strncpy(label, buffer, labeladdr - buffer); // copia a label;
                        label[labeladdr - buffer] = '\0';
                }
                if (statusfgets == NULL && !enderecoword) goto abrir_arquivo_data_erro;
                
        } while (!enderecoword);

        fseek(data, (enderecoword-buffer-strlen(buffer)), SEEK_CUR);

        unsigned int w = (proximo_numero(data)+1)/2; // dividido por 2, arredondando para cima!
        unsigned int h = proximo_numero(data);
        int bytes = w*h;
       
        if (!bytes) goto arquivo_data_malformado_erro;

        enderecoword = '\0'; // coloca um \0 logo depois da label, escrevendo apenas ela
        fprintf(ci4, "%s: .word %u, %u\n.byte ", label, w, h);
        
        // label: .word w h
        // .byte b1 b2 b3 b4...
        unsigned char byte, cor1, cor2; 
        char idx1, idx2;
        char bytestr[6]; 
        for (int i = 0; i < bytes; i++){
                cor1 = proximo_numero(data);
                idx1 = idx_paleta(cor1, paleta, paleta_tamanho, paleta_fornecida);
                if (flag_eof) goto arquivo_data_malformado_erro;

                cor2 = proximo_numero(data);
                if (flag_eof) idx2 = 0;
                else idx2 = idx_paleta(cor2, paleta, paleta_tamanho, paleta_fornecida);

                if (idx1 == -1 || idx2 == -1) {
                        if (paleta_fornecida) goto erro_paleta_fora;
                        if (*paleta_tamanho == 16) goto erro_paleta_pequena;
                        goto arquivo_data_malformado_erro;
                }
                byte = (idx1 << 4) + idx2;
                
                sprintf(bytestr, "0x%X,", byte);
                fwrite(bytestr, sizeof(unsigned char), strlen(bytestr), ci4);
        }

        fclose(data);
        fclose(ci4);
        return;

        arquivo_data_malformado_erro:
                printf("ERRO: Arquivo data malformado. Certifique-se que o arquivo esteja no formato padrão gerado pelo bmp2oac3.");
                exit(1);

        abrir_arquivo_data_erro:
                printf("ERRO: Erro ao abrir o arquivo data.\n");
                exit(1);
        
        criar_arquivo_ci4_erro:
                printf("ERRO: Erro ao criar o arquivo ci4.\n");
                exit(1);

        erro_paleta_fora:
                printf("ERRO: Nem todos os pixeis da imagem estão na paleta. Certifique-se de quantizar a imagem apropriadamente ou criar uma nova paleta.\n");
                exit(1);

        erro_paleta_pequena:
                printf("ERRO: A imagem possui cores demais para ser reduzida. Certifique-se que a imagem possua no máximo 16 cores distintas, incluindo a cor transparente (0xC7) se for parte da imagem.\n");
                exit(1);
}

void criar_arquivo_pal(char nomearquivo[], char * ponto_sufixo, unsigned char paleta[], size_t paleta_tamanho){
        FILE * pal = fopen(nomearquivo, "wb");
        if (!pal) goto erro_arquivo_paleta;
        
        *ponto_sufixo = '\0';
        char * espacos = strstr(nomearquivo, " ");
        while (espacos){
                *espacos = '_';
                espacos = strstr(espacos+1, " ");
        }

        char * dashes = strstr(nomearquivo, "-");
        while (dashes){
                *dashes = '_';
                dashes = strstr(dashes+1, "-");
        }

        fprintf(pal, "%s_paleta: .word %u 1 \n.byte ", nomearquivo, paleta_tamanho);
        for (int i = 0; i < paleta_tamanho; i++){
                fprintf(pal, "%u,", paleta[i]);
        }

        fclose(pal);
        return;

        erro_arquivo_paleta:
                printf("ERRO: Erro ao escrever arquivo de paleta.");
                exit(1);
}

int main(int argc, char** args){
        if (argc <= 1 || argc > 3) {
                printf("Uso:\n");
                printf("%s file.data: converte um arquivo .data para um arquivo .ci4 e um arquivo de paleta .pal\n", args[0]);
                printf("%s file.data file.pal: converte um arquivo .data para um arquivo .ci4 dado um arquivo .pal inicial\n", args[0]);
                return 0;
        }

        unsigned char paleta[16];
        int paleta_fornecida = argc == 3;
        int paleta_tamanho = paleta_fornecida ? ler_paleta(args[2], paleta) : 0;
       
        // vamos tirar o sufixo do nome do arquivo
        char buffer[BUFF_SIZE];
        strcpy(buffer, args[1]);
        char * ponto_sufixo = strstr(buffer, ".");
        char * proximoponto;
        
        while (1){
                proximoponto = strstr(ponto_sufixo+1, ".");
                if (!proximoponto) break;
                ponto_sufixo = proximoponto;
        }
        buffer[ponto_sufixo - buffer] = '\0';

        //arquivo ci4
        strcat(buffer, ".ci4");
        criar_arquivo_ci4(args[1], buffer, paleta, paleta_fornecida, &paleta_tamanho);

        //arquivo .pal
        if (!paleta_fornecida) {
                buffer[ponto_sufixo - buffer] = '\0';
                strcat(buffer, ".pal");
                criar_arquivo_pal(buffer, ponto_sufixo, paleta, paleta_tamanho);
        }
}

