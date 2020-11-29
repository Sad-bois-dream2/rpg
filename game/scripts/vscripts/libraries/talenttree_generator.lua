function GetTalentBranch(talentId)
    talentId = tonumber(talentId)
    local talentColumn = talentId % 9
    if (talentColumn >= 1 and talentColumn <= 3) then
        return 1
    end
    if (talentColumn >= 4 and talentColumn <= 6) then
        return 2
    end
    return 3
end

function GetTalentLine(talentId)
    talentId = tonumber(talentId)
    return math.ceil(talentId / 9)
end

local out = "";
out = out.."\"┼ID┼\"\n"
out = out.."{\n"
out = out.."\t\"Icon\"\t\"file://{images}/custom_game/hud/talenttree/talent_┼ID┼.png\"\n"
out = out.."\t\"Modifier\"\t\"modifier_talent_┼ID┼\"\n"
out = out.."\t\"MaxLevel\"\t\"3\"\n"
out = out.."\t\"Row\"\t\"┼ROW┼\"\n"
out = out.."\t\"Column\"\t\"┼COLUMN┼\"\n"
out = out.."}"
for i=1, 54 do
    local talent = out
    local row = GetTalentLine(i)
    local column = GetTalentBranch(i)
    talent = talent:gsub("┼ID┼", i)
    talent = talent:gsub("┼ROW┼", row)
    talent = talent:gsub("┼COLUMN┼", column)
    print(talent)
end

local out = "";
out = out.."\"┼ID┼\"\n"
out = out.."{\n"
out = out.."\t\"Row\"\t\"┼ROW┼\"\n"
out = out.."\t\"Column\"\t\"┼COLUMN┼\"\n"
out = out.."\t\"RequiredPoints\"\t\"┼POINTS┼\"\n"
out = out.."}"
local test = {}
local reqId = 1
for i=1, 54 do
    local talent = out
    local row = GetTalentLine(i)
    local column = GetTalentBranch(i)
    if(not (test[column] and test[column][row])) then
        talent = talent:gsub("┼ID┼", reqId)
        talent = talent:gsub("┼ROW┼", row)
        talent = talent:gsub("┼COLUMN┼", column)
        talent = talent:gsub("┼POINTS┼", (row-1)*3)
        print(talent)
        test[column] = test[column] or {}
        test[column][row] = {}
        reqId = reqId + 1
    end
end
