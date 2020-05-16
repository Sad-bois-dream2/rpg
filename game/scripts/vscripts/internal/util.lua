function DebugPrint(...)
    if BAREBONES_DEBUG_SPEW == true then
        print(...)
    end
end

function DebugPrintTable(...)
    if BAREBONES_DEBUG_SPEW == true then
        PrintTable(...)
    end
end

function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then
        return
    end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ":")
                PrintTable(value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                PrintTable((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep("\t", indent) .. tostring(t.FDesc[v]))
                else
                    print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                end
            end
        end
    end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'

function DebugAllCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: " .. src .. " -- " .. name .. " -- " .. info.currentline)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end



--wearable related stuff
--[[Author: Noya
  Date: 09.08.2015.
  Hides all dem hats
]]
function HideWearables(unit)
    unit.hiddenWearables = {} -- Keep every wearable handle in a table to show them later
    local model = unit:FirstMoveChild()
    while model ~= nil do
        if model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW) -- Set model hidden
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end
end

function ShowWearables(unit)
    for i, v in pairs(unit.hiddenWearables) do
        v:RemoveEffects(EF_NODRAW)
    end
end

function GetWearables(unit)
    local wearables = {}
    if (unit ~= nil) then
        local model = unit:FirstMoveChild()
        while model ~= nil do
            if model:GetClassname() == "dota_item_wearable" then
                table.insert(wearables, model)
            end
            model = model:NextMovePeer()
        end
    end
    return wearables
end

function AddWearables(unit, wearables)
    if (unit ~= nil and wearables ~= nil) then
        unit.customWearables = unit.customWearables or {}
        local origin = unit:GetAbsOrigin()
        for _, wearable in ipairs(wearables) do
            CreateUnitByNameAsync("wearable_dummy", origin, true, unit, unit, unit:GetTeamNumber(), function(newWearable)
                newWearable:SetOriginalModel(wearable:GetModelName())
                newWearable:SetModel(wearable:GetModelName())
                newWearable:AddNewModifier(unit, nil, "modifier_wearable", {})
                newWearable:SetParent(unit, nil)
                newWearable:FollowEntity(unit, true)
                table.insert(unit.customWearables, newWearable)
            end)
        end
        unit.customWearablesCount = #wearables
    end
end

function ForEachWearable(unit, func)
    if (unit ~= nil and unit.customWearables ~= nil) then
        Timers:CreateTimer(0,
                function()
                    if (unit ~= nil) then
                        if (#unit.customWearables == unit.customWearablesCount) then
                            for _, wearable in ipairs(unit.customWearables) do
                                func(wearable)
                            end
                        else
                            return 0.05
                        end
                    end
                end)
    end
end

function DestroyWearables(unit, callback)
    if (unit ~= nil and unit.customWearables ~= nil) then
        Timers:CreateTimer(0,
                function()
                    if (unit ~= nil) then
                        if (#unit.customWearables == unit.customWearablesCount) then
                            for _, wearable in ipairs(unit.customWearables) do
                                wearable:Destroy()
                            end
                            callback()
                        else
                            return 0.05
                        end
                    end
                end)
    end
end

modifier_wearable = class({})

function modifier_wearable:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
    }
    return state
end

function modifier_wearable:IsPurgable()
    return false
end

function modifier_wearable:IsStunDebuff()
    return false
end

function modifier_wearable:IsPurgeException()
    return false
end

function modifier_wearable:IsHidden()
    return true
end

LinkLuaModifier("modifier_wearable", "internal/util", LUA_MODIFIER_MOTION_NONE)

function TableContains(table, element)
    for _, v in pairs(table) do
        if v == element then
            return true
        end
    end

    return false
end

function DistanceBetweenVectors(vec1, vec2)
    return (vec1 - vec2):Length()
end