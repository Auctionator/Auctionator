#!/usr/bin/python3
import csv
suffixes = {}

with open('ItemRandomProperties.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        s = row['Name_lang']
        if s not in suffixes:
            suffixes[s] = []
        suffixes[s].append(int(row['ID']))

with open('ItemRandomProperties.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        s = row['Name_lang']
        if s not in suffixes:
            suffixes[s] = []
        suffixes[s].append(-int(row['ID']))

suffix_strings = []
for s, values in suffixes.items():
    values.sort()
    suffix_strings.append(s)

suffix_strings.sort()

print("Auctionator.Utilities.SuffixIDToSuffixStringID = {")
for index in range(1, len(suffix_strings)):
    s = suffix_strings[index]
    for value in suffixes[s]:
        print("[" + str(value) + "] = " + str(index) + ",")
print("}")

print("Auctionator.Utilities.SuffixStringIDTOSuffixString = {")
for index in range(1, len(suffix_strings)):
    s = suffix_strings[index]
    print("[" + str(index) + "] = \"" + s + "\",")
print("}")
