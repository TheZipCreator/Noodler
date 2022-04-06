from pydub import AudioSegment
import sys

if(len(sys.argv) < 2):
    print("Usage: ogg2mp3 <source file> <destination file>");
    sys.exit(1);

file = AudioSegment.from_ogg(sys.argv[1]);
file.export(sys.argv[2], format="mp3");