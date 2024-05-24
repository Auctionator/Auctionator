#!/usr/bin/python3
# This script converts the csv version of the item, itemeffect, spelllevels and
# spellequippeditems db2 files exported from a client to get a mapping of the
# enchant spell id to the enchant item (for searching the AH for the enchant or
# calculation crafting profit), and spell level/equipped slot (for the vellum
# needed for crafting cost/profit)
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

spell_to_level = {}
with open('spelllevels.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_to_level[int(row['SpellID'])] = int(row['BaseLevel'])

spell_to_item_class = {}
with open('spellequippeditems.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_to_item_class[int(row['SpellID'])] = int(row['EquippedItemClass'])

data_format = """\
  [{}] = {{itemID = {}, level = {}, itemClass = {}}},\
"""

print("Auctionator.CraftingInfo.EnchantSpellsToItemData = {")
for item_id in enchants_only:
    if item_id in item_to_spell:
        spell_id = item_to_spell[item_id]
        spell_level = 0
        if spell_id in spell_to_level:
            spell_level = spell_to_level[spell_id]
        if spell_id in spell_to_item_class:
            spell_class = spell_to_item_class[spell_id]
            print(data_format.format(spell_id, item_id, spell_level, spell_class))
print("}")
