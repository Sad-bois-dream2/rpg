if (IsServer()) then
    ---@param handler function
    function GameMode:RegisterCritDamageEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterCritDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterCritDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.CritDamageEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPreDamageEventHandler(handler, calculateBeforeResistances)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPreDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPreDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (calculateBeforeResistances == true) then
            table.insert(GameMode.PreDamageBeforeResistancesEventHandlersTable, handler)
        else
            table.insert(GameMode.PreDamageAfterResistancesEventHandlersTable, handler)
        end
    end

    ---@param handler function
    function GameMode:RegisterPostDamageEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPostDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPostDamageEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PostDamageEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPostApplyModifierEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPostApplyModifierEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPostApplyModifierEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PostApplyModifierEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPreHealEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPreHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPreHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PreHealEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPostHealEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPostHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPostHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PostHealEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterCritHealEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterCritHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterCritHealEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.CritHealEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPreHealManaEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPreHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPreHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PreHealManaEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterPostHealManaEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterPostHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterPostHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.PostHealManaEventHandlersTable, handler)
    end

    ---@param handler function
    function GameMode:RegisterCritHealManaEventHandler(handler)
        if (handler == nil) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to RegisterCritHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(handler) ~= "function") then
            DebugPrint("[GAME MECHANICS] Someone passed " .. tostring(handler) .. " instead of function to RegisterCritHealManaEventHandler()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        table.insert(GameMode.CritHealManaEventHandlersTable, handler)
    end

    ---@param abilityName string
    ---@param minCooldown number
    function GameMode:RegisterMinimumAbilityCooldown(abilityName, minCooldown)
        if (not abilityName or not minCooldown) then
            DebugPrint("[GAME MECHANICS] Someone passed nil to of arguments of RegisterMinimumAbilityCooldown()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(abilityName) ~= "string") then
            DebugPrint("[GAME MECHANICS] abilityName must be string in RegisterMinimumAbilityCooldown()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        if (type(minCooldown) ~= "number") then
            DebugPrint("[GAME MECHANICS] abilityName must be number in RegisterMinimumAbilityCooldown()")
            DebugPrint("[GAME MECHANICS] Source of that shit:")
            DebugPrintTable(debug.getinfo(2))
            return
        end
        GameMode.MinimumAbilitiesCooldownTable[abilityName] = minCooldown
    end

    --- handle every dmg instance in game. true = allow damage event, false = cancel damage event (damage itself, numbers still showed on client side)
    function GameMode:DamageFilter(args)
        if not IsServer() then
            return false
        end
        local attacker
        local victim
        if args.entindex_attacker_const and args.entindex_victim_const then
            attacker = EntIndexToHScript(args.entindex_attacker_const)
            victim = EntIndexToHScript(args.entindex_victim_const)
        else
            -- some weird shit happened, cancel that
            return false
        end
        if (args.damagetype_const ~= DAMAGE_TYPE_PURE) then
            -- creep aa or hero aa or another weird shit, cancel that
            -- creeps & heroes deal aa dmg via corresponding modifier
            return false
        end
        -- another weird shit happened, ignore that
        if not attacker or not victim then
            return false
        end
        --[[local ability
        if args.entindex_inflictor_const then
            ability = EntIndexToHScript(args.entindex_inflictor_const)
        end --]]
        return true
    end

    ---@class MODIFIER_TABLE
    ---@field public caster CDOTA_BaseNPC
    ---@field public target CDOTA_BaseNPC
    ---@field public ability CDOTA_Ability_Lua
    ---@field public modifier_name string
    ---@field public modifier_params table
    ---@field public duration number

    ---@class STACKING_MODIFIER_TABLE
    ---@field public caster CDOTA_BaseNPC
    ---@field public target CDOTA_BaseNPC
    ---@field public ability CDOTA_Ability_Lua
    ---@field public modifier_name string
    ---@field public modifier_params table
    ---@field public duration number
    ---@field public stacks number
    ---@field public max_stacks number
    ---
    --- Apply (or refresh if exists) buff
    ---@param args MODIFIER_TABLE
    ---@param fireEvent boolean
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyBuff(args, fireEvent)
        if (args ~= nil) then
            args.duration = tonumber(args.duration)
            if (args.caster ~= nil and args.target ~= nil and args.modifier_name ~= nil and args.duration ~= nil) then
                local modifierParams = args.modifier_params or {}
                if (args.duration > 0) then
                    args.duration = args.duration * Units:GetStatusAmplification(args.caster)
                end
                modifierParams.Duration = args.duration
                local modifier = args.target:AddNewModifier(args.caster, args.ability, args.modifier_name, modifierParams)
                if (fireEvent == nil) then
                    fireEvent = true
                end
                if (modifier ~= nil) then
                    GameMode:OverwriteModifierFunctions(modifier)
                    if (not modifier.IsHidden) then
                        modifier.IsHidden = function(self)
                            return false
                        end
                    end
                    if (not modifier.IsDebuff) then
                        modifier.IsDebuff = function(self)
                            return false
                        end
                    end
                    if (fireEvent == true) then
                        args.stacks = 0
                        args.max_stacks = 0
                        for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                            GameMode.PostApplyModifierEventHandlersTable[i](modifier, args)
                        end
                    end
                end
                return modifier
            end
        end
        return nil
    end

    --- Apply (or refresh if exists) buff + increase his stacks count by args.stacks up to args.max_stacks
    ---@param args STACKING_MODIFIER_TABLE
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyStackingBuff(args)
        if (args ~= nil and args.stacks ~= nil and args.max_stacks ~= nil and args.stacks > 0 and args.max_stacks > 0) then
            local modifier = GameMode:ApplyBuff(args, false)
            if (modifier ~= nil) then
                local stacks = modifier:GetStackCount() + args.stacks
                modifier:SetStackCount(math.min(stacks, args.max_stacks))
                for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                    GameMode.PostApplyModifierEventHandlersTable[i](modifier, args)
                end
                return modifier
            end
        end
        return nil
    end

    --- Apply (or refresh if exists) npc based buff
    ---@param args MODIFIER_TABLE
    ---@param fireEvent boolean
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyNPCBasedBuff(args)
        if (not args or not args.caster or not args.modifier_name or not args.target) then
            return nil
        end
        local findedModifier = args.target:FindModifierByNameAndCaster(args.modifier_name, args.caster)
        if (findedModifier) then
            findedModifier:ForceRefresh()
        else
            return GameMode:ApplyBuff(args)
        end
        return nil
    end

    --- Apply (or refresh if exists) npc based buff + increase his stacks count by args.stacks up to args.max_stacks
    ---@param args STACKING_MODIFIER_TABLE
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyNPCBasedStackingBuff(args)
        if (not args or not args.caster or not args.modifier_name or not args.target) then
            return nil
        end
        args.stacks = tonumber(args.stacks)
        args.max_stacks = tonumber(args.max_stacks)
        if (not args.stacks or not args.max_stacks) then
            return nil
        end
        local findedModifier = args.target:FindModifierByNameAndCaster(args.modifier_name, args.caster)
        if (findedModifier) then
            local stacks = findedModifier:GetStackCount() + args.stacks
            findedModifier:SetStackCount(math.min(stacks, args.max_stacks))
            findedModifier:ForceRefresh()
            for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                GameMode.PostApplyModifierEventHandlersTable[i](findedModifier, args)
            end
            return findedModifier
        else
            return GameMode:ApplyStackingBuff(args)
        end
        return nil
    end

    --- Apply (or refresh if exists) debuff
    ---@param args MODIFIER_TABLE
    ---@param fireEvent boolean
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyDebuff(args, fireEvent)
        if (args ~= nil) then
            args.duration = tonumber(args.duration)
            if (args.caster ~= nil and args.target ~= nil and args.modifier_name ~= nil and args.duration ~= nil) then
                local modifierParams = args.modifier_params or {}
                if (args.duration > 0) then
                    args.duration = args.duration * Units:GetStatusAmplification(args.caster) * Units:GetStatusResistance(args.target)
                end
                modifierParams.Duration = args.duration
                local isTargetCasting = false
                local abilitiesCount = args.target:GetAbilityCount() - 1
                local ability = nil
                for i = 0, abilitiesCount do
                    ability = args.target:GetAbilityByIndex(i)
                    if (ability and ability:IsInAbilityPhase()) then
                        isTargetCasting = true
                        break
                    end
                end
                local isStun = false
                local isRoot = false
                local isHex = false
                local isSilence = false
                local crowdControlModifier = GameMode.CrowdControlModifiersTable[args.modifier_name]
                local isModifierWillPreventCasting = false
                if (crowdControlModifier) then
                    isStun = (crowdControlModifier.stun == true)
                    isRoot = (crowdControlModifier.root == true)
                    isHex = (crowdControlModifier.hex == true)
                    isSilence = (crowdControlModifier.silence == true)
                else
                    if (args.modifier_name == "modifier_stunned") then
                        isStun = true
                    end
                    if (args.modifier_name == "modifier_silence") then
                        isSilence = true
                    end
                end
                isModifierWillPreventCasting = (isStun == true) or (isHex == true) or (isSilence == true)
                local isUnitHaveImmuneToStun = false
                local isUnitHaveImmuneToRoot = false
                local isUnitHaveImmuneToHex = false
                local isUnitHaveImmuneToSilence = false
                local unitModifiers = args.target:FindAllModifiers()
                for i = 1, #unitModifiers do
                    if (unitModifiers[i].GetImmunityToStun and isUnitHaveImmuneToStun == false) then
                        isUnitHaveImmuneToStun = unitModifiers[i].GetImmunityToStun(unitModifiers[i]) or false
                    end
                    if (unitModifiers[i].GetImmunityToRoot and isUnitHaveImmuneToRoot == false) then
                        isUnitHaveImmuneToRoot = unitModifiers[i].GetImmunityToRoot(unitModifiers[i]) or false
                    end
                    if (unitModifiers[i].GetImmunityToSilence and isUnitHaveImmuneToSilence == false) then
                        isUnitHaveImmuneToSilence = unitModifiers[i].GetImmunityToSilence(unitModifiers[i]) or false
                    end
                    if (unitModifiers[i].GetImmunityToHex and isUnitHaveImmuneToHex == false) then
                        isUnitHaveImmuneToHex = unitModifiers[i].GetImmunityToHex(unitModifiers[i]) or false
                    end
                end
                if (isStun == true and isUnitHaveImmuneToStun == true) then
                    return nil
                end
                if (isRoot == true and isUnitHaveImmuneToRoot == true) then
                    return nil
                end
                if (isHex == true and isUnitHaveImmuneToHex == true) then
                    return nil
                end
                if (isSilence == true and isUnitHaveImmuneToSilence == true) then
                    return nil
                end
                if (isTargetCasting == true and isModifierWillPreventCasting == true and ability.IsInterruptible and ability:IsInterruptible() == false) then
                    return nil
                end
                local modifier = args.target:AddNewModifier(args.caster, args.ability, args.modifier_name, modifierParams)
                if (fireEvent == nil) then
                    fireEvent = true
                end
                if (modifier ~= nil) then
                    GameMode:OverwriteModifierFunctions(modifier)
                    if (not modifier.IsHidden) then
                        modifier.IsHidden = function(self)
                            return false
                        end
                    end
                    if (not modifier.IsDebuff) then
                        modifier.IsDebuff = function(self)
                            return true
                        end
                    end
                    local modifierStateTable = {}
                    if (isStun == true) then
                        modifierStateTable[MODIFIER_STATE_STUNNED] = true
                    end
                    if (isHex == true) then
                        modifierStateTable[MODIFIER_STATE_HEXED] = true
                    end
                    if (isSilence == true) then
                        modifierStateTable[MODIFIER_STATE_SILENCED] = true
                    end
                    if (isRoot == true) then
                        modifierStateTable[MODIFIER_STATE_ROOTED] = true
                    end
                    if (not modifier.CheckState) then
                        modifier.CheckState = function(self)
                            return modifierStateTable
                        end
                    end
                    if (fireEvent == true) then
                        args.stacks = 0
                        args.max_stacks = 0
                        for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                            GameMode.PostApplyModifierEventHandlersTable[i](modifier, args)
                        end
                    end
                end
                return modifier
            end
        end
        return nil
    end

    --- Apply (or refresh if exists) debuff + increase his stacks count by args.stacks up to args.max_stacks
    ---@param args STACKING_MODIFIER_TABLE
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyStackingDebuff(args)
        if (args ~= nil and args.stacks ~= nil and args.max_stacks ~= nil and args.stacks > 0 and args.max_stacks > 0) then
            local modifier = GameMode:ApplyDebuff(args, false)
            if (modifier ~= nil) then
                local stacks = modifier:GetStackCount() + args.stacks
                modifier:SetStackCount(math.min(stacks, args.max_stacks))
                for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                    GameMode.PostApplyModifierEventHandlersTable[i](modifier, args)
                end
                return modifier
            end
        end
        return nil
    end

    --- Apply (or refresh if exists) npc based debuff
    ---@param args MODIFIER_TABLE
    ---@param fireEvent boolean
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyNPCBasedDebuff(args)
        if (not args or not args.caster or not args.modifier_name or not args.target) then
            return nil
        end
        local findedModifier = args.target:FindModifierByNameAndCaster(args.modifier_name, args.caster)
        if (findedModifier) then
            findedModifier:ForceRefresh()
        else
            return GameMode:ApplyDebuff(args)
        end
        return nil
    end

    --- Apply (or refresh if exists) npc based debuff + increase his stacks count by args.stacks up to args.max_stacks
    ---@param args STACKING_MODIFIER_TABLE
    ---@return CDOTA_Modifier_Lua
    function GameMode:ApplyNPCBasedStackingDebuff(args)
        if (not args or not args.caster or not args.modifier_name or not args.target) then
            return nil
        end
        args.stacks = tonumber(args.stacks)
        args.max_stacks = tonumber(args.max_stacks)
        if (not args.stacks or not args.max_stacks) then
            return nil
        end
        local findedModifier = args.target:FindModifierByNameAndCaster(args.modifier_name, args.caster)
        if (findedModifier) then
            local stacks = findedModifier:GetStackCount() + args.stacks
            findedModifier:SetStackCount(math.min(stacks, args.max_stacks))
            findedModifier:ForceRefresh()
            for i = 1, #GameMode.PostApplyModifierEventHandlersTable do
                GameMode.PostApplyModifierEventHandlersTable[i](findedModifier, args)
            end
            return findedModifier
        else
            return GameMode:ApplyStackingDebuff(args)
        end
        return nil
    end

    function GameMode:HasNPCBasedModifier(modifier, caster)
        if (not modifier or not caster or not self.HasNPCBasedModifier) then
            return false
        end
        local findedModifier = self:FindModifierByNameAndCaster(modifier, caster)
        if (findedModifier) then
            return true
        end
        return false
    end

    ---@class REDUCE_ABILITY_CD_TABLE
    ---@field public target CDOTA_BaseNPC
    ---@field public ability CDOTA_Ability_Lua
    ---@field public reduction number
    ---@field public isflat boolean

    --- Reduce any ability cooldown by args.reduction. If args.isflat = true then cooldown = cooldown - reduction else cooldown = cooldown * reduction
    ---@param args REDUCE_ABILITY_CD_TABLE
    function GameMode:ReduceAbilityCooldown(args)
        local target = args.target
        local ability = args.ability
        local reduction = args.reduction
        if (not reduction) then
            if (args.isflat) then
                reduction = 0
            else
                reduction = 1
            end
        end
        if (target ~= nil and ability ~= nil) then
            ability = target:FindAbilityByName(ability)
            if (ability ~= nil) then
                local abilityLevel = ability:GetLevel()
                if (abilityLevel > 0) then
                    local abilityCooldown = ability:GetCooldownTimeRemaining()
                    local reducedCooldown = abilityCooldown
                    if (args.isflat == true) then
                        reducedCooldown = math.max(0, reducedCooldown - reduction)
                    else
                        reducedCooldown = reducedCooldown * reduction
                    end
                    if (GameMode.MinimumAbilitiesCooldownTable[args.ability]) then
                        reducedCooldown = math.max(GameMode.MinimumAbilitiesCooldownTable[args.ability], reducedCooldown)
                    end
                    if (reducedCooldown < 0 or reducedCooldown > abilityCooldown) then
                        return
                    end
                    ability:EndCooldown()
                    ability:StartCooldown(reducedCooldown)
                end
            end
        end
    end

    ---@class DAMAGE_TABLE
    ---@field public caster CDOTA_BaseNPC
    ---@field public target CDOTA_BaseNPC
    ---@field public damage number
    ---@field public ability CDOTA_Ability_Lua
    ---@field public physdmg boolean
    ---@field public puredmg boolean
    ---@field public firedmg boolean
    ---@field public frostdmg boolean
    ---@field public earthdmg boolean
    ---@field public naturedmg boolean
    ---@field public voiddmg boolean
    ---@field public infernodmg boolean
    ---@field public holydmg boolean
    ---@field public fromsummon boolean
    ---@field public single boolean
    ---@field public dot boolean
    ---@field public aoe boolean
    ---
    ---@param args DAMAGE_TABLE
    function GameMode:DamageUnit(args)
        if (not args) then
            return
        end
        if (args.caster == nil or args.target == nil or args.damage == nil) then
            return
        end
        local damageTable = {
            victim = args.target,
            attacker = args.caster,
            damage = args.damage,
            damage_type = DAMAGE_TYPE_PURE,
            ability = args.ability,
            physdmg = args.physdmg,
            firedmg = args.firedmg,
            frostdmg = args.frostdmg,
            earthdmg = args.earthdmg,
            naturedmg = args.naturedmg,
            voiddmg = args.voiddmg,
            infernodmg = args.infernodmg,
            holydmg = args.holydmg,
            puredmg = args.puredmg,
            fromsummon = args.fromsummon,
            fromtalent = args.fromtalent,
            dot = args.dot,
            single = args.single,
            aoe = args.aoe,
            crit = 1.0
        }
        local damageCanceled = false
        local preDamageBeforeResistancesHandlerResultTable
        for i = 1, #GameMode.PreDamageBeforeResistancesEventHandlersTable do
            if (not damageTable.victim or damageTable.victim:IsNull() or not damageTable.victim:IsAlive() or not damageTable.attacker or damageTable.attacker:IsNull() or not damageTable.attacker:IsAlive()) then
                break
            end
            preDamageBeforeResistancesHandlerResultTable = GameMode.PreDamageBeforeResistancesEventHandlersTable[i](nil, damageTable)
            if (preDamageBeforeResistancesHandlerResultTable ~= nil) then
                if (not damageCanceled) then
                    damageCanceled = (preDamageBeforeResistancesHandlerResultTable.damage <= 0)
                end
                local latestCrit = damageTable.crit
                damageTable = preDamageBeforeResistancesHandlerResultTable
                if (latestCrit > damageTable.crit) then
                    damageTable.crit = latestCrit
                end
            end
        end
        if (damageCanceled == true) then
            return
        end
        -- perform all reductions/amplifications, should work fine unless unit recieved really hard mixed dmg instance with all types and have every block like 99%
        local totalReduction = 1
        local IsPureDamage = (damageTable.puredmg == true)
        local IsPhysicalDamage = (damageTable.physdmg == true)
        local IsFireDamage = (damageTable.firedmg == true)
        local IsFrostDamage = (damageTable.frostdmg == true)
        local IsEarthDamage = (damageTable.earthdmg == true)
        local IsNatureDamage = (damageTable.naturedmg == true)
        local IsVoidDamage = (damageTable.voiddmg == true)
        local IsInfernoDamage = (damageTable.infernodmg == true)
        local IsHolyDamage = (damageTable.holydmg == true)
        if (IsPureDamage == false) then
            local typesCount = 0
            local elementalReduction = 0
            if (IsPhysicalDamage == true) then
                -- armor formula gl hf, 999999999 armor = 100% phys resistance, 2000 armor = 99,1% phys resistance
                local targetArmor = Units:GetArmor(damageTable.victim)
                local physReduction
                if targetArmor >= 0 then
                    physReduction = (targetArmor * 0.06) / (1 + targetArmor * 0.06)
                else
                    physReduction = -1 + math.pow(0.94, targetArmor * -1)
                end
                physReduction = 1 - physReduction
                typesCount = typesCount + 1
                elementalReduction = elementalReduction + physReduction
            end
            if (IsFireDamage == true) then
                elementalReduction = elementalReduction + Units:GetFireProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsFrostDamage == true) then
                elementalReduction = elementalReduction + Units:GetFrostProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsEarthDamage == true) then
                elementalReduction = elementalReduction + Units:GetEarthProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsNatureDamage == true) then
                elementalReduction = elementalReduction + Units:GetNatureProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsVoidDamage == true) then
                elementalReduction = elementalReduction + Units:GetVoidProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsInfernoDamage == true) then
                elementalReduction = elementalReduction + Units:GetInfernoProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (IsHolyDamage == true) then
                elementalReduction = elementalReduction + Units:GetHolyProtection(damageTable.victim)
                typesCount = typesCount + 1
            end
            if (typesCount == 0) then
                elementalReduction = 1
            else
                elementalReduction = elementalReduction / typesCount
            end
            totalReduction = elementalReduction
        end
        local totalAmplification = 1
        if (IsFireDamage == true) then
            totalAmplification = totalAmplification + Units:GetFireDamage(damageTable.attacker) - 1
        end
        if (IsFrostDamage == true) then
            totalAmplification = totalAmplification + Units:GetFrostDamage(damageTable.attacker) - 1
        end
        if (IsEarthDamage == true) then
            totalAmplification = totalAmplification + Units:GetEarthDamage(damageTable.attacker) - 1
        end
        if (IsNatureDamage == true) then
            totalAmplification = totalAmplification + Units:GetNatureDamage(damageTable.attacker) - 1
        end
        if (IsVoidDamage == true) then
            totalAmplification = totalAmplification + Units:GetVoidDamage(damageTable.attacker) - 1
        end
        if (IsInfernoDamage == true) then
            totalAmplification = totalAmplification + Units:GetInfernoDamage(damageTable.attacker) - 1
        end
        if (IsHolyDamage == true) then
            totalAmplification = totalAmplification + Units:GetHolyDamage(damageTable.attacker) - 1
        end
        if (args.fromsummon == true) then
            totalAmplification = totalAmplification + Units:GetSummonDamage(damageTable.attacker) - 1
        end
        if (args.dot == true) then
            totalAmplification = totalAmplification + Units:GetDOTDamage(damageTable.attacker) - 1
        end
        if (args.single == true) then
            totalAmplification = totalAmplification + Units:GetSingleDamage(damageTable.attacker) - 1
        end
        if (args.aoe == true) then
            totalAmplification = totalAmplification + Units:GetAOEDamage(damageTable.attacker) - 1
        end
        if (args.ability or args.fromtalent) then
            totalAmplification = totalAmplification + Units:GetSpellDamage(damageTable.attacker, args.ability) - 1
        end
        local unitAdditionalConditionalDamage = 0
        local unitModifiers = damageTable.victim:FindAllModifiers()
        for i = 1, #unitModifiers do
            if (unitModifiers[i].GetAdditionalConditionalDamage) then
                unitAdditionalConditionalDamage = unitAdditionalConditionalDamage + tonumber(unitModifiers[i].GetAdditionalConditionalDamage(unitModifiers[i], damageTable) or 0)
            end
        end
        local unitModifiers = damageTable.attacker:FindAllModifiers()
        for i = 1, #unitModifiers do
            if (unitModifiers[i].GetAdditionalConditionalDamage) then
                unitAdditionalConditionalDamage = unitAdditionalConditionalDamage + tonumber(unitModifiers[i].GetAdditionalConditionalDamage(unitModifiers[i], damageTable) or 0)
            end
        end
        totalAmplification = totalAmplification + unitAdditionalConditionalDamage
        -- Damage reduction reduce even pure dmg
        totalReduction = totalReduction * Units:GetDamageReduction(damageTable.victim)
        -- final damage
        damageTable.damage = damageTable.damage * totalReduction
        -- dont trigger pre/post damage event if damage = 0 and dont apply "0" damage instances
        if (damageTable.damage > 0) then
            -- trigger pre/post dmg event for all skills/etc
            local preDamageHandlerResultTable
            for i = 1, #GameMode.PreDamageAfterResistancesEventHandlersTable do
                if (not damageTable.victim or damageTable.victim:IsNull() or not damageTable.victim:IsAlive() or not damageTable.attacker or damageTable.attacker:IsNull() or not damageTable.attacker:IsAlive()) then
                    break
                end
                preDamageHandlerResultTable = GameMode.PreDamageAfterResistancesEventHandlersTable[i](nil, damageTable)
                if (preDamageHandlerResultTable ~= nil) then
                    if (damageCanceled == false) then
                        damageCanceled = (preDamageHandlerResultTable.damage <= 0)
                    end
                    local latestCrit = damageTable.crit
                    damageTable = preDamageHandlerResultTable
                    if (latestCrit > damageTable.crit) then
                        damageTable.crit = latestCrit
                    end
                end
            end
            if (damageCanceled == false) then
                if (damageTable.crit > 1.0) then
                    totalAmplification = totalAmplification + Units:GetCriticalDamage(damageTable.attacker)
                    damageTable.damage = damageTable.damage * totalAmplification
                    damageTable.damage = damageTable.damage * damageTable.crit
                    for i = 1, #GameMode.CritDamageEventHandlersTable do
                        if (not damageTable.victim or damageTable.victim:IsNull() or not damageTable.victim:IsAlive() or not damageTable.attacker or damageTable.attacker:IsNull() or not damageTable.attacker:IsAlive()) then
                            break
                        end
                        GameMode.CritDamageEventHandlersTable[i](nil, damageTable)
                    end
                    if (args.ability or args.fromtalent) then
                        PopupSpellCriticalDamage(damageTable.victim, damageTable.damage)
                    else
                        PopupCriticalDamage(damageTable.victim, damageTable.damage)
                    end
                else
                    damageTable.damage = damageTable.damage * totalAmplification
                end
                ApplyDamage(damageTable)
                for i = 1, #GameMode.PostDamageEventHandlersTable do
                    if (not damageTable.victim or damageTable.victim:IsNull() or not damageTable.victim:IsAlive() or not damageTable.attacker or damageTable.attacker:IsNull() or not damageTable.attacker:IsAlive()) then
                        break
                    end
                    GameMode.PostDamageEventHandlersTable[i](nil, damageTable)
                end
            end
        end
    end

    ---@class HEAL_TABLE
    ---@field public caster CDOTA_BaseNPC
    ---@field public target CDOTA_BaseNPC
    ---@field public ability CDOTA_Ability_DataDriven
    ---@field public heal number
    ---@param args HEAL_TABLE
    function GameMode:HealUnit(args)
        if (args == nil) then
            return
        end
        args.heal = tonumber(args.heal)
        if (args.caster == nil or args.target == nil or args.heal == nil) then
            return
        end
        args.heal = args.heal * (Units:GetHealingCausedPercent(args.caster) + Units:GetHealingReceivedPercent(args.target) - 1)
        args.crit = 1.0
        local preHealHandlerResultTable
        local healCanceled = false
        for i = 1, #GameMode.PreHealEventHandlersTable do
            if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                break
            end
            preHealHandlerResultTable = GameMode.PreHealEventHandlersTable[i](nil, args)
            if (preHealHandlerResultTable ~= nil) then
                local latestCrit = args.crit
                args = preHealHandlerResultTable
                if (latestCrit > args.crit) then
                    args.crit = latestCrit
                end
            end
        end
        healCanceled = (args.heal < 1)
        if (not healCanceled) then
            if (args.crit > 1.0) then
                args.heal = args.heal * args.crit
                for i = 1, #GameMode.CritHealEventHandlersTable do
                    if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                        break
                    end
                    GameMode.CritHealEventHandlersTable[i](nil, args)
                end
            end
            args.target:Heal(args.heal, args.caster)
            PopupHealing(args.target, args.heal)
            for i = 1, #GameMode.PostHealEventHandlersTable do
                if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                    break
                end
                GameMode.PostHealEventHandlersTable[i](nil, args)
            end
        end
    end

    ---@class HEAL_MANA_TABLE
    ---@field public caster CDOTA_BaseNPC
    ---@field public target CDOTA_BaseNPC
    ---@field public ability CDOTA_Ability_DataDriven
    ---@field public heal number
    ---@param args HEAL_MANA_TABLE
    function GameMode:HealUnitMana(args)
        if (args == nil) then
            return
        end
        args.heal = tonumber(args.heal)
        if (args.caster == nil or args.target == nil or args.heal == nil) then
            return
        end
        args.crit = 1.0
        args.heal = args.heal * (Units:GetHealingCausedPercent(args.caster) + Units:GetHealingReceivedPercent(args.target) - 1)
        local preHealHandlerResultTable
        local healCanceled = false
        for i = 1, #GameMode.PreHealManaEventHandlersTable do
            if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                break
            end
            preHealHandlerResultTable = GameMode.PreHealManaEventHandlersTable[i](nil, args)
            if (preHealHandlerResultTable ~= nil) then
                local latestCrit = args.crit
                args = preHealHandlerResultTable
                if (latestCrit > args.crit) then
                    args.crit = latestCrit
                end
            end
        end
        healCanceled = (args.heal < 1)
        if (not healCanceled) then
            if (args.crit > 1.0) then
                args.heal = args.heal * args.crit
                for i = 1, #GameMode.CritHealManaEventHandlersTable do
                    if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                        break
                    end
                    GameMode.CritHealManaEventHandlersTable[i](nil, args)
                end
            end
            args.target:GiveMana(args.heal)
            PopupManaHealing(args.target, args.heal)
            for i = 1, #GameMode.PostHealManaEventHandlersTable do
                if (not args.caster or args.caster:IsNull() or not args.caster:IsAlive() or not args.target or args.target:IsNull() or not args.target:IsAlive()) then
                    break
                end
                GameMode.PostHealManaEventHandlersTable[i](nil, args)
            end
        end
    end

    function GameMode:RollCriticalChance(unit, chance)
        return RollPercentage(chance * Units:GetCriticalChanceMultiplier(unit))
    end

    ---@param modifierTable MODIFIER_TABLE
    function GameMode:OnModifierApplied(modifierTable)
        if (modifierTable.target) then
            Units:ForceStatsCalculation(modifierTable.target)
        end
    end

    function GameMode:PerformGameMechanicsPostInit()
        if (not IsServer()) then
            return
        end
        local abilitiesList = {}
        local abilitiesData = LoadKeyValues("scripts/npc/npc_abilities_custom.txt")
        for name, _ in pairs(abilitiesData) do
            table.insert(abilitiesList, name)
        end
        local modifiersList = {}
        local innateModifiersList = {}
        for name, class in pairs(_G) do
            if (type(class) == "table" and name:find("modifier_")) then
                modifiersList[name] = class
            end
            if (type(class) == "table" and TableContains(abilitiesList, name)) then
                innateModifiersList[name] = class
            end
        end
        GameMode:BuildAuraModifiersList(modifiersList)
        GameMode:BuildCrowdControlModifiersList(modifiersList)
        GameMode:BuildIntrinsicModifiersList(innateModifiersList)
    end

    function GameMode:BuildAuraModifiersList(modifiersList)
        for name, class in pairs(modifiersList) do
            if (class.IsAura) then
                local auraModifier = class.GetModifierAura(nil)
                if (type(auraModifier) == "string") then
                    table.insert(GameMode.AuraModifiersTable, auraModifier)
                else
                    DebugPrint("[GAME MECHANICS] There are problems during loading aura modifiers. Expected aura modifier name (string) from GetModifierAura(), but got something else. Aura with problem: " .. tostring(name))
                end
            end
        end
    end

    function GameMode:BuildCrowdControlModifiersList(modifiersList)
        for name, class in pairs(modifiersList) do
            if (class.CheckState) then
                local stateTable = class.CheckState(nil)
                local isRoot = (stateTable[MODIFIER_STATE_ROOTED] == true)
                local isStun = (stateTable[MODIFIER_STATE_STUNNED] == true)
                local isSilence = (stateTable[MODIFIER_STATE_SILENCED] == true)
                local isHex = (stateTable[MODIFIER_STATE_HEXED] == true)
                GameMode.CrowdControlModifiersTable[name] = { root = isRoot, stun = isStun, silence = isSilence, hex = isHex }
            end
        end
    end

    function GameMode:BuildIntrinsicModifiersList(abilitiesList)
        for name, class in pairs(abilitiesList) do
            if (class.GetIntrinsicModifierName) then
                local modifierName = class.GetIntrinsicModifierName(nil)
                if (type(modifierName) == "string") then
                    table.insert(GameMode.IntrinsicModifiersTable, modifierName)
                else
                    DebugPrint("[GAME MECHANICS] There are problems during loading intrinsic modifiers. Expected intrinsic modifier name (string) from GetIntrinsicModifierName(), but got something else. Ability with problem: " .. tostring(name))
                end
            end
        end
    end

    function GameMode:OverwriteModifierFunctions(modifier)
        if (modifier.OnDestroy and not modifier.OnDestroy2) then
            modifier.OnDestroy2 = modifier.OnDestroy
            modifier.OnDestroy = function(context)
                context.OnDestroy2(context)
                if (IsServer()) then
                    Units:ForceStatsCalculation(context:GetParent())
                end
            end
        end
        if (not modifier.SetStackCount2) then
            modifier.SetStackCount2 = modifier.SetStackCount
            modifier.SetStackCount = function(context, count)
                context.SetStackCount2(context, count)
                if (IsServer()) then
                    Units:ForceStatsCalculation(context:GetParent())
                end
            end
        end
        if (not modifier.IncrementStackCount2) then
            modifier.IncrementStackCount2 = modifier.IncrementStackCount
            modifier.IncrementStackCount = function(context)
                context.IncrementStackCount2(context)
                if (IsServer()) then
                    Units:ForceStatsCalculation(context:GetParent())
                end
            end
        end
        if (not modifier.DecrementStackCount2) then
            modifier.DecrementStackCount2 = modifier.DecrementStackCount
            modifier.DecrementStackCount = function(context)
                context.DecrementStackCount2(context)
                if (IsServer()) then
                    Units:ForceStatsCalculation(context:GetParent())
                end
            end
        end
        if (not modifier.OnRefresh2) then
            modifier.OnRefresh2 = modifier.OnRefresh
            modifier.OnRefresh = function(context, table)
                context.OnRefresh2(context, table)
                if (IsServer()) then
                    Units:ForceStatsCalculation(context:GetParent())
                end
            end
        end
    end
end

modifier_cooldown_reduction_custom = class({
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
    DeclareFunctions = function(self)
        return { MODIFIER_EVENT_ON_ABILITY_FULLY_CAST }
    end
})

function modifier_cooldown_reduction_custom:OnAbilityFullyCast(keys)
    if (not IsServer()) then
        return
    end
    if (keys.unit == self.unit) then
        local charges = self.unit:FindAllModifiersByName("modifier_charges")
        for _, charge in pairs(charges) do
            if (charge.ability == keys.ability) then
                return
            end
        end
        local cooldownTable = {}
        cooldownTable.reduction = Units:GetCooldownReduction(self.unit, keys.ability)
        cooldownTable.ability = keys.ability:GetAbilityName()
        cooldownTable.isflat = false
        cooldownTable.target = self.unit
        GameMode:ReduceAbilityCooldown(cooldownTable)
    end
end

function modifier_cooldown_reduction_custom:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.unit = self:GetParent()
end

LinkLuaModifier("modifier_cooldown_reduction_custom", "systems/game_mechanics", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    local isUnitThinker = (unit:GetUnitName() == "npc_dota_thinker")
    if (not unit:HasModifier("modifier_cooldown_reduction_custom") and not Summons:IsSummmon(unit) and not isUnitThinker) then
        unit:AddNewModifier(unit, nil, "modifier_cooldown_reduction_custom", { Duration = -1 })
    end
end, nil)

modifier_out_of_combat = class({
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

function modifier_out_of_combat:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self.delay = 4
    self:StartIntervalThink(1.0)
end

function modifier_out_of_combat:OnIntervalThink()
    if (not IsServer()) then
        return
    end
    local stacks = self:GetStackCount() + 1
    if (stacks > self.delay) then
        stacks = self.delay
        if (not self.buff) then
            local modifierTable = {}
            modifierTable.ability = nil
            modifierTable.target = self.caster
            modifierTable.caster = self.caster
            modifierTable.modifier_name = "modifier_out_of_combat_buff"
            modifierTable.duration = -1
            self.buff = GameMode:ApplyBuff(modifierTable)
        end
    end
    self:SetStackCount(stacks)
end

function modifier_out_of_combat:OnPostTakeDamage(damageTable)
    local modifier = damageTable.victim:FindModifierByName("modifier_out_of_combat")
    if (modifier) then
        modifier_out_of_combat:ResetTimer(damageTable.victim)
    end
    modifier = damageTable.attacker:FindModifierByName("modifier_out_of_combat")
    if (modifier) then
        modifier_out_of_combat:ResetTimer(damageTable.attacker)
    end
end

function modifier_out_of_combat:OnPostHeal(healTable)
    local modifier = healTable.caster:FindModifierByName("modifier_out_of_combat")
    if (modifier and not healTable.target:HasModifier("modifier_out_of_combat_buff")) then
        modifier_out_of_combat:ResetTimer(healTable.caster)
    end
end

function modifier_out_of_combat:ResetTimer(unit)
    if (not unit or unit:IsNull()) then
        return
    end
    local buff = unit:FindModifierByName("modifier_out_of_combat_buff")
    if (buff) then
        buff:Destroy()
    end
    local modifier = unit:FindModifierByName("modifier_out_of_combat")
    if (modifier) then
        modifier:SetStackCount(0)
        modifier.buff = nil
    end
end

LinkLuaModifier("modifier_out_of_combat", "systems/game_mechanics", LUA_MODIFIER_MOTION_NONE)

modifier_out_of_combat_buff = class({
    IsDebuff = function(self)
        return false
    end,
    IsHidden = function(self)
        return false
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
    GetTexture = function(self)
        return "chen_divine_favor"
    end
})

function modifier_out_of_combat_buff:GetMoveSpeedBonus()
    return 100
end

function modifier_out_of_combat_buff:OnCreated(keys)
    if (not IsServer()) then
        return
    end
    self.caster = self:GetParent()
    self:StartIntervalThink(1.0)
    self:OnIntervalThink()
end

function modifier_out_of_combat_buff:OnIntervalThink()
    if (not IsServer() or not self.caster:IsAlive()) then
        return
    end
    local healTable = {}
    healTable.caster = self.caster
    healTable.target = self.caster
    healTable.ability = nil
    healTable.heal = self.caster:GetMaxHealth() * 0.10
    GameMode:HealUnit(healTable)
    healTable.heal = self.caster:GetMaxMana() * 0.10
    GameMode:HealUnitMana(healTable)
end

LinkLuaModifier("modifier_out_of_combat_buff", "systems/game_mechanics", LUA_MODIFIER_MOTION_NONE)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    local isUnitThinker = (unit:GetUnitName() == "npc_dota_thinker")
    if (not unit.HasNPCBasedModifier and not isUnitThinker) then
        unit.HasNPCBasedModifier = GameMode.HasNPCBasedModifier
    end
end, nil)

ListenToGameEvent("npc_spawned", function(keys)
    if (not IsServer()) then
        return
    end
    local unit = EntIndexToHScript(keys.entindex)
    local isUnitThinker = (unit:GetUnitName() == "npc_dota_thinker")
    if (not unit:HasModifier("modifier_out_of_combat") and not Summons:IsSummmon(unit) and not isUnitThinker and unit.IsRealHero and unit:IsRealHero()) then
        unit:AddNewModifier(unit, nil, "modifier_out_of_combat", { Duration = -1 })
    end
end, nil)

ListenToGameEvent("dota_player_learned_ability", function(keys)
    if (not IsServer()) then
        return
    end
    if (not keys.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(keys.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    Units:ForceStatsCalculation(hero)
end, nil)

if (IsServer() and not GameMode.GAME_MECHANICS_INIT) then
    GameMode.PreDamageBeforeResistancesEventHandlersTable = {}
    GameMode.PreDamageAfterResistancesEventHandlersTable = {}
    GameMode.PostDamageEventHandlersTable = {}
    GameMode.CritDamageEventHandlersTable = {}
    GameMode.PostApplyModifierEventHandlersTable = {}
    GameMode.PreHealEventHandlersTable = {}
    GameMode.PostHealEventHandlersTable = {}
    GameMode.CritHealEventHandlersTable = {}
    GameMode.PreHealManaEventHandlersTable = {}
    GameMode.PostHealManaEventHandlersTable = {}
    GameMode.CritHealManaEventHandlersTable = {}
    GameMode.MinimumAbilitiesCooldownTable = {}
    GameMode.CrowdControlModifiersTable = {}
    GameMode.AuraModifiersTable = {}
    GameMode.IntrinsicModifiersTable = {}
    GameMode:RegisterPostDamageEventHandler(Dynamic_Wrap(modifier_out_of_combat, 'OnPostTakeDamage'))
    GameMode:RegisterPostHealEventHandler(Dynamic_Wrap(modifier_out_of_combat, 'OnPostHeal'))
    GameMode:RegisterPostApplyModifierEventHandler(Dynamic_Wrap(GameMode, 'OnModifierApplied'))
    GameMode.GAME_MECHANICS_INIT = true
end