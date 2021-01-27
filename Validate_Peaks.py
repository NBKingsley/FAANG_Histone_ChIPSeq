# Modified from Colin's script
# created 11192018
import sys
from collections import defaultdict

peaks = defaultdict(list)
with open(sys.argv[1]) as f:
    input_file = sys.argv[1]
    character = input_file.split("_")[2]
    for line in f:
        parts = line.strip().split()
        peaks[(parts[0], parts[1], parts[2], parts[3], parts[4])].append((float(parts[13]), int(parts[14])))

for k, v in peaks.iteritems():
    try:
        score = sum(x[0] * x[1] for x in v) / sum(x[1] for x in v)
    except ZeroDivisionError:
        score = 0
    if score >= 2:
        print("{}\t{}\t{}\t{}\t{}\t.".format(*k))
