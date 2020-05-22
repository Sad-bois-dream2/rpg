if HeroSelection == nil then
    _G.HeroSelection = class({})
end

modifier_heroselection = class({
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
    CheckState = function(self)
        return {
            [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
            [MODIFIER_STATE_ROOTED] = true,
            [MODIFIER_STATE_DISARMED] = true,
            [MODIFIER_STATE_ATTACK_IMMUNE] = true,
            [MODIFIER_STATE_SILENCED] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_STUNNED] = true,
            [MODIFIER_STATE_OUT_OF_GAME] = true,
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_FLYING] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_UNSELECTABLE] = true,
            [MODIFIER_STATE_INVULNERABLE] = true,
            [MODIFIER_STATE_INVISIBLE] = true
        }
    end
})

LinkLuaModifier("modifier_heroselection", "systems/heroselection", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    if (unit:GetUnitName() == "npc_dota_hero_poor_soul") then
        unit:AddNewModifier(unit, nil, "modifier_heroselection", { Duration = -1 })
        HideWearables(unit)
    end
end, nil)