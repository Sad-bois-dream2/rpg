if TalentTree == nil then
    _G.TalentTree = class({})
end

-- for test only, remove later pls
if (IsServer() and IsInToolsMode()) then
    ListenToGameEvent("player_chat", function(event)
        if (event.text == "-reset") then
            local player = PlayerResource:GetPlayer(event.playerid)
            local hero = player:GetAssignedHero()
            TalentTree:Reset(hero)
        end
    end, nil)
end

function TalentTree:Init()
    -- Changing that value will prob require fix for TalentTree:GetTalentLine() and TalentTree:GetTalentBranch()
    self.latestTalentId = 63
    self.maxTalentPoints = 32
    TalentTree:InitPanaromaEvents()
end


-- internal stuff to make all work
function TalentTree:GetLatestTalentID()
    return TalentTree.latestTalentId
end

---@param hero CDOTA_BaseNPC_Hero
---@return number
function TalentTree:GetHeroMaxTalentPoints(hero)
    if (hero) then
        return TalentTree.maxTalentPoints
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:SetupForHero(hero)
    if (hero ~= nil) then
        hero.talents = {}
        hero.talents.level = {}
        hero.talents.modifiers = {}
        for i = 1, TalentTree:GetLatestTalentID() do
            hero.talents.level[i] = 0
        end
    end
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:Reset(hero)
    if (hero and hero.talents) then
        for talentId = 1, TalentTree:GetLatestTalentID() do
            TalentTree:SetHeroTalentLevel(hero, talentId, 0)
        end
        local event = {
            player_id = hero:GetPlayerID()
        }
        TalentTree:OnTalentTreeStateRequest(event, nil)
    end
end

---@param hero CDOTA_BaseNPC_Hero
---@return number
function TalentTree:GetHeroCurrentTalentPoints(hero)
    local currentTalentPoints = TalentTree:GetHeroMaxTalentPoints(hero)
    if (TalentTree:IsHeroHaveTalentTree(hero)) then
        for i = 1, #hero.talents.level do
            currentTalentPoints = currentTalentPoints - hero.talents.level[i]
        end
        return currentTalentPoints
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@return boolean
function TalentTree:IsHeroHaveTalentTree(hero)
    if (hero ~= nil and hero.talents ~= nil and hero.talents.level ~= nil) then
        return true
    end
    return false
end

function TalentTree:OnTalentTreeLevelUpRequest(event, args)
    if (event == nil or not event.PlayerID) then
        return
    end
    event.player_id = tonumber(event.PlayerID)
    event.talent_id = tonumber(event.talent_id)
    if (event.talent_id == nil or event.player_id == nil) then
        return
    end
    local player = PlayerResource:GetPlayer(event.player_id)
    if (player == nil) then
        return
    end
    local hero = player:GetAssignedHero()
    if (hero == nil) then
        return
    end
    if (not TalentTree:IsHeroHaveTalentTree(hero)) then
        return
    end
    local desiredTalentLine = TalentTree:GetTalentLine(event.talent_id)
    if (desiredTalentLine == 0) then
        return
    end
    local desiredTalentBranch = TalentTree:GetTalentBranch(event.talent_id)
    if (desiredTalentBranch == 0) then
        return
    end
    local IsPointsRequirmentPassed = false
    if (desiredTalentLine > 0) then
        IsPointsRequirmentPassed = TalentTree:IsRequiredPointsForLineAndBranchConditionMeet(hero, desiredTalentLine, desiredTalentBranch)
    end
    if (IsPointsRequirmentPassed == false) then
        return
    end
    local maxLevelOfTalent = TalentTree:GetMaxLevelForTalent(event.talent_id)
    local heroLevelOfTalent = TalentTree:GetHeroTalentLevel(hero, event.talent_id)
    local IsHeroHaveEnoughTalentPoints = (TalentTree:GetHeroCurrentTalentPoints(hero) >= 1)
    local IsHeroCanLevelUpTalent = (heroLevelOfTalent < maxLevelOfTalent) and IsHeroHaveEnoughTalentPoints
    if (IsHeroCanLevelUpTalent) then
        TalentTree:SetHeroTalentLevel(hero, event.talent_id, heroLevelOfTalent + 1)
        local event = {
            PlayerID = event.player_id
        }
        TalentTree:OnTalentTreeStateRequest(event, nil)
    end
end

---@param talentId number
---@return boolean
function TalentTree:IsTalentIdValid(talentId)
    if (talentId > 0 and talentId <= TalentTree:GetLatestTalentID()) then
        return true
    end
    return false
end

---@param hero CDOTA_BaseNPC_Hero
---@param talentId number
---@param level number
---@return number
function TalentTree:SetHeroTalentLevel(hero, talentId, level)
    talentId = tonumber(talentId)
    level = tonumber(level)
    if (hero ~= nil and hero:IsAlive() and talentId ~= nil and level ~= nil and level > -1) then
        if (TalentTree:IsHeroHaveTalentTree(hero)) then
            if (TalentTree:IsTalentIdValid(talentId)) then
                hero.talents.level[talentId] = level
                if (level == 0 and hero.talents.modifiers[talentId] ~= nil) then
                    hero.talents.modifiers[talentId]:Destroy()
                    hero.talents.modifiers[talentId] = nil
                end
                if (level > 0 and hero.talents.modifiers[talentId] == nil) then
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = "modifier_talent_" .. tostring(talentId)
                    modifierTable.duration = -1
                    hero.talents.modifiers[talentId] = GameMode:ApplyBuff(modifierTable)
                end
            end
        end
    end
end

---@param hero CDOTA_BaseNPC_Hero
---@param talentId number
---@return number
function TalentTree:GetHeroTalentLevel(hero, talentId)
    talentId = tonumber(talentId)
    if (hero ~= nil and talentId ~= nil) then
        if (TalentTree:IsHeroHaveTalentTree(hero)) then
            if (TalentTree:IsTalentIdValid(talentId)) then
                return hero.talents.level[talentId]
            end
        end
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@param line number
---@param branch number
---@return number
function TalentTree:GetPointsSpendedInLinesIncludeThisForBranch(hero, line, branch)
    line = tonumber(line)
    branch = tonumber(branch)
    if (hero ~= nil and line ~= nil and branch ~= nil) then
        local result = 0
        for i = 1, line do
            result = result + TalentTree:GetPointsSpendedInLineForBranch(hero, i, branch)
        end
        return result
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@param line number
---@param branch number
---@return number
function TalentTree:GetPointsSpendedInLineForBranch(hero, line, branch)
    local result = 0
    line = tonumber(line)
    branch = tonumber(branch)
    if (hero ~= nil and line ~= nil and branch ~= nil and TalentTree:IsHeroHaveTalentTree(hero)) then
        for i = 1, TalentTree:GetLatestTalentID() do
            if (TalentTree:GetTalentBranch(i) == branch and TalentTree:GetTalentLine(i) == line) then
                result = result + TalentTree:GetHeroTalentLevel(hero, i)
            end
        end
    end
    return result
end

---@param hero CDOTA_BaseNPC_Hero
---@param line number
---@return number
function TalentTree:GetPointsSpendedInLine(hero, line)
    line = tonumber(line)
    if (hero ~= nil and line ~= nil) then
        local result = 0
        for i = 1, 3 do
            result = result + TalentTree:GetPointsSpendedInLineForBranch(hero, line, i)
        end
        return result
    end
    return 0
end

---@param talentId number
---@return number
function TalentTree:GetTalentBranch(talentId)
    talentId = tonumber(talentId)
    if (talentId) then
        local talentColumn = talentId % 9
        if (talentColumn >= 1 and talentColumn <= 3) then
            return 1
        end
        if (talentColumn >= 4 and talentColumn <= 6) then
            return 2
        end
        return 3
    end
    return 0
end

---@param talentId number
---@return number
function TalentTree:GetTalentLine(talentId)
    talentId = tonumber(talentId)
    if (talentId) then
        return math.ceil(talentId / 9)
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@param talentId number
---@param branch number
---@return number
function TalentTree:IsRequiredPointsForLineAndBranchConditionMeet(hero, line, branch)
    line = tonumber(line)
    branch = tonumber(branch)
    if (not hero or not line or not branch) then
        return false
    end
    return TalentTree:GetPointsSpendedInLinesIncludeThisForBranch(hero, line, branch) >= ((line - 1) * 3)
end

---@param talentId number
---@return number
function TalentTree:GetMaxLevelForTalent(talentId)
    talentId = tonumber(talentId)
    if (talentId) then
        return 3
    end
    return 0
end

-- Panaroma stuff
function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_talenttree_open_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_close_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowCloseRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_lvlup_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_require_player_talents_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
end

function TalentTree:OnTalentTreeStateRequest(event)
    if (event == nil) then
        return
    end
    event.player_id = tonumber(event.PlayerID)
    if (not event.player_id) then
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
                if (not TalentTree:IsHeroHaveTalentTree(hero)) then
                    return 1.0
                end
                local resultTable = {}
                for i = 1, TalentTree:GetLatestTalentID() do
                    local talentLvl = TalentTree:GetHeroTalentLevel(hero, i)
                    local talentMaxLvl = TalentTree:GetMaxLevelForTalent(i)
                    local talentLine = TalentTree:GetTalentLine(i)
                    local talentBranch = TalentTree:GetTalentBranch(i)
                    local IsRequiredPointsForLineAndBranchConditionMeet = TalentTree:IsRequiredPointsForLineAndBranchConditionMeet(hero, talentLine, talentBranch)
                    local IsTalentMissLevels = (talentLvl < talentMaxLvl) and IsRequiredPointsForLineAndBranchConditionMeet
                    table.insert(resultTable, { talent_id = i, disabled = (not IsRequiredPointsForLineAndBranchConditionMeet), lvlup = IsTalentMissLevels, level = talentLvl, maxlevel = talentMaxLvl })
                end
                if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
                    for _, talent in pairs(resultTable) do
                        if (TalentTree:GetHeroTalentLevel(hero, talent.talent_id) == 0) then
                            talent.disabled = true
                            talent.lvlup = false
                        end
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_require_player_talents_state_from_server", { player_id = event.player_id, data = json.encode(resultTable) })
                TalentTree:SendTotalTalentPointsToPlayer(player)
            end)
end

function TalentTree:SendTotalTalentPointsToPlayer(player)
    if (player ~= nil) then
        local player_id = player:GetPlayerID()
        if (player_id ~= nil) then
            local hero = player:GetAssignedHero()
            if (hero ~= nil) then
                local totalTalentPoints = TalentTree:GetHeroCurrentTalentPoints(hero)
                CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_update_total_talents_points", { player_id = player_id, amount = totalTalentPoints })
            end
        end
    end
end

function TalentTree:OnTalentTreeWindowOpenRequest(event)
    if (event and event.PlayerID) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_open_window_from_server", {})
        end
    end
end

function TalentTree:OnTalentTreeWindowCloseRequest(event)
    if (event and event.PlayerID) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_close_window_from_server", {})
        end
    end
end

function TalentTree:LoadTalentsFromSaveData(playerHero, talentData)
    if (not playerHero or not talentData) then
        return
    end
    TalentTree:RemoveAllTalentAbilities(playerHero)
    for talentId = 1, TalentTree:GetLatestTalentID() do
        local talentLevel = tonumber(talentData["talent" .. talentId])
        if (not talentLevel) then
            talentLevel = 0
        end
        TalentTree:SetHeroTalentLevel(playerHero, talentId, talentLevel)
    end
    local new_event = {
        player_id = playerHero:GetPlayerID()
    }
    TalentTree:OnTalentTreeStateRequest(new_event, nil)
end

if IsServer() and not TalentTree.initialized then
    TalentTree:Init()
    TalentTree.initialized = true
end