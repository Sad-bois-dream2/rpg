function OnStartTouch(trigger)

    --print(trigger.activator)
    --print(trigger.caller)
    --local spawn_point = Vector(-14908.075195, 14764.760742, 384.000000)

    local number = 7
    local boss =
    {"npc_boss_ursa",
     "npc_boss_lycan",
     "npc_boss_brood",
     "npc_boss_treant",
     "npc_boss_luna",
     "npc_boss_mirana",
     "npc_boss_venge",
    }

    local vector =
    {
        {x = -11796.5, y = 10923, z =  384},--ursa
        {x = -13959, y = 5160, z = 384}, --lycan
        {x = -7602, y =  9910, z =384}, --brood
        {x = -9605, y = 6872, z = 384}, --treant
        {x = -13150, y = 1594, z = 384}, --luna
        {x = -13638, y = 1398.5, z = 384}, --mirana
        {x = -8462, y = 4147, z = 384}, --venge
    }

    for i = 0, number - 1, 1 do
        CreateUnitByNameAsync(boss[i+1], Vector(vector[i+1].x, vector[i+1].y, vector[i+1].z), true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    end

    Timers:CreateTimer(2.0, function()
        Notifications:TopToAll({text = "Zone 1: Nightsilver Woods", duration = 3, style={color="white", ["font-size"]="54px", border="10px solid blue"}})
        Notifications:TopToAll({image = "s2r://panorama/images/custom_game/zone_opening/venge_png.vtex", duration=3})
        Notifications:BottomToAll({text = "Selemene : Die!", duration = 3})
        EmitGlobalSound("vengefulspirit_vng_attack_08")
    end)
end

