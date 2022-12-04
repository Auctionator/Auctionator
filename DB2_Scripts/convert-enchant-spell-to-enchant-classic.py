#!/usr/bin/python3
# This script converts the csv version of the item and itemeffect db2 files
# exported from a client to get a mapping of the enchant spell id to the enchant
# item
import csv

enchants_only = {}

with open('item.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        if row['ClassID'] == '0' and row['SubclassID'] == '6':
            enchants_only[int(row['ID'])] = True

item_to_spell = {}
with open('itemeffect.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        item_to_spell[int(row['ParentItemID'])] = int(row['SpellID'])

def print_enchant(itemID, spellID):
    print("  [" + str(spellID) + "] = " + str(itemID) + ",")

print("Auctionator.CraftingInfo.EnchantSpellsToItems = {")
for key in enchants_only:
    print_enchant(key, item_to_spell[key])
print("}")
