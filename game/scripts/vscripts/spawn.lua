function OnStartTouch(trigger)

    --print(trigger.activator)
    --print(trigger.caller)
    local spawn_point = Vector(-14908.075195, 14764.760742, 384.000000)
    local spawn = spawn_point + Vector(500,0,0)
    --CreateUnitByNameAsync("npc_boss_parasite_golem", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_executioner", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_hellhound", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_succubus", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_winterwyrm_dragon", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_balanar", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_rubicundus", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_viridis", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --CreateUnitByNameAsync("npc_boss_coeruleus", spawn, true, nil, nil, DOTA_TEAM_BADGUYS,nil)



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
        {x = -11796.5, y = 10923},--ursa
        {x = -13959, y = 5160}, --lycan
        {x = -7602, y =  9910}, --brood
        {x = -9605, y = 6872}, --treant
        {x = -13150, y = 1594}, --luna
        {x = -13638, y = 1398.5}, --mirana
        {x = -8462, y = 4147}, --venge
    }


    --boss spawn
    --for i = 0, number - 1, 1 do
        --CreateUnitByNameAsync(boss[i+1], Vector(vector[i+1].x, vector[i+1].y, 384), true, nil, nil, DOTA_TEAM_BADGUYS,nil)
    --end

    --act opening pic and sound
    Timers:CreateTimer(2.0, function()
        Notifications:TopToAll({text = "Zone 1: Nightsilver Woods", duration = 2, style={color="white", ["font-size"]="54px", border="10px solid blue"}})
        Timers:CreateTimer(2.0, function()
        Notifications:TopToAll({image = "s2r://panorama/images/custom_game/zone_opening/venge_png.vtex", duration=2})
        Notifications:BottomToAll({text = "Selemene : Die!", duration = 2})
        EmitGlobalSound("vengefulspirit_vng_attack_08")
        end)
    end)

    --tower
    local tower =
    {
        "npc_tower_holytower",
        "npc_tower_helltower",
        "npc_tower_naturetower",
        "npc_tower_naturetower"
    }

    local vector_tower =
    {
        {x = -11037.5, y = 13954 },
        {x = -11044.5, y = 13436.5},
        {x = -15041.5, y = 6934},
        {x = -12327, y = 7278},
        {x = -10451, y = 4721},
        {x = -12487, y = 3482},
        {x = -15273, y = 1527},
        {x = -14864, y = 976},
        {x = -8804, y = 4692},
        {x = -7866, y = 3889}

    }

    local number_tower = RandomInt(3, 6)
    local rng_number
    local chosen
    --for i = 0, number_tower - 1, 1 do
        --rng_number = RandomInt(1, #vector_tower)
        --chosen = vector_tower[rng_number]
        --CreateUnitByNameAsync(tower[RandomInt(1, #tower)], Vector(chosen.x, chosen.y, 384), true, nil, nil, DOTA_TEAM_BADGUYS,nil)
        --table.remove(vector_tower,rng_number) -- dont pepeg and build at the same place
    --end
end

