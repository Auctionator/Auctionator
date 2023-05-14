#!/usr/bin/python3
import csv

enchants_only = {}

with open('item.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        if row['ClassID'] == '8': # Item Enhancement
            itemID = int(row['ID'])
            enchants_only[itemID] = []

with open('itemxitemeffect.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        itemid = int(row['ItemID'])
        if itemid in enchants_only:
            enchants_only[itemid].append(int(row['ItemEffectID']))

effects_to_spell = {}
with open('itemeffect.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        effects_to_spell[int(row['ID'])] = int(row['SpellID'])


enchants_to_items = {}

for itemID in enchants_only:
    itemeffects = enchants_only[itemID]
    if len(itemeffects) == 1:
        spellID = effects_to_spell[itemeffects[0]]
        if spellID not in enchants_to_items:
            enchants_to_items[spellID] = [itemID]
        else:
            enchants_to_items[spellID].append(itemID)

def array_str(array):
    result = "{"
    for index, item in enumerate(array):
        if index + 1 < len(array):
            result = result + str(item) + ","
        else:
            result = result + str(item)
    result = result + "}"
    return result

ordered_spells = []
for spellID in enchants_to_items:
    ordered_spells.append(spellID)
ordered_spells.sort()
    

print("Auctionator.CraftingInfo.EnchantSpellsToItems = {")
for spellID in ordered_spells:
    itemIDs = enchants_to_items[spellID]
    print("  [" + str(spellID) + "] = " + array_str(itemIDs) + ",")
print("}")
