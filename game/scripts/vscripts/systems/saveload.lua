if not SaveLoad then
    SaveLoad = class({})
end

function SaveLoad:Init()

end

modifier_save_npc = class({
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
    GetAttributes = function(self)
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function(self)
        return { MODIFIER_PROPERTY_MIN_HEALTH }
    end,
    CheckState = function(self)
        return {
            [MODIFIER_STATE_NO_HEALTH_BAR] = true,
            [MODIFIER_STATE_INVULNERABLE] = true
        }
    end,
    GetMinHealth = function(self)
        return 1
    end
})

LinkLuaModifier("modifier_save_npc", "systems/saveload", LUA_MODIFIER_MOTION_NONE)

function SaveLoad:InitPanaromaEvents()

end

function SaveLoad:OnNPCSpawned(keys)
    if (not IsServer()) then
        return
    end
    local saveNpc = EntIndexToHScript(keys.entindex)
    if (saveNpc and saveNpc:GetUnitName() == "npc_save_unit" and not saveNpc:HasModifier("modifier_save_npc") and saveNpc:GetTeam() == DOTA_TEAM_GOODGUYS) then
        saveNpc:AddNewModifier(saveNpc, nil, "modifier_save_npc", { Duration = -1 })
    end
end

if not SaveLoad.initialized and IsServer() then
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(SaveLoad, 'OnNPCSpawned'), SaveLoad)
    SaveLoad:InitPanaromaEvents()
    SaveLoad:Init()
    SaveLoad.initialized = true
end
