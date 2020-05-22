if TalentTree == nil then
    _G.TalentTree = class({})
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:SetupForHero(hero)
    if (hero ~= nil) then
        hero.talents = {}
        hero.talents.level = {}
        hero.talents.modifiers = {}
        for i = 1, TalentTree.latest_talent_id do
            hero.talents.level[i] = 0
        end
        -- for test only, remove later pls
        hero:FindAbilityByName("antimage_blink"):SetLevel(4)
    end
end

-- for test only, remove later pls
if (IsServer()) then
    ListenToGameEvent("player_chat", function(event)
        if (event.text == "-reset") then
            PlayerResource:ReplaceHeroWith(event.playerid, "npc_dota_hero_drow_ranger", 0, 0)
            --[[
            local player = PlayerResource:GetPlayer(event.playerid)
            local hero = player:GetAssignedHero()
            TalentTree:Reset(hero) --]]
        end
    end, nil)
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:ChangeHeroAbilities(hero)
    if (hero ~= nil and hero.talents ~= nil) then
        local talentAbilties = {}
        for i = 19, 24 do
            if (hero.talents.level[i] > 0) then
                table.insert(talentAbilties, TalentTree:GetTalentAbilityName(hero, i))
            end
        end
        if (#talentAbilties > 2) then
            DebugPrint("[TALENTTREE] Abilties.count > 2. WTF?")
            DebugPrint("hero=" .. hero:GetUnitName())
            DebugPrintTable(talentAbilties)
            return
        end
        local freeIndex = -1
        for i = 1, 5 do
            local ability = hero:GetAbilityByIndex(i)
            local abilityName = ability:GetAbilityName()
            if (abilityName == TalentTree.tempAbilities[1] or abilityName == TalentTree.tempAbilities[2]) then
                freeIndex = i
                break
            end
        end
        if (freeIndex < 0) then
            return
        end
        for i = 1, #talentAbilties do
            if (talentAbilties[i] and not hero:HasAbility(talentAbilties[i])) then
                local tempAbilityName = hero:GetAbilityByIndex(freeIndex)
                if (tempAbilityName) then
                    tempAbilityName = tempAbilityName:GetAbilityName()
                    hero:RemoveAbility(tempAbilityName)
                    local ability = hero:AddAbility(talentAbilties[i])
                    ability:SetAbilityIndex(freeIndex)
                    freeIndex = freeIndex + 1
                end
            end
        end
    end
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:Reset(hero)
    if (hero and hero.talents) then
        TalentTree:RemoveAllTalentAbilities(hero)
        for talentId = 1, TalentTree.latest_talent_id do
            TalentTree:SetHeroTalentLevel(hero, talentId, 0)
        end
        local new_event = {
            player_id = hero:GetPlayerID()
        }
        TalentTree:OnTalentTreeStateRequest(new_event, nil)
    end
end

---@param hero CDOTA_BaseNPC_Hero
function TalentTree:RemoveAllTalentAbilities(hero)
    if (hero ~= nil and hero.talents ~= nil) then
        hero:RemoveAbility(TalentTree.tempAbilities[1])
        hero:RemoveAbility(TalentTree.tempAbilities[2])
        for i = 19, 24 do
            local name = TalentTree:GetTalentAbilityName(hero, i)
            local ability = hero:FindAbilityByName(name)
            if (ability) then
                hero:SetAbilityPoints(hero:GetAbilityPoints() + ability:GetLevel())
                hero:RemoveAbility(name)
            end
        end
        hero:AddAbility(TalentTree.tempAbilities[1])
        hero:AddAbility(TalentTree.tempAbilities[2])
        -- for test only, remove later pls
        hero:FindAbilityByName("antimage_blink"):SetLevel(4)
    end
end

function TalentTree:Init()
    -- Changing that require modifying all Get() functions  and IsRequiredPointsForLineConditionMeet() below...
    self.latest_talent_id = 51
    self.max_talent_points = 32
    self.tempAbilities = { "empty5", "antimage_blink" }
    self.talent_abilities = {
        ["npc_dota_hero_drow_ranger"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_juggernaut"] = {
            "luminous_samurai_blade_dance",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_phantom_assassin"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_abyssal_underlord"] = {
            "terror_lord_flame_of_menace",
            "terror_lord_immolation",
            "terror_lord_inferno_impulse",
            "terror_lord_ruthless_predator",
            "terror_lord_pit_of_seals",
            "terror_lord_aura_of_seals"
        },
        ["npc_dota_hero_mars"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_axe"] = {
            "blazing_berserker_rage_eruption",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_crystal_maiden"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_invoker"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_silencer"] = {
            "light_cardinal_spirit_shield",
            "light_cardinal_harmony",
            "light_cardinal_desecration",
            "light_cardinal_consecration",
            "light_cardinal_smite",
            "light_cardinal_patronage"
        },
        ["npc_dota_hero_enchantress"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_doom_bringer"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        },
        ["npc_dota_hero_dark_willow"] = {
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator",
            "terror_lord_ruthless_predator"
        }
    }
    TalentTree:InitPanaromaEvents()
end


-- internal stuff to make all work
---@param hero CDOTA_BaseNPC_Hero
---@return number
function TalentTree:GetHeroMaxTalentPoints(hero)
    if (hero ~= nil) then
        return TalentTree.max_talent_points
    end
    return 0
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
    if (event == nil) then
        return
    end
    event.player_id = tonumber(event.player_id)
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
    local IsPointsRequirmentPassed = true
    if (desiredTalentLine > 1) then
        IsPointsRequirmentPassed = TalentTree:IsRequiredPointsForLineAndBranchConditionMeet(hero, desiredTalentLine, desiredTalentBranch)
    end
    if (not IsPointsRequirmentPassed) then
        return
    end
    local maxLevelOfTalent = TalentTree:GetMaxLevelForTalent(event.talent_id)
    local heroLevelOfTalent = TalentTree:GetHeroTalentLevel(hero, event.talent_id)
    local IsHeroHaveEnoughTalentPoints = (TalentTree:GetHeroCurrentTalentPoints(hero) >= 1)
    local totalPointsSpendedInLine = TalentTree:GetPointsSpendedInLine(hero, desiredTalentLine)
    local IsMaximumPointsSpendedForLine = (totalPointsSpendedInLine >= TalentTree:GetMaxPointsForLine(desiredTalentLine))
    local totalPointsSpendedInLineForBranch = TalentTree:GetPointsSpendedInLineForBranch(hero, desiredTalentLine, desiredTalentBranch)
    local IsMaximumPointsSpendedForLineInBranch = (totalPointsSpendedInLineForBranch >= TalentTree:GetMaxPointsForLineInBranch(desiredTalentLine, desiredTalentBranch))
    local IsHeroCanLevelUpTalent = (heroLevelOfTalent < maxLevelOfTalent) and IsHeroHaveEnoughTalentPoints and not IsMaximumPointsSpendedForLine and not IsMaximumPointsSpendedForLineInBranch
    if (IsHeroCanLevelUpTalent) then
        TalentTree:SetHeroTalentLevel(hero, event.talent_id, heroLevelOfTalent + 1)
        local new_event = {
            player_id = event.player_id
        }
        TalentTree:OnTalentTreeStateRequest(new_event, nil)
    end
end

---@param talentId number
---@return boolean
function TalentTree:IsTalentIdValid(talentId)
    if (talentId > 0 and talentId <= TalentTree.latest_talent_id) then
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
                    local modifier_name = "modifier"
                    if (TalentTree:IsUniversalTalent(talentId)) then
                        modifier_name = modifier_name .. "_generic_"
                    else
                        local heroName = hero:GetUnitName()
                        modifier_name = modifier_name .. "_" .. heroName .. "_"
                    end
                    modifier_name = modifier_name .. "talent_" .. tostring(talentId)
                    local modifierTable = {}
                    modifierTable.ability = nil
                    modifierTable.target = hero
                    modifierTable.caster = hero
                    modifierTable.modifier_name = modifier_name
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
        for i = 1, TalentTree.latest_talent_id do
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
    if (talentId ~= nil) then
        -- line1
        if (talentId >= 1 and talentId <= 3) then
            return 1
        end
        if (talentId > 3 and talentId <= 6) then
            return 2
        end
        if (talentId > 6 and talentId <= 9) then
            return 3
        end
        -- line2
        if (talentId > 9 and talentId <= 12) then
            return 1
        end
        if (talentId > 12 and talentId <= 15) then
            return 2
        end
        if (talentId > 15 and talentId <= 18) then
            return 3
        end
        -- line3
        if (talentId > 18 and talentId <= 20) then
            return 1
        end
        if (talentId > 20 and talentId <= 22) then
            return 2
        end
        if (talentId > 22 and talentId <= 24) then
            return 3
        end
        -- line4
        if (talentId > 24 and talentId <= 27) then
            return 1
        end
        if (talentId > 27 and talentId <= 30) then
            return 2
        end
        if (talentId > 30 and talentId <= 33) then
            return 3
        end
        -- line5
        if (talentId > 33 and talentId <= 35) then
            return 1
        end
        if (talentId > 35 and talentId <= 37) then
            return 2
        end
        if (talentId > 37 and talentId <= 39) then
            return 3
        end
        -- line6
        if (talentId > 39 and talentId <= 41) then
            return 1
        end
        if (talentId > 41 and talentId <= 43) then
            return 2
        end
        if (talentId > 43 and talentId <= 45) then
            return 3
        end
        -- line7
        if (talentId > 45 and talentId <= 47) then
            return 1
        end
        if (talentId > 47 and talentId <= 49) then
            return 2
        end
        if (talentId > 49 and talentId <= 51) then
            return 3
        end
    end
    return 0
end

---@param talentId number
---@return number
function TalentTree:GetTalentLine(talentId)
    talentId = tonumber(talentId)
    if (talentId ~= nil) then
        if (talentId >= 1 and talentId <= 9) then
            return 1
        end
        if (talentId > 9 and talentId <= 18) then
            return 2
        end
        if (talentId > 18 and talentId <= 24) then
            return 3
        end
        if (talentId > 24 and talentId <= 33) then
            return 4
        end
        if (talentId > 33 and talentId <= 39) then
            return 5
        end
        if (talentId > 39 and talentId <= 45) then
            return 6
        end
        if (talentId > 45 and talentId <= 51) then
            return 7
        end
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
    if (hero and line and line >= 1 and line <= 7 and branch) then
        if (line >= 4) then
            local pointsInAbilityLine = TalentTree:GetPointsSpendedInLineForBranch(hero, 3, branch)
            local totalPointsSpended = TalentTree:GetPointsSpendedInLinesIncludeThisForBranch(hero, line, branch) - pointsInAbilityLine
            totalPointsSpended = totalPointsSpended + TalentTree:GetPointsSpendedInLine(hero, 3)
            return totalPointsSpended >= (((line - 1) * 3) - 1)
        else
            return TalentTree:GetPointsSpendedInLinesIncludeThisForBranch(hero, line, branch) >= ((line - 1) * 3)
        end
    end
    return false
end

---@param talentId number
---@return number
function TalentTree:GetMaxPointsForLineInBranch(line, branch)
    line = tonumber(line)
    branch = tonumber(branch)
    if (line and branch) then
        if (line == 7) then
            return 1
        end
        return 99999
    end
    return 0
end

---@param talentId number
---@return number
function TalentTree:GetMaxPointsForLine(line)
    line = tonumber(line)
    if (line) then
        if (line == 3) then
            return 2
        end
        return 99999
    end
    return 0
end

---@param talentId number
---@return number
function TalentTree:GetMaxLevelForTalent(talentId)
    talentId = tonumber(talentId)
    if (talentId ~= nil) then
        if (talentId > 18 and talentId <= 24) then
            return 1
        end
        if (talentId > 45 and talentId <= 51) then
            return 1
        end
        return 3
    end
    return 0
end

---@param hero CDOTA_BaseNPC_Hero
---@param talentId number
---@return string
function TalentTree:GetTalentAbilityName(hero, talentId)
    local talentId = tonumber(talentId)
    if (hero ~= nil and talentId ~= nil) then
        if (talentId >= 19 and talentId <= 24) then
            local heroName = hero:GetUnitName()
            return self.talent_abilities[heroName][talentId - 18] or ""
        end
    end
    return ""
end

---@param talentId number
---@return boolean
function TalentTree:IsUniversalTalent(talentId)
    local talentId = tonumber(talentId)
    if (talentId == nil) then
        return false
    end
    if (talentId >= 25 and talentId <= 33) then
        return true
    end
    if (talentId >= 1 and talentId <= 18) then
        return true
    end
    return false
end

-- Panaroma stuff
function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("rpg_talenttree_open_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowOpenRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_close_window", Dynamic_Wrap(TalentTree, 'OnTalentTreeWindowCloseRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_lvlup_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
    CustomGameEventManager:RegisterListener("rpg_talenttree_require_player_talents_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
end

function TalentTree:OnTalentTreeStateRequest(event, args)
    if (event == nil) then
        return
    end
    event.player_id = tonumber(event.player_id)
    if (event.player_id == nil) then
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
                for i = 1, TalentTree.latest_talent_id do
                    local talentLvl = TalentTree:GetHeroTalentLevel(hero, i)
                    local talentMaxLvl = TalentTree:GetMaxLevelForTalent(i)
                    local talentLine = TalentTree:GetTalentLine(i)
                    local talentBranch = TalentTree:GetTalentBranch(i)
                    local IsRequiredPointsForLineAndBranchConditionMeet = TalentTree:IsRequiredPointsForLineAndBranchConditionMeet(hero, talentLine, talentBranch)
                    local totalPointsSpendedInLine = TalentTree:GetPointsSpendedInLine(hero, talentLine)
                    local IsMaximumPointsSpendedForLine = (totalPointsSpendedInLine >= TalentTree:GetMaxPointsForLine(talentLine))
                    local totalPointsSpendedInLineForBranch = TalentTree:GetPointsSpendedInLineForBranch(hero, talentLine, talentBranch)
                    local IsMaximumPointsSpendedForLineInBranch = (totalPointsSpendedInLineForBranch >= TalentTree:GetMaxPointsForLineInBranch(talentLine, talentBranch))
                    local IsTalentMissLevels = (talentLvl < talentMaxLvl) and IsRequiredPointsForLineAndBranchConditionMeet and not IsMaximumPointsSpendedForLine and not IsMaximumPointsSpendedForLineInBranch
                    table.insert(resultTable, { talent_id = i, disabled = (not IsRequiredPointsForLineAndBranchConditionMeet), lvlup = IsTalentMissLevels, level = talentLvl, maxlevel = talentMaxLvl, abilityname = TalentTree:GetTalentAbilityName(hero, i) })
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
                TalentTree:ChangeHeroAbilities(hero)
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

function TalentTree:OnTalentTreeWindowOpenRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_open_window_from_server", {})
        end
    end
end

function TalentTree:OnTalentTreeWindowCloseRequest(event, args)
    if (event ~= nil and event.player_id ~= nil) then
        local player = PlayerResource:GetPlayer(event.player_id)
        if player ~= nil then
            CustomGameEventManager:Send_ServerToPlayer(player, "rpg_talenttree_close_window_from_server", {})
        end
    end
end

if IsServer() and not TalentTree.initialized then
    TalentTree:Init()
    TalentTree.initialized = true
end