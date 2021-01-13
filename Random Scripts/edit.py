
import os
import glob
import re

def add_up(m):
  return '\"depth\": ' + str(int(m.group(1)) + 20)

os.chdir("Edits")
for file in glob.glob("*.json"):
  print(file)
  with open(file, "r") as readfile:
    with open("__" + file, "w") as writefile:
      lines = readfile.readlines()
      for line in lines:
        if "depth" in line:
          newline = re.sub(r'\"depth\": (-?[\d]+)', add_up, line)
          writefile.write(newline)
        else:
          writefile.write(line)
      writefile.close()

