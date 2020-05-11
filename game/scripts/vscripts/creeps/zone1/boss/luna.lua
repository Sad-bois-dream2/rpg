-------------
--luna void
------------
self:GetCaster():EmitSound("Hero_Antimage.ManaVoidCast")
local void_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_POINT_FOLLOW, target)
ParticleManager:SetParticleControlEnt(void_pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
ParticleManager:SetParticleControl(void_pfx, 1, Vector(radius,0,0))
ParticleManager:ReleaseParticleIndex(void_pfx)
target:EmitSound("Hero_Antimage.ManaVoid")

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