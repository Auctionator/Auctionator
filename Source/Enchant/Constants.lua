local ENCHANT_REAGENTS = {
  SOUL_DUST = "172230",
  SACRED_SHARD = "172231",
  ETERNAL_CRYSTAL = "172232",

  GLOOM_DUST = "152875",
  UMBRA_SHARD = "152876",
  VEILED_CRYSTAL = "152877",

  ARKANA = "124440",
  LEYLIGHT_SHARD = "124441",
  CHAOS_CRYSTAL = "124442",

  DRAENIC_DUST = "109693",
  LUMINOUS_SHARD = "111245",
  TEMPORAL_CRYSTAL = "113588",
}

Auctionator.Enchant.DE_TABLE = {
  [LE_EXPANSION_SHADOWLANDS or LE_EXPANSION_9_0] = {
    [Enum.ItemQuality.Uncommon] = {[ENCHANT_REAGENTS.SOUL_DUST] = 2.26},
    [Enum.ItemQuality.Rare]  = {
      [ENCHANT_REAGENTS.SOUL_DUST]    = 1.5,
      [ENCHANT_REAGENTS.SACRED_SHARD] = 1.41
    },
    [Enum.ItemQuality.Epic] = {
      [ENCHANT_REAGENTS.SACRED_SHARD]    = 0.35,
      [ENCHANT_REAGENTS.ETERNAL_CRYSTAL] = 1.06
    }
  },
  [LE_EXPANSION_BATTLE_FOR_AZEROTH] = {
    [Enum.ItemQuality.Uncommon] = {[ENCHANT_REAGENTS.GLOOM_DUST] = 5},
    [Enum.ItemQuality.Rare]  = {
      [ENCHANT_REAGENTS.GLOOM_DUST]  = 0.55,
      [ENCHANT_REAGENTS.UMBRA_SHARD] = 0.73
    },
    [Enum.ItemQuality.Epic] = {
      [ENCHANT_REAGENTS.UMBRA_SHARD]    = 0.4,
      [ENCHANT_REAGENTS.VEILED_CRYSTAL] = 1
    }
  },
  [LE_EXPANSION_LEGION] = {
    [Enum.ItemQuality.Uncommon] = {[ENCHANT_REAGENTS.ARKANA] = 5},
    [Enum.ItemQuality.Rare]  = {[ENCHANT_REAGENTS.LEYLIGHT_SHARD] = 1},
    [Enum.ItemQuality.Epic] = {[ENCHANT_REAGENTS.CHAOS_CRYSTAL] = 1},
  },
  [LE_EXPANSION_WARLORDS_OF_DRAENOR] = {
    [Enum.ItemQuality.Uncommon] = {[ENCHANT_REAGENTS.DRAENIC_DUST] = 2.5},
    [Enum.ItemQuality.Rare]  = {
      [ENCHANT_REAGENTS.DRAENIC_DUST] = 8.1,
      [ENCHANT_REAGENTS.LUMINOUS_SHARD] = 0.1
    },
    [Enum.ItemQuality.Epic] = {[ENCHANT_REAGENTS.TEMPORAL_CRYSTAL] = 1},
  }
}
