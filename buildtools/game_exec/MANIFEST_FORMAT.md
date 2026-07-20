# ARCHIVE MANIFEST

Esse arquivo especifica os detalhes do arquivo manifesto para a criação de um arquivo de archive, contendo os arquivos de um projeto.

Os comandos de um arquivo manifest são os seguintes:

### from (caminho)
Define o diretório raiz do projeto relativo ao manifesto. Deve vir antes de qualquer include ou exclude.
Exemplo: 
- `from ../../projeto/`

### include (caminho)
Inclui um ou mais arquivos ou diretórios no archive. Não inclui arquivos excluídos, independentemente da exclusão ser anterior ou posterior ao comando.
Exemplos: 
- `include src/`
- `include assets/fotos` (a barra no final para diretórios é opcional)
- `include arquivo1.s arquivo2.s "arquivo 3.s"`
- `include "utils/programas executaveis/prog.exe"`
- `include .` (inclui todos os arquivos no diretorio)

### exclude (caminho)
Impede que um ou mais caminhos e diretórios sejam incluídos pelo comando include. A ordem da exclusão não importa.
Exemplos:
- `exclude src/test`
- `exclude "assets/arquivos bitmap/temp"`
- `exclude proj.archive build/ test manifest.ini`


Também é possível adiciona comentários por meio do caractere hashtag. 

## Exemplos

1.
```
# Fulano de Tal - DD/MM/AAAA - Manifesto para arquivar o projeto
# Nenhum direito reservado

from ..         # diretorio do projeto
include .       # pega todos os arquivos
exclude build/  # tirando build
```

2.
```
from "C:/users/userpc/Documentos/UnB/2026.1/Organizacao e Arquitetura de Computadores/projeto final"

include assets/
#exclude src/debug -- comentado ateh a production release estar pronta
include src/
include README.md
include LICENSE
```