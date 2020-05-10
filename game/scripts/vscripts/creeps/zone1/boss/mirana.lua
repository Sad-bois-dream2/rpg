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

