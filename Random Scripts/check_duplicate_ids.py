
import os
import glob
import sys

# search = sys.argv[1]

os.chdir("../Game/Sequences")
for file in glob.glob("*.json"):
  print(file)
  with open(file, "r") as readfile:
    id_bank = {}
    lines = readfile.readlines()
    for line in lines:
      if "\"id\"" in line:
        key = line.strip().lower().replace("\"id\": ", "").replace(",","").replace("\"","")
        if key in id_bank:
          print("-- " + key)
        id_bank[key] = 1


