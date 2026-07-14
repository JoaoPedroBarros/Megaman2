import mido
import os
import sys
import struct

# MIDICONVERTER
# Inspired by https://github.com/Zen-o/Tradutor_MIDI-RISC-V
#
# This version creates a struct of notes to be used on FPGRARS.

if len(sys.argv) < 2:
    print(f"Usage: python {sys.argv[0]} <filename.mid>")
    exit(1)

FOLDER_PATH = os.path.dirname(os.path.realpath(__file__))
input_path = os.path.join(FOLDER_PATH, sys.argv[1])

if not os.path.isfile(input_path):
    raise Exception("ERROR: The input path doesn't exist.")
if not input_path.endswith(".mid"):
    raise Exception("ERROR: The given file isn't a .mid")

mid = mido.MidiFile(input_path)

filename = os.path.splitext(os.path.basename(sys.argv[1]))[0]
filename = filename.replace(" ", "_").replace("-", "_")

datafilename = filename + ".data"

notes = []
active_notes = {}
abs_time = 0
programs = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] # program for each channel

for msg in mid:
    abs_time += msg.time
    if msg.type == 'program_change':
        programs[msg.channel] = msg.program # keep track of the current instrument
        continue
    if msg.type == 'note_on' and msg.velocity > 0:
        active_notes[(msg.note, msg.channel)] = [msg.velocity, abs_time, programs[msg.channel]] 
        continue
    if msg.type == 'note_off' or (msg.type == 'note_on' and msg.velocity == 0):
        note = active_notes.pop((msg.note, msg.channel), None)

        # skip invalid notes
        if note is None:
            continue

        pitch = msg.note
        #instrument = note[2] - irrelevant since the board does not support instruments
        volume = note[0]
        start_time = round(note[1]*1000)    # convert to ms
        end_time = round(abs_time*1000)     # convert to ms
        duration = end_time - start_time
        notes.append((pitch, volume, duration, start_time))

notes.sort(key=lambda note: note[3]) # sorts by start time

# Write  to .data

# 
with open(datafilename, "w") as df: 
    df.write(f"{filename}:\n")  
    for n in notes:                             # struct_note:
        df.write(f"    .byte {n[0]}, {n[1]}\n") # .byte pitch, volume
        df.write(f"    .half {n[2]}\n")         # .half duration (ms)p
        df.write(f"    .word {n[3]}\n\n")       # .word start_time (ms since start of track)

    df.write(f"{filename}_FIM:\n")
    df.write(f"    .word 0 0")

print("Done! Converted to " + datafilename + ".")