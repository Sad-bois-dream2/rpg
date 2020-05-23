
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
    return self.data.spellhaste
end

function modifier_inventory_item_silver_ring:GetSpellHastePercentBonus()
    return self.data.spellhaste_percent
end

LinkLuaModifier("modifier_inventory_item_silver_ring", "items/item_silver_ring", LUA_MODIFIER_MOTION_NONE)