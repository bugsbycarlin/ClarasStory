
import json
import sys
from collections import OrderedDict

print(sys.argv[1])

with open(sys.argv[1], "r") as in_file:
  structure = json.loads(in_file.read())
  
  for item in structure:

    if "fixed_x" in item:
      del item["fixed_x"]
    if "fixed_y" in item:
      del item["fixed_y"]
    if "type" in item:
      del item["type"]

    if "y_scale" in item:
      item["yScale"] = item.pop("y_scale")
    if "x_scale" in item:
      item["xScale"] = item.pop("x_scale")
    if "disappear_time" in item:
      item["end_time"] = item.pop("disappear_time")
    if "disappear_method" in item:
      item["end_effect"] = item.pop("disappear_method")
    if "name" in item:
      item["picture"] = item.pop("name")

    # optional:
    if "intro" in item:
      del item["intro"]


  externally_sorted_structure = sorted(structure, key = lambda t: (t["start_time"], t["picture"]))
  fully_sorted_structure = [OrderedDict(sorted(d.items())) for d in externally_sorted_structure]

  with open("outfile.json", "w") as out_file:
    out_file.write(json.dumps(fully_sorted_structure, sort_keys=False, indent=2))