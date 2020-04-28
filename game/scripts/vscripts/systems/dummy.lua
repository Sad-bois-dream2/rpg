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
    local playerId = damageTable.attacker:GetPlayerID()
    if (modifier and damageTable.victim.isready and playerId == damageTable.victim.owner) then
        local abilityDamage = false
        local abilityName = ""
        if (damageTable.ability) then
            abilityDamage = true
            abilityName = damageTable.ability:GetAbilityName()
        end
        local event = {
            player_id = playerId,
            damage = damageTable.damage,
            source = damageTable.attacker:GetUnitName(),
            ability = abilityDamage,
            abilityName = abilityName,
            physdmg = damageTable.physdmg,
            puredmg = damageTable.puredmg,
            firedmg = damageTable.firedmg,
            frostdmg = damageTable.frostdmg,
            earthdmg = damageTable.earthdmg,
            naturedmg = damageTable.naturedmg,
            voiddmg = damageTable.voiddmg,
            infernodmg = damageTable.infernodmg,
            holydmg = damageTable.holydmg,
            fromsummon = damageTable.fromsummon,
        }
        table.insert(damageTable.victim.damageInstances, event)
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "rpg_dummy_damage", event)
    end
end

function modifier_dps_dummy:OnCreated()
    if (not IsServer()) then
        return
    end
    self.damageInstances = {}
    self.parent = self:GetParent()
    Timers:CreateTimer(0, function()
        local scaling = self.parent:FindModifierByName("modifier_creep_scaling")
        if (scaling) then
            scaling:Destroy()
        end
        return 0.25
    end, self)
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
    self.parent.isready = true
    local dummy = self.parent
    Timers:CreateTimer(Dummy.DPS_TIME, function()
        Dummy:CalculateDPS(dummy)
    end, nil)
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

function Dummy:CalculateDPS(dummy)
    if (not IsServer() or not dummy) then
        return
    end
    local dps = 0
    for _, instance in pairs(dummy.damageInstances) do
        dps = dps + instance.damage
    end
    dps = dps / Dummy.DPS_TIME
    local player = PlayerResource:GetPlayer(dummy.owner)
    local event = {
        player_id = dummy.owner,
        dps = dps
    }
    CustomGameEventManager:Send_ServerToPlayer(player, "rpg_dummy_result_dps", event)
    dummy.isbusy = nil
    dummy.isready = nil
    dummy.owner = nil
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
    if (event.dummy.isbusy and event.player_id ~= event.dummy.owner) then
        return
    end
    event.dummy.damageInstances = {}
    event.dummy.isbusy = true
    event.dummy.owner = event.player_id
    event.dummy:AddNewModifier(event.dummy, nil, "modifier_dps_dummy_counter", { duration = -1, delay = Dummy.DPS_DELAY })
    EmitSoundOn("ogre_magi_ogmag_battlebegins_01", event.dummy)
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
    Dummy.DPS_TIME = 10
    Dummy.DPS_DELAY = 5
    Dummy.initialized = true
end

