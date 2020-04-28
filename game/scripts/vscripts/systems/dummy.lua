modifier_dps_dummy = modifier_dps_dummy or class({
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
    end
})

---@param damageTable DAMAGE_TABLE
function modifier_dps_dummy:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_dps_dummy")
    if (modifier) then

    end
end

LinkLuaModifier("modifier_dps_dummy", "systems/dummy", LUA_MODIFIER_MOTION_NONE)

if not Dummy then
    Dummy = class({})
end

function Dummy:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_dummy_on_start", Dynamic_Wrap(Dummy, 'OnDummyStartRequest'))
end

function Dummy:OnDummyStartRequest(event)
    if (not event) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (not event.player_id) then
        return
    end
    event.dummy = tonumber(event.dummy)
    if(not event.dummy) then
        return
    end

end

function Dummy:OnNPCSpawned(keys)
    if (not IsServer()) then
        return
    end
    local dummy = EntIndexToHScript(keys.entindex)
    if (dummy and dummy:GetUnitName() == "npc_dummy_dps_unit" and not dummy:HasModifier("modifier_dps_dummy") and dummy:GetTeam() ~= DOTA_TEAM_GOODGUYS) then
        dummy:AddNewModifier(hero, nil, "modifier_dps_dummy", { Duration = -1 })
    end
end

if not Dummy.initialized and IsServer() then
    ListenToGameEvent('npc_spawned', Dynamic_Wrap(Dummy, 'OnNPCSpawned'), Dummy)
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_dps_dummy, 'OnPostTakeDamage'))
    Dummy:InitPanaromaEvents()
    Dummy.initialized = true
end

