---------
--luna wax
--------

local wax_sound = "luna_luna_levelup_10"

function PathRainOfStarsAA( event )
    local caster = event.caster
    local target = event.target
    local chance = 15
    if math.random(1,100) <= chance then
        EmitSoundOn("Hero_Luna.Eclipse.Cast", target)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_mirana/mirana_starfall_attack.vpcf", PATTACH_POINT_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(particle)
    end
end