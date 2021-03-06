if TalentTree == nil then
    _G.TalentTree = class({})
end

function TalentTree:Init()
    if (not IsServer() or TalentTree.initialized) then
        return
    end
    local data = LoadKeyValues("scripts/npc/npc_talents_custom.txt")
    self.talentsData = {}
    self.talentsRequirements = {}
    if (not data) then
        DebugPrint("[TalentTree] Error loading scripts/npc/npc_talents_custom.txt.")
        return
    end
    if (not data.Talents) then
        DebugPrint("[TalentTree] Can't find talents data.")
        return
    end
    if (not data.Requirements) then
        DebugPrint("[TalentTree] Can't find talents requirements data.")
        return
    end
    if (not data.Settings) then
        DebugPrint("[TalentTree] Can't load settings. Using default values.")
        self.maxTalentsPerRequest = 10
    else
        self.maxTalentsPerRequest = tonumber(data.Settings.MaxTalentsPerRequest) or 10
    end
    for talentId, talentData in pairs(data.Talents) do
        local convertedId = tonumber(talentId)
        if (convertedId < 1) then
            DebugPrint("[TalentTree] Talent id must be greater than 0. Skipped.")
        else
            if (TalentTree:IsValidTalent(convertedId, talentData) == true) then
                self.talentsData[convertedId] = talentData
            end
        end
    end
    for key, requirementsData in pairs(data.Requirements) do
        if (TalentTree:IsValidRequirement(key, requirementsData) == true) then
            self.talentsRequirements[key] = requirementsData
        end
    end
    for _, talentData in pairs(self.talentsData) do
        local requirementsFinded = false
        for _, requirementsData in pairs(self.talentsRequirements) do
            if(requirementsData.Row == talentData.Row and requirementsData.Column == talentData.Column) then
                requirementsFinded = true
            end
        end
        if(requirementsFinded == false) then
            DebugPrint("[TalentTree] Can't find requirements data for row "..talentData.Row.." and column "..talentData.Column..". This will lead to problems so talent tree loading abandoned.")
            return
        end
    end
    TalentTree:InitPanaromaEvents()
    TalentTree.initialized = true
end

function TalentTree:IsValidRequirement(id, requirementsData)
    if (not requirementsData) then
        return false
    end
    requirementsData.Row = tonumber(requirementsData.Row)
    if (not requirementsData.Row) then
        DebugPrint("[TalentTree] Can't find row for requirement " .. tostring(id) .. ". Skipped.")
        return false
    end
    requirementsData.Column = tonumber(requirementsData.Column)
    if (not requirementsData.Column) then
        DebugPrint("[TalentTree] Can't find column for requirement " .. tostring(id) .. ". Skipped.")
        return false
    end
    requirementsData.RequiredPoints = tonumber(requirementsData.RequiredPoints)
    if (not requirementsData.RequiredPoints) then
        DebugPrint("[TalentTree] Can't find required points for requirement " .. tostring(id) .. ". Skipped.")
        return false
    end
    return true
end

function TalentTree:IsValidTalent(talentId, talentData)
    if (not talentData) then
        return false
    end
    if (not talentData.Icon) then
        DebugPrint("[TalentTree] Can't find icon for talent " .. tostring(talentId) .. ". Skipped.")
        return false
    end
    if (not talentData.Modifier) then
        DebugPrint("[TalentTree] Can't find modifier for talent " .. tostring(talentId) .. ". Skipped.")
        return false
    end
    if (not talentData.MaxLevel) then
        DebugPrint("[TalentTree] Can't find max level for talent " .. tostring(talentId) .. ". Skipped.")
        return false
    end
    if (not talentData.Row) then
        DebugPrint("[TalentTree] Can't find row for talent " .. tostring(talentId) .. ". Skipped.")
        return false
    end
    if (talentData.Row < 1) then
        DebugPrint("[TalentTree] Row for talent " .. tostring(talentId) .. " must be greater than 0. Skipped.")
        return false
    end
    if (not talentData.Column) then
        DebugPrint("[TalentTree] Can't find column for talent " .. tostring(talentId) .. ". Skipped.")
        return false
    end
    if (talentData.Column < 1) then
        DebugPrint("[TalentTree] Column for talent " .. tostring(talentId) .. " must be greater than 0. Skipped.")
        return false
    end
    return true
end

function TalentTree:GetLatestTalentID()
    local id = -1
    for talentId, _ in pairs(TalentTree.talentsData) do
        local convertedId = tonumber(talentId)
        if (convertedId > id) then
            id = convertedId
        end
    end
    return id
end

function TalentTree:SetupForHero(hero)
    if (not hero) then
        return
    end
    hero.talents = {}
    hero.talents.level = {}
    hero.talents.modifiers = {}
    for i = 1, TalentTree:GetLatestTalentID() do
        hero.talents.level[i] = 0
    end
    hero.talents.currentPoints = 0
    TalentTree:AddTalentPointsToHero(hero, 90)
end

function TalentTree:GetHeroCurrentTalentPoints(hero)
    if (not hero or not hero.talents) then
        return 0
    end
    return hero.talents.currentPoints
end

function TalentTree:AddTalentPointsToHero(hero, points)
    if (not hero or not hero.talents) then
        return false
    end
    points = tonumber(points)
    if (not points) then
        return false
    end
    hero.talents.currentPoints = hero.talents.currentPoints + points
    local event = {
        PlayerID = hero:GetPlayerOwnerID()
    }
    TalentTree:OnTalentTreeStateRequest(event)
end

function TalentTree:IsHeroHaveTalentTree(hero)
    if (not hero) then
        return false
    end
    if (hero.talents) then
        return true
    end
    return false
end

function TalentTree:GetTalentRow(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].Row
    end
    return -1
end

function TalentTree:GetTalentColumn(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].Column
    end
    return -1
end

function TalentTree:GetTalentMaxLevel(talentId)
    if (TalentTree.talentsData[talentId]) then
        return TalentTree.talentsData[talentId].MaxLevel
    end
    return -1
end

function TalentTree:GetHeroTalentLevel(hero, talentId)
    if (TalentTree:IsHeroHaveTalentTree(hero) == true and talentId and talentId > 0) then
        return hero.talents.level[talentId]
    end
    return 0
end

function TalentTree:SetHeroTalentLevel(hero, talentId, level)
    level = tonumber(level)
    if (TalentTree:IsHeroHaveTalentTree(hero) == true and talentId > 0 and level and level > -1) then
        hero.talents.level[talentId] = level
        if (level == 0) then
            if (hero.talents.modifiers[talentId]) then
                hero.talents.modifiers[talentId]:Destroy()
                hero.talents.modifiers[talentId] = nil
            end
        else
            if (not hero.talents.modifiers[talentId]) then
                local modifierTable = {
                    ability = nil,
                    target = hero,
                    caster = hero,
                    modifier_name = TalentTree.talentsData[talentId].Modifier,
                    duration = -1
                }
                hero.talents.modifiers[talentId] = GameMode:ApplyBuff(modifierTable)
            end
            if (hero.talents.modifiers[talentId]) then
                hero.talents.modifiers[talentId]:SetStackCount(level)
            end
        end
        local event = {
            PlayerID = hero:GetPlayerOwnerID()
        }
        TalentTree:OnTalentTreeStateRequest(event)
    end
end

function TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, talentId)
    if (not TalentTree.talentsData[talentId]) then
        return false
    end
    local row = TalentTree:GetTalentRow(talentId)
    local column = TalentTree:GetTalentColumn(talentId)
    local totalRequiredPoints = 0
    for _, requirementsData in pairs(TalentTree.talentsRequirements) do
        if (requirementsData.Column == column and requirementsData.Row == row) then
            totalRequiredPoints = requirementsData.RequiredPoints
            break
        end
    end
    local pointsSpendedInColumn = 0
    for i = 1, TalentTree:GetLatestTalentID() do
        if (TalentTree:GetTalentColumn(i) == column and TalentTree:GetTalentRow(i) < row) then
            pointsSpendedInColumn = pointsSpendedInColumn + TalentTree:GetHeroTalentLevel(hero, i)
        end
    end
    if (pointsSpendedInColumn >= totalRequiredPoints) then
        return true
    end
    return false
end

function TalentTree:IsHeroCanLevelUpTalent(hero, talentId)
    if (not TalentTree.talentsData[talentId]) then
        return false
    end
    if (TalentTree:GetHeroTalentLevel(hero, talentId) >= TalentTree:GetTalentMaxLevel(talentId)) then
        return false
    end
    if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
        return false
    end
    return true
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

function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_talent_tree_get_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeTalentsRequest'))
    CustomGameEventManager:RegisterListener("rpg_talent_tree_level_up_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
    CustomGameEventManager:RegisterListener("rpg_talent_tree_get_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
    CustomGameEventManager:RegisterListener("rpg_talent_tree_reset_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeResetRequest'))
    CustomGameEventManager:RegisterListener("rpg_talent_tree_open_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_talent_tree_close_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowCloseRequest'))
end

function TalentTree:OnTalentTreeTalentsRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local currentTalent = 0
    local talentsData = {}
    local talentsCount = GetTableSize(TalentTree.talentsData)
    for talentId, talentData in pairs(TalentTree.talentsData) do
        if (currentTalent > TalentTree.maxTalentsPerRequest) then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talent_tree_get_talents_from_server", { talents = json.encode(talentsData), count = talentsCount })
            talentsData = {}
            currentTalent = 0
        end
        table.insert(talentsData, { id = talentId, data = talentData })
        currentTalent = currentTalent + 1
    end
    if (#talentsData > 0) then
        CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talent_tree_get_talents_from_server", { talents = json.encode(talentsData), count = talentsCount })
    end
end

function TalentTree:OnTalentTreeResetRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
        return
    end
    local pointsToReturn = 0
    for i = 1, TalentTree:GetLatestTalentID() do
        pointsToReturn = pointsToReturn + TalentTree:GetHeroTalentLevel(hero, i)
        TalentTree:SetHeroTalentLevel(hero, i, 0)
    end
    TalentTree:AddTalentPointsToHero(hero, pointsToReturn)
end

function TalentTree:OnTalentTreeLevelUpRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end
    local talentId = tonumber(event.id)
    if (not talentId or talentId < 1 or talentId > TalentTree:GetLatestTalentID()) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
        return
    end
    if (TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, talentId) and TalentTree:IsHeroCanLevelUpTalent(hero, talentId)) then
        local talentLvl = TalentTree:GetHeroTalentLevel(hero, talentId)
        TalentTree:AddTalentPointsToHero(hero, -1)
        TalentTree:SetHeroTalentLevel(hero, talentId, talentLvl + 1)
    end
end

function TalentTree:OnTalentTreeStateRequest(event)
    if (not IsServer()) then
        return
    end
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    Timers:CreateTimer(0,
            function()
                local hero = player:GetAssignedHero()
                if (hero == nil) then
                    return 1.0
                end
                if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
                    return 1.0
                end
                local resultTable = {}
                for i = 1, TalentTree:GetLatestTalentID() do
                    local talentLvl = TalentTree:GetHeroTalentLevel(hero, i)
                    local talentMaxLvl = TalentTree:GetTalentMaxLevel(i)
                    local isDisabled = (TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, i) == false) or TalentTree:IsHeroCanLevelUpTalent(hero, i) == false
                    if (talentLvl == talentMaxLvl) then
                        isDisabled = false
                    end
                    table.insert(resultTable, { id = i, disabled = isDisabled, level = talentLvl, maxlevel = talentMaxLvl })
                end
                if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
                    for _, talent in pairs(resultTable) do
                        if (TalentTree:GetHeroTalentLevel(hero, talent.talent_id) == 0) then
                            talent.disabled = true
                            talent.lvlup = false
                        end
                    end
                end
                CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talent_tree_get_state_from_server", { talents = json.encode(resultTable), points = TalentTree:GetHeroCurrentTalentPoints(hero) })
            end)
end

function TalentTree:OnTalentTreeWindowOpenRequest(event)
    if (event and event.PlayerID) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talent_tree_open_window_from_server", {})
        end
    end
end

function TalentTree:OnTalentTreeWindowCloseRequest(event)
    if (event and event.PlayerID) then
        local player = PlayerResource:GetPlayer(event.PlayerID)
        if player then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talent_tree_close_window_from_server", {})
        end
    end
end

if (IsServer() and not TalentTree.initialized) then
    TalentTree:Init()
end