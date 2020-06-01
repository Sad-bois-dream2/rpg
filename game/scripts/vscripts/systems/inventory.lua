if Inventory == nil then
    _G.Inventory = class({})
end

-- items database
function Inventory:SetupItems()
    Inventory:RegisterItemSlot("item_two_handed_sword", self.rarity.common, self.slot.mainhand, 5) --2H
    Inventory:RegisterItemSlot("item_one_handed_sword", self.rarity.common, self.slot.mainhand, 5) --both
    Inventory:RegisterItemSlot("item_silver_ring", self.rarity.common, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_chainshirt", self.rarity.common, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_wooden_shield", self.rarity.common, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_leather_boots", self.rarity.common, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_wooden_wand", self.rarity.common, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_glowing_weed", self.rarity.uncommon, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_witchs_broom", self.rarity.immortal, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_twig", self.rarity.common, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_elven_slippers", self.rarity.uncommon, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_warchief_belt", self.rarity.uncommon, self.slot.belt, 5)
    Inventory:RegisterItemSlot("item_elven_blade", self.rarity.uncommon, self.slot.mainhand, 5) --both
    Inventory:RegisterItemSlot("item_iron_gauntlets", self.rarity.common, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_executioner_axe", self.rarity.rare, self.slot.mainhand, 5) --2H
    Inventory:RegisterItemSlot("item_garnet_circlet", self.rarity.uncommon, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_kings_crown", self.rarity.uniqueRare, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_elven_armband", self.rarity.uncommon, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_apprentice_mantle", self.rarity.common, self.slot.shoulder, 5)
    Inventory:RegisterItemSlot("item_wizard_robe", self.rarity.uncommon, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_jewel_staff", self.rarity.rare, self.slot.mainhand, 5) --2H
    Inventory:RegisterItemSlot("item_sacred_tome", self.rarity.uncommon, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_hatchet", self.rarity.common, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_citrine_ring", self.rarity.common, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_martial_staff", self.rarity.common, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_iron_spear", self.rarity.uncommon, self.slot.mainhand, 5) --2H
    Inventory:RegisterItemSlot("item_wolf_claw", self.rarity.common, self.slot.mainhand, 5) --both
    Inventory:RegisterItemSlot("item_plate_helmet", self.rarity.common, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_leather_cloak", self.rarity.common, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_cultist_mask", self.rarity.rare, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_curved_dagger", self.rarity.rare, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_ruby_ring", self.rarity.uncommon, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_leather_glove", self.rarity.common, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_cursed_ring", self.rarity.rare, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_void_amulet", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_ritual_mask", self.rarity.uncommon, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_shiny_emerald", self.rarity.uncommon, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_fel_staff", self.rarity.uniqueRare, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_demon_stone", self.rarity.uniqueRare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_poison_orb", self.rarity.uniqueRare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_gold_ring", self.rarity.uniqueRare, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_glimmering_sapphire", self.rarity.uniqueRare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_scarlet_orb", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_azure_orb", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_amaranthine_orb", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_plate_armor", self.rarity.legendary, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_purifying_talisman", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_tribal_charm", self.rarity.uncommon, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_plasma_orb", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_fel_sword", self.rarity.cursedLegendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_sapphire_staff", self.rarity.uniqueLegendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_elven_bow", self.rarity.uniqueLegendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_titan_axe", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_golden_skull", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_composite_wand", self.rarity.uncommon, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_bronze_brancer", self.rarity.uncommon, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_violet_talisman", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_elven_warmask", self.rarity.uncommon, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_demon_ring", self.rarity.cursedAncient, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_solider_sneakers", self.rarity.rare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_mage_sneakers", self.rarity.rare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_elven_sneakers", self.rarity.rare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_swiftboots", self.rarity.rare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_bone_wand", self.rarity.legendary, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_wizard_ring", self.rarity.uniqueLegendary, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_death_gods_mask", self.rarity.cursedLegendary, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_samurai_helmet", self.rarity.ancient, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_blessed_boots", self.rarity.legendary, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_battle_boots", self.rarity.legendary, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_iron_shield", self.rarity.uncommon, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_warchief_headress", self.rarity.rare, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_void_ring", self.rarity.uniqueLegendary, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_lichs_phylactery", self.rarity.cursedAncient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_healer_boots", self.rarity.uncommon, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_tiger_medallion", self.rarity.common, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_mage_boots", self.rarity.legendary, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_tribal_drum", self.rarity.rare, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_enchanted_trinket", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_cultleaders_mask", self.rarity.ancient, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_turquoise_locket", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_soul_jar", self.rarity.cursedImmortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_glowing_weed_pipe", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_knight_boots", self.rarity.uniqueRare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_void_cape", self.rarity.uniqueImmortal, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_veil_of_darkness", self.rarity.ancient, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_book_of_agony", self.rarity.cursedLegendary, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_book_of_dread", self.rarity.cursedAncient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_book_of_calamity", self.rarity.cursedImmortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_crescent_staff", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_sapphire_lens", self.rarity.uniqueAncient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_flaming_rod", self.rarity.immortal, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_wand_of_the_wind", self.rarity.ancient, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_ruby_bone_wand", self.rarity.ancient, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_infernal_staff", self.rarity.cursedAncient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_heliotrix", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_winter_staff", self.rarity.ancient, self.slot.mainhand, 5) --2H
    Inventory:RegisterItemSlot("item_tenebris", self.rarity.immortal, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_viridis", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_sacrificial_scythe", self.rarity.cursedImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_rubicundus", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_antimagic_hood", self.rarity.uncommon, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_ironwall", self.rarity.rare, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_commander_mail", self.rarity.rare, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_time_rewinder", self.rarity.uniqueImmortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_fusion_orb", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_kings_armor", self.rarity.uniqueRare, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_scarlet_lotus", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_kings_staff", self.rarity.uniqueRare, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_sky_pike", self.rarity.uniqueLegendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_mirror_axe", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_northern_realm_shoulder", self.rarity.ancient, self.slot.shoulder, 5)
    Inventory:RegisterItemSlot("item_hells_general_armor", self.rarity.ancient, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_tainted_fire", self.rarity.uniqueAncient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_scorching_blade", self.rarity.uniqueLegendary, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_glacial_hammer", self.rarity.uniqueLegendary, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_void_armlet", self.rarity.cursedLegendary, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_umbra_blade", self.rarity.uniqueLegendary, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_murderous_maul", self.rarity.legendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_elder_staff", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_bronze_double_axe", self.rarity.uniqueRare, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_fel_blade", self.rarity.ancient, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_luminarium", self.rarity.uniqueAncient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_assassins_blade", self.rarity.uniqueAncient, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_devils_kiss", self.rarity.uniqueAncient, self.slot.mainhand, 5)--2H bow
    Inventory:RegisterItemSlot("item_subsicivus", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_judgement", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_lights_bane", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_sanguis_furore", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_winged_serpent", self.rarity.legendary, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_frozeheart", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_knightfall", self.rarity.uniqueAncient, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_quicksilver", self.rarity.uniqueAncient, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_volvebatur", self.rarity.immortal, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_lightning_mace", self.rarity.legendary, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_mageblade", self.rarity.ancient, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_sacred_halberd", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_hellscythe", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_eldritch_twin_guardian", self.rarity.uniqueAncient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_scorching_twin_guardian", self.rarity.uniqueAncient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_freezing_twin_guardian", self.rarity.uniqueAncient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_demons_horn", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_dreameater", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_firecore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_frostcore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_earthcore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_voidcore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_holycore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_naturecore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_infernocore", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_lesser_viridis", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_mage_ring", self.rarity.legendary, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_savage", self.rarity.uniqueRare, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_autumn", self.rarity.uniqueAncient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_sniper_lens", self.rarity.rare, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_nymphs_tear", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_moonlit_shield", self.rarity.legendary, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_shovel", self.rarity.common, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_fishermans_net", self.rarity.uncommon, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_scaled_shoulder", self.rarity.rare, self.slot.shoulder, 5)
    Inventory:RegisterItemSlot("item_verdant_ring", self.rarity.ancient, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_long_bow", self.rarity.uncommon, self.slot.mainhand, 5)--2H bow
    Inventory:RegisterItemSlot("item_dragon_claw", self.rarity.rare, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_noble_cape", self.rarity.uncommon, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_seer_orb", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_apple_charm", self.rarity.uncommon, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_serpent_ring", self.rarity.rare, self.slot.ring, 5)
    Inventory:RegisterItemSlot("item_elven_armguard", self.rarity.rare, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_mage_armguard", self.rarity.rare, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_soldier_armguard", self.rarity.rare, self.slot.gloves, 5)
    Inventory:RegisterItemSlot("item_tribal_necklace", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_golemskin", self.rarity.immortal, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_mechanical_quiver", self.rarity.immortal, self.slot.cape, 5) --need bow to work
    Inventory:RegisterItemSlot("item_greater_glowing_weed", self.rarity.legendary, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_subzero_edge", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_darkflame", self.rarity.uniqueImmortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_excalibur", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_emerald_necklace", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_stonehammer", self.rarity.common, self.slot.mainhand, 5)--both
    Inventory:RegisterItemSlot("item_mothers_leg", self.rarity.uniqueImmortal, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_spyglass", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_charred_essence", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_pharaoh_staff", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_blazefury", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_silken_reflector", self.rarity.immortal, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_ritual_candle", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_dragon_horn", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_shuriken", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_warlock_dagger", self.rarity.uniqueImmortal, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_lucky_crystal", self.rarity.legendary, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_hellsworn", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_dragon_orb", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_soldier_shako", self.rarity.rare, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_elementinus", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_deaths_whisper", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H bow
    Inventory:RegisterItemSlot("item_pestilence", self.rarity.uniqueImmortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_thunderstrike", self.rarity.uniqueImmortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_constellation", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_voodoo_boots", self.rarity.ancient, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_void_mirror", self.rarity.immortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_captain_hat", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_outworld_prism", self.rarity.uniqueImmortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_hopes_end", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_boots_of_autumn", self.rarity.ancient, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_sea_king_trident", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_cultist_boot", self.rarity.rare, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_general_banner", self.rarity.rare, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_blazing_robe", self.rarity.uniqueRare, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_herald_of_void", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_felskull", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_truth", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_pelt_cape", self.rarity.common, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_hand_of_the_fallen", self.rarity.cursedImmortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_ruby_disk", self.rarity.rare, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_bronze_mace", self.rarity.rare, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_army_baldric", self.rarity.ancient, self.slot.belt, 5)
    Inventory:RegisterItemSlot("item_voodoo_femur", self.rarity.ancient, self.slot.mainhand, 5)
    Inventory:RegisterItemSlot("item_spider_shield", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_hood_of_damned", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_warlock_skull", self.rarity.cursedImmortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_general_boots", self.rarity.ancient, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_shimmering_moon", self.rarity.immortal, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_fallen_helm", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_forgotten_carapace", self.rarity.immortal, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_soulstring", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H bow
    Inventory:RegisterItemSlot("item_katana", self.rarity.ancient, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_bearskin_cloak", self.rarity.rare, self.slot.cape, 5)
    Inventory:RegisterItemSlot("item_winterwyrm_skull_helmet", self.rarity.immortal, self.slot.helmet, 5)
    Inventory:RegisterItemSlot("item_glowing_sphere", self.rarity.ancient, self.slot.amulet, 5)
    Inventory:RegisterItemSlot("item_sacred_shield", self.rarity.ancient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_lich_skull", self.rarity.cursedAncient, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_gluey_substance", self.rarity.ancient, self.slot.body, 5)
    Inventory:RegisterItemSlot("item_death_edge", self.rarity.immortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_dimension_slipper", self.rarity.ancient, self.slot.boots, 5)
    Inventory:RegisterItemSlot("item_lucifera", self.rarity.cursedImmortal, self.slot.mainhand, 5)--2H
    Inventory:RegisterItemSlot("item_obstrutionum", self.rarity.uniqueImmortal, self.slot.offhand, 5)
    Inventory:RegisterItemSlot("item_holy_trident", self.rarity.uniqueImmortal, self.slot.mainhand, 5)--2H
    --Inventory:RegisterItemSlot("item_", self.rarity., self.slot., 5)
end

function Inventory:Init()
    self.maxItemsPerRequest = 10
    -- slots count, changes here require same changes in client side inventory.js
    self.maxStoredItems = 14 * 7
    -- slot types, changes here require changes in GetInventoryItemSlotName() in client side inventory.js
    self.slot = {}
    self.slot.mainhand = 0
    self.slot.body = 1
    self.slot.legs = 2
    self.slot.boots = 3
    self.slot.helmet = 4
    self.slot.offhand = 5
    self.slot.cape = 6
    self.slot.shoulder = 7
    self.slot.gloves = 8
    self.slot.ring = 9
    self.slot.belt = 10
    self.slot.amulet = 11
    -- latest slot id for internal stuff
    self.slot.last = 11
    -- Invalid slot id for internal stuff
    self.slot.invalid = -1
    -- item types, changes here require changes in GetInventoryItemRarityName() in client side inventory.js
    self.rarity = {}
    self.rarity.common = 0
    self.rarity.uncommon = 1
    self.rarity.rare = 2
    self.rarity.uniqueRare = 3
    self.rarity.legendary = 4
    self.rarity.uniqueLegendary = 5
    self.rarity.cursedLegendary = 6
    self.rarity.ancient = 7
    self.rarity.uniqueAncient = 8
    self.rarity.cursedAncient = 9
    self.rarity.immortal = 10
    self.rarity.uniqueImmortal = 11
    self.rarity.cursedImmortal = 12
    -- latest rarity id for internal stuff
    self.rarity.max = 12
    self.itemsData = {}
    self.itemsKeyValues = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    Inventory:SetupItems()
    Inventory:InitPanaromaEvents()
end

--  internal stuff to make all work
--- Return item slot if it possible to add item or Inventory.slot.invalid if impossible (no space)
---@param hero CDOTA_BaseNPC_Hero
---@param item string
---@return number
function Inventory:AddItem(hero, item, itemStats)
    if (hero ~= nil and item ~= nil and hero.inventory ~= nil) then
        if (not Inventory.itemsData[item]) then
            DebugPrint("[INVENTORY] Attempt to add unknown item (" .. item .. ").")
            return Inventory.slot.invalid, nil
        end
        if (not itemStats) then
            local difficulty = Difficulty:GetValue()
            itemStats = Inventory:GenerateStatsForItem(item, difficulty)
        end
        for i = 0, Inventory.maxStoredItems do
            local itemInSlot = Inventory:GetItemInSlot(hero, false, i)
            if (not Inventory:IsItemNotEmpty(itemInSlot)) then
                Inventory:SetItemInSlot(hero, item, false, i, itemStats)
                return i, Inventory:GetItemInSlot(hero, false, i)
            end
        end
        local item = CreateItem(item, hero, hero)
        local positionOnGround = hero:GetAbsOrigin()
        local itemId = item:GetEntityIndex()
        local itemOnGround = CreateItemOnPositionSync(positionOnGround, item)
        Inventory:SetItemEntityStats(item, itemStats)
        item:SetPurchaser(hero)
        CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), { itemWorldId = itemOnGround:GetEntityIndex(), itemStats = itemStats, itemName = item:GetAbilityName() })
        return Inventory.slot.invalid, item
    end
end

function Inventory:CreateItemOnGround(hero, location, item, itemStats)
    local slot, item = Inventory:AddItem(hero, item, itemStats)
    if (slot ~= Inventory.slot.invalid) then
        local itemStats = Inventory:GetItemStatsForHero(hero, false, slot)
        local itemEntity = CreateItem(item, hero, hero)
            local itemId = itemEntity:GetEntityIndex()
        local itemOnGround = CreateItemOnPositionSync(location, itemEntity)
        Inventory:SetItemEntityStats(itemEntity, itemStats)
        itemEntity:SetPurchaser(hero)
        Inventory:SetItemInSlot(hero, "", false, slot, {})
        CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), { itemWorldId = itemOnGround:GetEntityIndex(), itemStats = itemStats, itemName = itemEntity:GetAbilityName() })
    end
    return item
end

function Inventory:GetItemsByRarity(rarity)
    local result = {}
    rarity = tonumber(rarity)
    if (not rarity or rarity < 0 or rarity > Inventory.rarity.max) then
        DebugPrint("[INVENTORY] Attempt to get items with unknown rarity (rarity=" .. tostring(rarity) .. ")")
        return result
    end
    for itemName, itemData in pairs(Inventory.itemsData) do
        if (itemData.rarity == rarity) then
            table.insert(result, { name = itemName, slot = itemData.slot, rarity = itemData.rarity, stats = itemData.stats, difficulty = itemData.difficulty })
        end
    end
    return result
end

---@param item string
---@param difficulty number
---@return number
function Inventory:GenerateStatsForItem(item, difficulty)
    local result = {}
    difficulty = tonumber(difficulty)
    if (not item or not Inventory.itemsData[item] or not difficulty) then
        DebugPrint("[INVENTORY] Unable to generate stats for " .. tostring(item) .. ". Wtf?")
        DebugPrint("item", item)
        DebugPrint("Inventory.itemsData[item]", Inventory.itemsData[item])
        DebugPrint("difficulty", difficulty)
        return result
    end
    local itemStats = Inventory:GetPossibleItemStats(item)
    if (not itemStats) then
        return result
    end
    local itemDifficulty = Inventory:GetItemDifficulty(item)
    local minRoll = 0
    if (difficulty > itemDifficulty or math.abs(difficulty - itemDifficulty) < 0.01) then
        minRoll = 0.5
    end
    for statName, statValues in pairs(itemStats) do
        local value = Inventory:PerformRoll(statValues.min, statValues.max, minRoll)
        table.insert(result, { name = statName, value = value })
    end
    return result
end

function Inventory:PerformRoll(min, max, minRoll)
    min = min + ((max - min) * minRoll)
    return math.random(math.floor(min), max)
end

---@param item string
---@return table
function Inventory:GetPossibleItemStats(item)
    if (not item or not Inventory.itemsData[item]) then
        return nil
    end
    return Inventory.itemsData[item].stats
end

---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param is_equipped boolean
---@return table
function Inventory:GetItemStatsForHero(hero, is_equipped, slot)
    if (not hero or not slot or not Inventory:IsHeroHaveInventory(hero)) then
        return {}
    end
    if (is_equipped) then
        return DeepTableCopy(hero.inventory.equipped_items[slot].stats)
    else
        return DeepTableCopy(hero.inventory.items[slot].stats)
    end
end

---@param hero CDOTA_BaseNPC_Hero
---@return boolean
function Inventory:IsHeroHaveInventory(hero)
    if (hero ~= nil and hero.inventory ~= nil and hero.inventory.items ~= nil and hero.inventory.equipped_items ~= nil) then
        return true
    end
    return false
end

---@param slot number
---@param equipped boolean
---@return boolean
function Inventory:IsSlotValid(slot, equipped)
    if (slot ~= nil and equipped ~= nil) then
        if (equipped) then
            if (slot > Inventory.slot.invalid and slot <= Inventory.slot.last) then
                return true
            end
        else
            if (slot > Inventory.slot.invalid and slot < Inventory.maxStoredItems) then
                return true
            end
        end
    end
    return false
end

--- Return item name in desired slot (can be empty string if there are no item) or empty string if arguments invalid
---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param is_equipped boolean
---@return string
function Inventory:GetItemInSlot(hero, is_equipped, slot)
    slot = tonumber(slot)
    if (hero ~= nil and slot ~= nil and is_equipped ~= nil) then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (is_equipped) then
                return hero.inventory.equipped_items[slot].name
            else
                return hero.inventory.items[slot].name
            end
        end
    end
    return ""
end

--- Set item in slot and inform client about that
---@param hero CDOTA_BaseNPC_Hero
---@param slot number
---@param item string
---@param is_equipped boolean
---@param stats table
---@return boolean
function Inventory:SetItemInSlot(hero, item, is_equipped, slot, stats)
    slot = tonumber(slot)
    if (hero ~= nil and item ~= nil and is_equipped ~= nil and slot ~= nil and type(item) == "string") then
        if (Inventory:IsHeroHaveInventory(hero) and Inventory:IsSlotValid(slot, is_equipped)) then
            if (not stats) then
                stats = {}
            end
            if (is_equipped) then
                if (hero.inventory.equipped_items[slot].modifier ~= nil and not hero.inventory.equipped_items[slot].modifier:IsNull()) then
                    hero.inventory.equipped_items[slot].modifier:Destroy()
                end
                hero.inventory.equipped_items[slot].name = item
                hero.inventory.equipped_items[slot].stats = stats
                if (Inventory:IsItemNotEmpty(hero.inventory.equipped_items[slot].name)) then
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = "modifier_inventory_" .. item
                    local modifierParams = {}
                    for _, statData in pairs(stats) do
                        modifierParams[statData.name] = statData.value
                    end
                    modifierTable.modifier_params = modifierParams
                    modifierTable.duration = -1
                    hero.inventory.equipped_items[slot].modifier = GameMode:ApplyBuff(modifierTable)
                end
            else
                hero.inventory.items[slot].name = item
                hero.inventory.items[slot].stats = stats
            end
            Inventory:SendUpdateInventorySlotRequest(hero, item, is_equipped, slot, stats)
        end
    end
end

--- Return slot id for that item or Inventory.slot.invalid
---@param item string
---@return number
function Inventory:GetValidSlotForItem(item)
    if (item and Inventory.itemsData[item]) then
        return Inventory.itemsData[item].slot
    end
    return Inventory.slot.invalid
end

---@param item string
---@return boolean
function Inventory:IsItemNotEmpty(item)
    if (type(item) == "string") then
        return string.len(item) > 0
    end
    return false
end

---@param item string
---@param slot number
---@return boolean
function Inventory:IsItemValidForSlot(item, slot)
    slot = tonumber(slot)
    if (item ~= nil and slot ~= nil) then
        if (slot > Inventory.slot.invalid and Inventory.itemsData[item]) then
            return Inventory.itemsData[item].slot == slot
        end
        return false
    end
    return false
end

---@param hero CDOTA_BaseNPC_Hero
function Inventory:SetupForHero(hero)
    if (hero ~= nil) then
        hero.inventory = {}
        hero.inventory.items = {}
        hero.inventory.equipped_items = {}
        for i = 0, Inventory.maxStoredItems do
            hero.inventory.items[i] = {}
            hero.inventory.items[i].name = ""
        end
        for i = 0, Inventory.slot.last do
            hero.inventory.equipped_items[i] = {}
            hero.inventory.equipped_items[i].name = ""
        end
        Inventory:AddItem(hero,"item_one_handed_sword")
        Inventory:AddItem(hero,"item_two_handed_sword")
        Inventory:AddItem(hero,"item_silver_ring")
        Inventory:AddItem(hero,"item_chainshirt")
        Inventory:AddItem(hero,"item_wooden_shield")
        Inventory:AddItem(hero,"item_leather_boots")
        Inventory:AddItem(hero,"item_wooden_wand")
        Inventory:AddItem(hero,"item_glowing_weed")
        Inventory:AddItem(hero,"item_witchs_broom")
        Inventory:AddItem(hero,"item_twig")
        Inventory:AddItem(hero,"item_elven_slippers")
        Inventory:AddItem(hero,"item_warchief_belt")
        Inventory:AddItem(hero,"item_elven_blade")
        Inventory:AddItem(hero,"item_iron_gauntlets")
        Inventory:AddItem(hero,"item_executioner_axe")
        Inventory:AddItem(hero,"item_garnet_circlet")
        Inventory:AddItem(hero,"item_kings_crown")
        Inventory:AddItem(hero,"item_elven_armband")
        Inventory:AddItem(hero,"item_apprentice_mantle")
        Inventory:AddItem(hero,"item_wizard_robe")
        Inventory:AddItem(hero,"item_jewel_staff")
        Inventory:AddItem(hero,"item_sacred_tome")
        Inventory:AddItem(hero,"item_hatchet")
        Inventory:AddItem(hero,"item_citrine_ring")
        Inventory:AddItem(hero,"item_martial_staff")
        Inventory:AddItem(hero,"item_iron_spear")
        Inventory:AddItem(hero,"item_wolf_claw")

    end
end

---@param itemName string
---@param itemRarity number
---@param itemSlot number
function Inventory:RegisterItemSlot(itemName, itemRarity, itemSlot, itemDifficulty)
    if (itemName and itemSlot and itemRarity and itemDifficulty) then
        if (not type(itemName) == "string" or string.len(itemName) == 0) then
            DebugPrint("[INVENTORY] Item name can't be empty and must be string.")
            return
        end
        if (not Inventory:IsSlotValid(itemSlot, true)) then
            DebugPrint("[INVENTORY] Item slot (" .. itemSlot .. ") invalid.")
            return
        end
        for _, value in pairs(Inventory.itemsData) do
            if value.item == itemName then
                DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " (already exists).")
                return
            end
        end
        if (itemRarity < 0 or itemRarity > Inventory.rarity.max) then
            DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " with rarity " .. tostring(itemRarity) .. " (unknown rarity).")
            return
        end
        if (itemDifficulty < 0) then
            DebugPrint("[INVENTORY] Bad attempt to register item \"" .. tostring(itemName) .. "\" for slot " .. tostring(itemSlot) .. " with rarity " .. tostring(itemRarity) .. " (item difficulty can't be nil or negative).")
            return
        end
        local itemStats = {}
        if (Inventory.itemsKeyValues[itemName] and Inventory.itemsKeyValues[itemName]["AbilitySpecial"]) then
            local itemStatsNames = Inventory:GetItemStatsFromKeyValues(Inventory.itemsKeyValues[itemName]["AbilitySpecial"], itemName)
            for _, stat in pairs(itemStatsNames) do
                local statEntry = Inventory:FindStatValuesFromKeyValues(Inventory.itemsKeyValues[itemName]["AbilitySpecial"], stat, itemName)
                if (statEntry) then
                    itemStats[stat.name] = statEntry
                else
                    DebugPrint("[INVENTORY] Can't find min and max values for " .. tostring(stat.name) .. " in item " .. tostring(itemName) .. ". Ignoring.")
                end
            end
        end
        Inventory.itemsData[itemName] = { slot = itemSlot, rarity = itemRarity, stats = itemStats, difficulty = itemDifficulty }
    else
        DebugPrint("[INVENTORY] Bad attempt to add item (something is nil)");
        DebugPrint("itemName", itemName);
        DebugPrint("itemRarity", itemRarity);
        DebugPrint("itemSlot", itemSlot);
        DebugPrint("itemDifficulty", itemDifficulty);
    end
end

function Inventory:GetItemDifficulty(item)
    local result = 0
    if (not item or not Inventory.itemsData[item]) then
        return result
    end
    return Inventory.itemsData[item].difficulty
end

function Inventory:FindStatValuesFromKeyValues(statsTable, stat, itemName)
    local result
    local min
    local max
    for _, statEntry in pairs(statsTable) do
        for k, v in pairs(statEntry) do
            if (k == (tostring(stat.name) .. "_min")) then
                min = v
            end
            if (k == (tostring(stat.name) .. "_max")) then
                max = v
            end
        end
    end
    if (min and max) then
        if (max < min) then
            min = 0
            max = 0
            DebugPrint("[INVENTORY] Max value for stat " .. tostring(stat.name) .. " from item " .. tostring(itemName) .. " must be greater or equal min. Used 0 for both to fix that.")
        end
        result = { min = min, max = max }
    end
    return result
end

function Inventory:GetItemStatsFromKeyValues(statsTable, itemName)
    local result = {}
    for _, statEntry in pairs(statsTable) do
        local entrySize = GetTableSize(statEntry)
        if (entrySize == 2) then
            local entry
            for k, v in pairs(statEntry) do
                if (string.match(k, "_min")) then
                    entry = string.gsub(k, "_min", "")
                end
            end
            if (entry) then
                table.insert(result, { name = entry })
            end
        else
            DebugPrint("[INVENTORY] Expected two key-value pairs from ability special for item " .. tostring(itemName) .. ", but received " .. tostring(entrySize) .. ". Ignoring.")
            DebugPrintTable(statEntry)
        end
    end
    return result
end

-- Panaroma related stuff
function Inventory:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_inventory_open_window", Dynamic_Wrap(Inventory, 'OnInventoryWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_close_window", Dynamic_Wrap(Inventory, 'OnInventoryWindowCloseRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_equip_item", Dynamic_Wrap(Inventory, 'OnInventoryEquipItemRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_start_item_replace_dialog", Dynamic_Wrap(Inventory, 'OnInventoryItemReplaceDialogRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_swap_items", Dynamic_Wrap(Inventory, 'OnInventorySwapItemsRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_drop_item_on_ground", Dynamic_Wrap(Inventory, 'OnInventoryDropItemRequest'))
    CustomGameEventManager:RegisterListener("rpg_inventory_remove_equipped_item", Dynamic_Wrap(Inventory, 'OnInventoryEquippedItemRightClick'))
    CustomGameEventManager:RegisterListener("rpg_inventory_require_items_and_rest_data", Dynamic_Wrap(Inventory, 'OnInventoryItemsAndRestDataRequest'))
end

function Inventory:GenerateAndSendToPlayerInventoryItemsDataTable(player)
    local currentItem = 0
    local itemsData = {}
    for itemName, data in pairs(Inventory.itemsData) do
        if (currentItem > self.maxItemsPerRequest) then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_items_data", { items_data = json.encode(itemsData) })
            itemsData = {}
            currentItem = 0
        end
        table.insert(itemsData, { item = itemName, slot = data.slot, rarity = data.rarity, stats = data.stats })
        currentItem = currentItem + 1
    end
    if (#itemsData > 0) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_items_data", { items_data = json.encode(itemsData) })
    end
end

function Inventory:OnInventoryItemsAndRestDataRequest(event, args)
    if (event == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    Timers:CreateTimer(0,
            function()
                local hero = player:GetAssignedHero()
                if (hero == nil) then
                    return 1.0
                end
                if (not Inventory:IsHeroHaveInventory(hero)) then
                    return 1.0
                end
                Inventory:GenerateAndSendToPlayerInventoryItemsDataTable(player)
                for i = 0, Inventory.maxStoredItems do
                    local itemInInventorySlot = Inventory:GetItemInSlot(hero, false, i)
                    if (Inventory:IsItemNotEmpty(itemInInventorySlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventorySlot, false, i, Inventory:GetItemStatsForHero(hero, false, i))
                    end
                end
                for i = 0, Inventory.slot.last do
                    local itemInInventoryEquippedSlot = Inventory:GetItemInSlot(hero, true, i)
                    if (Inventory:IsItemNotEmpty(itemInInventoryEquippedSlot)) then
                        Inventory:SendUpdateInventorySlotRequest(hero, itemInInventoryEquippedSlot, true, i, Inventory:GetItemStatsForHero(hero, true, i))
                    end
                end
            end)
end

function Inventory:OnInventoryItemPickedFromGround(event)
    if (event ~= nil and event.item ~= nil and event.itemEntity ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if (player ~= nil) then
            local hero = player:GetAssignedHero()
            if (hero ~= nil) then
                if (Inventory:IsHeroHaveInventory(hero)) then
                    local itemId = event.itemEntity:GetEntityIndex()
                    if (event.itemEntity:GetPurchaser() == hero) then
                        Inventory:AddItem(hero, event.item, event.itemEntity.inventoryStats)
                    else
                        local item = CreateItem(event.item, hero, hero)
                        local positionOnGround = hero:GetAbsOrigin()
                        local itemOnGround = CreateItemOnPositionSync(positionOnGround, item)
                        local itemStats = Inventory:GetItemEntityStats(event.itemEntity)
                        Inventory:SetItemEntityStats(item, itemStats)
                        CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), { itemWorldId = itemOnGround:GetEntityIndex(), itemStats = itemStats, itemName = item:GetAbilityName() })
                    end
                    CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), nil)
                    event.itemEntity:Destroy()
                end
            end
        end
    end
end

function Inventory:OnInventoryDropItemRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.slot = tonumber(parsedData.slot)
    event.item = parsedData.item
    event.equipped = parsedData.equipped
    event.player_id = tonumber(parsedData.player_id)
    if (event.slot == nil or event.item == nil or event.equipped == nil or not GameMode:IsValidBoolean(event.equipped) or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local itemInSlot = Inventory:GetItemInSlot(hero, event.equipped, event.slot)
    if (itemInSlot ~= event.item) then
        return
    end
    local item = CreateItem(event.item, hero, hero)
    local positionOnGround = hero:GetAbsOrigin()
    local itemOnGround = CreateItemOnPositionSync(positionOnGround, item)
    local itemStats = Inventory:GetItemStatsForHero(hero, event.equipped, event.slot)
    Inventory:SetItemEntityStats(item, itemStats)
    local itemId = item:GetEntityIndex()
    CustomNetTables:SetTableValue("inventory_world_items", tostring(itemId), { itemWorldId = itemOnGround:GetEntityIndex(), itemStats = itemStats, itemName = item:GetAbilityName() })
    item:SetPurchaser(hero)
    Inventory:SetItemInSlot(hero, "", event.equipped, event.slot)
end

function Inventory:SetItemEntityStats(item, itemStats)
    if (item) then
        item.inventoryStats = itemStats
    end
end

function Inventory:GetItemEntityStats(item)
    if (item and item.inventoryStats) then
        return item.inventoryStats
    end
    return nil
end

function Inventory:OnInventorySwapItemsRequest(event, args)
    if (event == nil or event.data == nil) then
        return
    end
    local parsedData = json.decode(event.data)
    event.fromslot = tonumber(parsedData.fromslot)
    event.inslot = tonumber(parsedData.inslot)
    event.player_id = tonumber(parsedData.player_id)
    event.equipped = parsedData.equipped
    if (event.fromslot == nil or event.inslot == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    if (event.equipped == nil or not GameMode:IsValidBoolean(event.equipped)) then
        return
    end
    -- swap bottom slot with equipped slots
    if (event.equipped) then
        local itemFromSlot = Inventory:GetItemInSlot(hero, true, event.fromslot)
        local itemInSlot = Inventory:GetItemInSlot(hero, false, event.inslot)
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, true, event.fromslot)
        local statsInSlot = Inventory:GetItemStatsForHero(hero, false, event.inslot)
        -- swap equipped item with empty bottom slot
        if (not Inventory:IsItemNotEmpty(itemInSlot)) then
            Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot, statsFromSlot)
            Inventory:SetItemInSlot(hero, "", true, event.fromslot, statsInSlot)
        else
            -- swap equipped item with not empty bottom slot (conflict)
            local event_data = {
                inslot = event.fromslot,
                fromslot = event.inslot,
                item = itemInSlot,
                player_id = event.player_id
            }
            Inventory:OnInventoryItemReplaceDialogRequest(event_data, nil)
        end
    else
        -- swap in bottom slots
        local itemFromSlot = Inventory:GetItemInSlot(hero, false, event.fromslot)
        local itemInSlot = Inventory:GetItemInSlot(hero, false, event.inslot)
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.fromslot)
        local statsInSlot = Inventory:GetItemStatsForHero(hero, false, event.inslot)
        Inventory:SetItemInSlot(hero, itemInSlot, false, event.fromslot, statsInSlot)
        Inventory:SetItemInSlot(hero, itemFromSlot, false, event.inslot, statsFromSlot)
    end
end

function Inventory:OnInventoryEquippedItemRightClick(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    if (event.item == nil or event.fromslot == nil or event.player_id == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local itemFromSlot = Inventory:GetItemInSlot(hero, true, event.fromslot)
    if (not itemFromSlot or itemFromSlot ~= event.item) then
        return
    end
    if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, false, event.inslot))) then
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, true, event.fromslot)
        Inventory:SetItemInSlot(hero, "", true, event.fromslot, {})
        Inventory:SetItemInSlot(hero, event.item, false, event.inslot, statsFromSlot)
    end
end

function Inventory:OnInventoryItemReplaceDialogRequest(event, args)
    if (event == nil) then
        return
    end
    event.inslot = tonumber(event.inslot)
    event.fromslot = tonumber(event.fromslot)
    if (event.item == nil or event.fromslot == nil or event.player_id == nil or event.inslot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local desiredItemSlot = Inventory:GetValidSlotForItem(event.item)
    if (desiredItemSlot == Inventory.slot.invalid) then
        return
    end
    if (desiredItemSlot ~= event.inslot) then
        return
    end
    local itemFromSlot = Inventory:GetItemInSlot(hero, false, event.fromslot)
    if (not itemFromSlot or itemFromSlot ~= event.item) then
        return
    end
    if (not Inventory:IsItemNotEmpty(Inventory:GetItemInSlot(hero, true, desiredItemSlot))) then
        local statsInSlot = Inventory:GetItemStatsForHero(hero, true, desiredItemSlot)
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.fromslot)
        Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot, statsFromSlot)
        Inventory:SetItemInSlot(hero, "", false, event.fromslot, statsInSlot)
    else
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_start_item_replace_dialog_from_server", { player_id = event.player_id, item = event.item, slot = event.fromslot })
    end
end

function Inventory:OnInventoryWindowOpenRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_open_window_from_server", {})
        end
    end
end

function Inventory:OnInventoryWindowCloseRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_close_window_from_server", {})
        end
    end
end

function Inventory:OnInventoryEquipItemRequest(event, args)
    if (event == nil) then
        return
    end
    event.slot = tonumber(event.slot)
    if (event.player_id == nil or event.item == nil or event.slot == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if player == nil then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil or not hero:IsAlive()) then
        return
    end
    if (not Inventory:IsHeroHaveInventory(hero)) then
        return
    end
    local desiredItemSlot = Inventory:GetValidSlotForItem(event.item)
    if (desiredItemSlot == Inventory.slot.invalid) then
        return
    end
    local itemInSlot = Inventory:GetItemInSlot(hero, false, event.slot)
    if (itemInSlot == event.item) then
        local statsFromSlot = Inventory:GetItemStatsForHero(hero, false, event.slot)
        Inventory:SetItemInSlot(hero, event.item, true, desiredItemSlot, statsFromSlot)
        Inventory:SetItemInSlot(hero, "", false, event.slot, {})
    end
end

function Inventory:SendUpdateInventorySlotRequest(hero, itemName, is_equipped, itemSlot, itemStats)
    if (hero ~= nil and itemName ~= nil and is_equipped ~= nil and itemSlot ~= nil) then
        local player = hero:GetPlayerOwner()
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_inventory_update_slot", { item = itemName, equipped = is_equipped, slot = itemSlot, stats = json.encode(itemStats) })
    end
end

if not Inventory.initialized then
    Inventory:Init()
    Inventory.initialized = true
end