--------
--venge moonfall
---------
function AffixStarboy( event )
    local caster = event.caster
    local ability = event.ability
    local duration = 20
    local stars_per_sec = 4
    local ticks = duration * stars_per_sec
    local tick_interval = 1 / stars_per_sec
    local fly_time = 3.5
    local aoe = 150
    for i=0, ticks - 1 do
        Timers:CreateTimer(tick_interval * i,function()
            if caster and (caster:IsNull() or not caster:IsAlive()) then
                return
            end
            local target_point = caster:GetAbsOrigin() + RandomVector(math.random(1, 1750))
            FXStarfall(caster, target_point, Vector(600,600,1200), fly_time, aoe, true)
            Timers:CreateTimer(fly_time,function()
                local tab = {}
                tab.caster = caster
                tab.damage = 0.0
                tab.spelldamagefactor = 0.0
                tab.attributefactor = 0.0
                tab.includeauto = 500
                tab.ability = ability
                tab.aoe = aoe
                tab.targeteffect = "blood"
                tab.onlyhero = 1
                tab.target_points = {}
                tab.target_points[1] = target_point
                DamageAOE(tab)
            end)
        end)
    end
end

function FXStarfall(caster, target_point, offset, time, aoe, shadowfx)
    local particle = ParticleManager:CreateParticle("particles/invoker_chaos_meteor_fly_blue_slow2.5.vpcf", PATTACH_WORLDORIGIN, caster)
    ParticleManager:SetParticleControl(particle, 0, target_point + offset)
    ParticleManager:SetParticleControl(particle, 1, target_point + Vector(0,0,50))
    ParticleManager:SetParticleControl(particle, 2, Vector(time,0,0))
    ParticleManager:ReleaseParticleIndex(particle)
    EmitSoundOn("Hero_Luna.Eclipse.Cast", caster)
    local particle2
    if shadowfx then
        particle2 = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher_v2_ground01.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle2, 0, target_point)
        ParticleManager:SetParticleControl(particle2, 1, target_point)
        ParticleManager:SetParticleControl(particle2, 2, target_point)

    end
    Timers:CreateTimer(time,function()
        particle = ParticleManager:CreateParticle("particles/econ/items/wisp/wisp_death_ti7_model.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 1, target_point)
        ParticleManager:ReleaseParticleIndex(particle)
        particle = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 0, target_point)
        ParticleManager:SetParticleControl(particle, 1, Vector(aoe,aoe,aoe))
        ParticleManager:ReleaseParticleIndex(particle)
        if shadowfx and particle2 then
            ParticleManager:DestroyParticle(particle2,false)
            ParticleManager:ReleaseParticleIndex(particle2)
        end
    end)
end