
import os
import glob
import sys

search = sys.argv[1]

os.chdir("../Game/Sequences")
for file in glob.glob("*.json"):
  print(file)
  with open(file, "r") as readfile:
    count = 0
    lines = readfile.readlines()
    for line in lines:
      if search.lower() in line.lower():
        count += 1
    print(count)

