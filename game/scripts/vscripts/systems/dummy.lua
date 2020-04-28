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

modifier_dps_dummy_counter = modifier_dps_dummy_counter or class({
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

function modifier_dps_dummy_counter:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    if (not keys or not keys.delay) then
        self:Destroy()
    end
    self.parent = self:GetParent()
    self.particle = ParticleManager:CreateParticle("particles/units/dummy/dummy.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0, keys.delay, 0))
    self:SetStackCount(keys.delay)
    self:StartIntervalThink(1.0)
end

function modifier_dps_dummy_counter:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local stacks = self:GetStackCount() - 1
    if (stacks < 1) then
        self:Destroy()
    else
        ParticleManager:SetParticleControl(self.particle, 1, Vector(0, stacks, 0))
        self:SetStackCount(stacks)
    end
end

function modifier_dps_dummy_counter:OnDestroy()
    if (not IsServer()) then
        return
    end
    local responses = { "ogre_magi_ogmag_kill_06", "ogre_magi_ogmag_attack_04", "ogre_magi_ogmag_level_07" }
    self.parent:EmitSound(responses[math.random(#responses)])
    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

LinkLuaModifier("modifier_dps_dummy_counter", "systems/dummy", LUA_MODIFIER_MOTION_NONE)

if not Dummy then
    Dummy = class({})
end

function Dummy:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_dummy_start", Dynamic_Wrap(Dummy, 'OnDummyStartRequest'))
    CustomGameEventManager:RegisterListener("rpg_dummy_open_window", Dynamic_Wrap(Dummy, 'OnDummyOpenWindowRequest'))
    CustomGameEventManager:RegisterListener("rpg_dummy_close_window", Dynamic_Wrap(Dummy, 'OnDummyCloseWindowRequest'))
end

function Dummy:OnDummyCloseWindowRequest(event)
    if (not event) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (not event.player_id) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_dummy_close_window_from_server", { player_id = event.player_id })
    end
end

function Dummy:OnDummyOpenWindowRequest(event)
    if (not event) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (not event.player_id) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_dummy_open_window_from_server", { player_id = event.player_id })
    end
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
    if (not event.dummy) then
        return
    end
    event.dummy = EntIndexToHScript(event.dummy)
    if (not event.dummy or event.dummy:IsNull() or not event.dummy:HasModifier("modifier_dps_dummy")) then
        return
    end
    event.dummy:AddNewModifier(event.dummy, nil, "modifier_dps_dummy_counter", { duration = -1, delay = 5 })
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

