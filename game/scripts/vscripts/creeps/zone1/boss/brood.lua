---------------------
-- brood toxin
---------------------
target:EmitSound("Hero_Slardar.Bash")

---------------------
-- brood comes
---------------------
caster:EmitSound("broodmother_broo_move_09")
---------------------
-- brood cocoons
---------------------
caster:EmitSound("Hero_Broodmother.SpawnSpiderlingsCast")

local brood_cocoons_fx = ParticleManager:CreateParticle("particles/items5_fx/spider_legs_buff_webs.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
---------------------
-- brood kiss
---------------------
caster:EmitSound("broodmother_broo_kill_12")
----------------
-- brood spit
---------------
caster:EmitSound("hero_viper.poisonAttack.Cast")
----------------
-- brood hunger
----------------
caster:EmitSound("Hero_Broodmother.InsatiableHunger")
---------------------
-- brood web
---------------------
caster:EmitSound("Hero_Broodmother.SpinWebCast")
caster:EmitSound("broodmother_broo_ability_spin_01")
--on spawn
caster:EmitSound("broodmother_broo_ability_spawn_04")
