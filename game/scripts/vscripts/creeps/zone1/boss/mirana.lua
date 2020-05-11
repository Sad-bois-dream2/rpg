--------------
--mirana shard
---------------
target:EmitSound("Hero_Antimage.ManaBreak")
local fx = "particles/generic_gameplay/generic_manaburn.vpcf"
--------------
--mirana sky
---------------
local darkness = "Hero_Nightstalker.Darkness.Team"
local desolate =  "particles/units/heroes/hero_spectre/spectre_desolate_debuff.vpcf"
--------------
--mirana blessing
---------------

--------------
--mirana holy
---------------

--------------
--mirana under
---------------
local fx = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_lvlup_godray.vpcf"
--------------
--mirana aligned
---------------

function StarsAlignFX(target)
    local particle = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly_blue_fast.vpcf", PATTACH_WORLDORIGIN, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(500,250,900))
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() + Vector(0,0,50))
    ParticleManager:SetParticleControl(particle, 2, Vector(0.25,0,0))
    ParticleManager:ReleaseParticleIndex(particle)
    particle = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly_blue_fast.vpcf", PATTACH_WORLDORIGIN, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetAbsOrigin() + Vector(-500,-250,900))
    ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() + Vector(0,0,50))
    ParticleManager:SetParticleControl(particle, 2, Vector(0.25,0,0))
    ParticleManager:ReleaseParticleIndex(particle)
    EmitSoundOn("Hero_Luna.Eclipse.Cast", target)
    Timers:CreateTimer(0.25,function()
        particle = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_death_ti7_model.vpcf", PATTACH_WORLDORIGIN, target)
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin() + Vector(0,0,0))
        ParticleManager:ReleaseParticleIndex(particle)
    end)
end

--------------
--mirana guile
---------------
--------------
--mirana bound
---------------