modifier_inventory_item_two_handed_sword = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_two_handed_sword:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_two_handed_sword:GetAttackDamageBonus()
    return self.data.attack_damage
end

function modifier_inventory_item_two_handed_sword:GetMoveSpeedBonus()
    return self.data.move_speed_reduce
end

LinkLuaModifier("modifier_inventory_item_two_handed_sword", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_one_handed_sword = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_one_handed_sword:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_one_handed_sword:GetAttackDamageBonus()
    return self.data.attack_damage
end

function modifier_inventory_item_one_handed_sword:GetAttackSpeedBonus()
    return self.data.attack_speed
end

LinkLuaModifier("modifier_inventory_item_one_handed_sword", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_silver_ring = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_silver_ring:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_silver_ring:GetSpellHasteBonus()
    return self.data.spellhaste * 0.01
end

LinkLuaModifier("modifier_inventory_item_silver_ring", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_chainshirt = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_chainshirt:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_chainshirt:GetArmorBonus()
    return self.data.armor
end

function modifier_inventory_item_chainshirt:GetFireProtectionBonus()
    return self.data.fire_resist_reduce*0.01
end

LinkLuaModifier("modifier_inventory_item_chainshirt", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_wooden_shield = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_wooden_shield:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_wooden_shield:GetBlockBonus()
    return self.data.block
end

LinkLuaModifier("modifier_inventory_item_wooden_shield", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_leather_boots = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_leather_boots:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_leather_boots:GetMoveSpeedBonus()
    return self.data.move_speed
end

LinkLuaModifier("modifier_inventory_item_leather_boots", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_wooden_wand = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_wooden_wand:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_wooden_wand:GetSpellHasteBonus()
    return self.data.spellhaste * 0.01
end

function modifier_inventory_item_wooden_wand:GetManaRegenerationBonus()
    return self.data.mana_regen
end

LinkLuaModifier("modifier_inventory_item_wooden_wand", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_glowing_weed = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_glowing_weed:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
    self:StartIntervalThink(5)
end

function modifier_inventory_item_glowing_weed:GetHealthRegenerationBonus()
    return self.data.health_regen
end

function modifier_inventory_item_glowing_weed:GetManaRegenerationBonus()
    return self.data.mana_regen
end

function modifier_inventory_item_glowing_weed:GetAttackSpeedBonus()
    return self.data.attack_speed_reduce
end

function modifier_inventory_item_glowing_weed:GetSpellHasteBonus()
    return self.data.spellhaste_reduce*0.01
end

function modifier_inventory_item_glowing_weed:GetMoveSpeedBonus()
    return self.data.move_speed_reduce
end

function modifier_inventory_item_glowing_weed:OnIntervalThink()
    if RollPercentage(self.data.blank_chance) then
        local modifierTable = {}
        modifierTable.ability = self
        modifierTable.target = self:GetParent()
        modifierTable.caster = self:GetParent()
        modifierTable.modifier_name = "modifier_stunned"
        modifierTable.duration = self.data.blank_stun
        GameMode:ApplyDebuff(modifierTable)
    end
end

LinkLuaModifier("modifier_inventory_item_glowing_weed", "items/item", LUA_MODIFIER_MOTION_NONE)


modifier_inventory_item_witchs_broom = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    GetEffectName = function(self)
        return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
    end,
})

function modifier_inventory_item_witchs_broom:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
    self.parent = self:GetParent()
    self.fly = 0
    self:StartIntervalThink(1)
end

function modifier_inventory_item_witchs_broom:OnIntervalThink()
    local MaxMana = self.parent:GetMaxMana()
    local drain = MaxMana * self.data.mana_drain_percent * 0.01 + self.data.mana_drain
    local Mana = self.parent:GetMana()
    if Mana/MaxMana < 0.25 then
        self.fly = 0
    else
        self.parent:ReduceMana(drain)
        self.fly = 1
        Units:ForceStatsCalculation(self.parent)
    end
end

function modifier_inventory_item_witchs_broom:GetMoveSpeedBonus()
    if self.fly == 0 then
        return 0
    else
        return self.data.move_speed
    end
end

function modifier_inventory_item_witchs_broom:GetSpellHasteBonus()
    return self.data.spellhaste * 0.01
end

function modifier_inventory_item_witchs_broom:GetIntellectBonus()
    return self.data.intellect
end

LinkLuaModifier("modifier_inventory_item_witchs_broom", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_twig = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_twig:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_twig:GetHealthRegenerationBonus()
    return self.data.health_regen
end

function modifier_inventory_item_twig:GetAttackDamageBonus()
    return self.data.attack_damage
end

LinkLuaModifier("modifier_inventory_item_twig", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_elven_slippers = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_elven_slippers:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_elven_slippers:GetMoveSpeedBonus()
    return self.data.move_speed
end

function modifier_inventory_item_elven_slippers:GetAgilityBonus()
    return self.data.agility
end

LinkLuaModifier("modifier_inventory_item_elven_slippers", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_warchief_belt = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_warchief_belt:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_warchief_belt:GetArmorBonus()
    return self.data.armor
end

function modifier_inventory_item_warchief_belt:GetStrengthBonus()
    return self.data.strength
end

LinkLuaModifier("modifier_inventory_item_warchief_belt", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_elven_blade = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_elven_blade:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_elven_blade:GetAgilityBonus()
    return self.data.agility
end

function modifier_inventory_item_elven_blade:GetAttackSpeedBonus()
    return self.data.attack_speed
end

LinkLuaModifier("modifier_inventory_item_elven_blade", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_iron_gauntlets = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_iron_gauntlets:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_iron_gauntlets:GetStrengthBonus()
    return self.data.strength
end

LinkLuaModifier("modifier_inventory_item_iron_gauntlets", "items/item", LUA_MODIFIER_MOTION_NONE)


modifier_inventory_item_executioner_axe = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_executioner_axe:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_executioner_axe:GetAttackDamageBonus()
    return self.data.attack_damage
end

---@param damageTable DAMAGE_TABLE
function modifier_inventory_item_executioner_axe:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_inventory_item_executioner_axe")
    if (damageTable.damage > 0 and modifier and GameMode:RollCriticalChance(damageTable.attacker, modifier.data.crit_chance) and not damageTable.ability and damageTable.physdmg ) then
        damageTable.crit = modifier.data.crit_damage *0.01
        return damageTable
    end
end

LinkLuaModifier("modifier_inventory_item_executioner_axe", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_garnet_circlet = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_garnet_circlet:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_garnet_circlet:GetPrimaryAttributeBonus()
    return self.data.primary
end

LinkLuaModifier("modifier_inventory_item_garnet_circlet", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_kings_crown = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_kings_crown:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_kings_crown:GetPrimaryAttributeBonus()
    return self.data.primary
end

function modifier_inventory_item_kings_crown:GetHealthBonus()
    return self.data.health
end

function modifier_inventory_item_kings_crown:GetManaBonus()
    return self.data.mana
end

LinkLuaModifier("modifier_inventory_item_kings_crown", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_elven_armband = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_elven_armband:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_elven_armband:GetAttackSpeedBonus()
    return self.data.attack_speed
end

function modifier_inventory_item_elven_armband:GetHealthBonus()
    return self.data.health
end
LinkLuaModifier("modifier_inventory_item_elven_armband", "items/item", LUA_MODIFIER_MOTION_NONE)
modifier_inventory_item_apprentice_mantle = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_apprentice_mantle:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_apprentice_mantle:GetIntellectBonus()
    return self.data.intellect
end

LinkLuaModifier("modifier_inventory_item_apprentice_mantle", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_wizard_robe = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_wizard_robe:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_wizard_robe:GetIntellectBonus()
    return self.data.intellect
end

function modifier_inventory_item_wizard_robe:GetHealthBonus()
    return self.data.health
end

LinkLuaModifier("modifier_inventory_item_wizard_robe", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_jewel_staff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_jewel_staff:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_jewel_staff:GetIntellectBonus()
    return self.data.intellect
end

function modifier_inventory_item_jewel_staff:GetSpellHasteBonus()
    return self.data.spellhaste * 0.01
end

LinkLuaModifier("modifier_inventory_item_jewel_staff", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_sacred_tome = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_sacred_tome:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_sacred_tome:GetIntellectBonus()
    return self.data.intellect
end

function modifier_inventory_item_sacred_tome:GetHolyDamageBonus()
    return self.data.holy_damage * 0.01
end

function modifier_inventory_item_sacred_tome:GetHealingCausedBonus()
    return self.data.healing_caused
end

LinkLuaModifier("modifier_inventory_item_sacred_tome", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_hatchet = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_hatchet:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_hatchet:GetStrengthBonus()
    return self.data.strength
end

function modifier_inventory_item_hatchet:GetAttackDamageBonus()
    return self.data.attack_damage
end

LinkLuaModifier("modifier_inventory_item_hatchet", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_citrine_ring = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_citrine_ring:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_citrine_ring:GetArmorBonus()
    return self.data.armor
end

LinkLuaModifier("modifier_inventory_item_citrine_ring", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_martial_staff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_martial_staff:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_martial_staff:GetAttackDamageBonus()
    return self.data.attack_damage
end

function modifier_inventory_item_martial_staff:GetSpellHasteBonus()
    return self.data.spellhaste * 0.01
end

LinkLuaModifier("modifier_inventory_item_martial_staff", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_iron_spear = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_iron_spear:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end

function modifier_inventory_item_iron_spear:GetAttackDamageBonus()
    return self.data.attack_damage
end

function modifier_inventory_item_iron_spear:OnAttackLanded(keys)
    if not IsServer() then
        return
    end
    if (keys.attacker == self.parent) and keys.attacker:IsAlive() and RollPercentage(self.data.phys_proc_chance) then
        local damageTable = {}
        damageTable.caster = keys.attacker
        damageTable.target = keys.victim
        damageTable.ability = nil
        damageTable.damage = self.data.phys_proc_damage
        damageTable.physdmg = true
        GameMode:DamageUnit(damageTable)
    end
end

LinkLuaModifier("modifier_inventory_item_iron_spear", "items/item", LUA_MODIFIER_MOTION_NONE)

modifier_inventory_item_wolf_claw = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return true
    end,
    IsPurgable = function(self)
        return false
    end,
    RemoveOnDeath = function(self)
        return false
    end,
    AllowIllusionDuplicate = function(self)
        return false
    end,
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
})

function modifier_inventory_item_wolf_claw:OnCreated(keys)
    if(not IsServer()) then
        return
    end
    self.data = keys
end


---@param damageTable DAMAGE_TABLE
function modifier_inventory_item_wolf_claw:OnTakeDamage(damageTable)
    local modifier = damageTable.attacker:FindModifierByName("modifier_inventory_item_wolf_claw")
    if (damageTable.damage > 0 and modifier and GameMode:RollCriticalChance(damageTable.attacker, modifier.data.ab_crit_chance) and damageTable.ability ) then
        damageTable.crit = modifier.data.ab_crit_damage *0.01
        return damageTable
    end
end

LinkLuaModifier("modifier_inventory_item_wolf_claw", "items/item", LUA_MODIFIER_MOTION_NONE)

if (IsServer() and not GameMode.the_biggest_oversight) then
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_inventory_item_executioner_axe, 'OnTakeDamage'))
    GameMode:RegisterPreDamageEventHandler(Dynamic_Wrap(modifier_inventory_item_wolf_claw, 'OnTakeDamage'))
    GameMode.the_biggest_oversight = true
end