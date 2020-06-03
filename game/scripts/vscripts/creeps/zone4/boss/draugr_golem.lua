
--------------------
--draugr golem winter solider --animation victory --channeling summon solider that heal him on attack. Winter soldiers spawn at his location, they have mindless servant passive
-------------------
--------------------
--draugr golem frozen tomb --animation tombstone cast --banish hero(s) and replace it(them) with tomb that needed to be channeled to bring the hero back
-------------------

draugr_golem_tomb = class({
    GetAbilityTextureName = function(self)
        return "draugr_golem_tomb"
    end,

})

function draugr_golem_tomb:FindTargetForBanish(caster)
    local range = self:GetSpecialValueFor("range")
    -- Find all nearby enemies
    local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
            caster:GetAbsOrigin(),
            nil,
            range,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    local keys = {}
    for k in pairs(enemies) do
        table.insert(keys, k)
    end
    if (#enemies > 0) then
        local banishTarget = enemies[keys[math.random(#keys)]] --pick one number = pick one enemy
        if (#enemies > 0) then
            return banishTarget
        else
            return nil
        end
    end
end

function draugr_golem_tomb:Banish(target)
    if (not IsServer()) then
        return
    end
    --apply banish debuff banish until rescue by channeling at melee range for some time if not saved for 30s = ded
    if target ~= nil then

        local newItem = CreateItem( "item_tombstone", target , target )
        newItem:SetPurchaseTime( 0 )
        newItem:SetPurchaser( target )
        local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
        tombstone:SetContainedItem( newItem )
        tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
        FindClearSpaceForUnit( tombstone, target:GetAbsOrigin(), true )
        target:AddNewModifier( target, nil, "modifier_hide_on_minimap", { EnemiesOnly=true } )
        Timers:CreateTimer(20, function()
            if target:HasModifier("modifer_hide_on_minimap") then
                target:ForceKill(false)
            end
        end)

    end
end

function draugr_golem_tomb:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    local number = self:GetSpecialValueFor("number")
    --self.duration = self:GetSpecialValueFor("duration")
    local counter = 0
    local target
    Timers:CreateTimer(0, function()
        if counter < number then
            target = self:FindTargetForBanish(self.caster)
            self:Banish(target)
            counter = counter + 1
            return 0.1
        end
    end)
    --self.caster:EmitSound("broodmother_broo_move_09")
end

-------------------------
--draugr golem zombify--animation decay --small aoe blast around a random target applying undispellable %max health bonus but negate healing/regen for 30 s
-------------------------
--------------------
--draugr golem mindless servant--passive slow/stun/silence debuff last 50/75/100% shorter on him and take less take 35/55/75% less dmg from physical dmg attack/physical dmg  spells
--------------------
---------------------------------
--draugr golem rot from with in --passive low cd aoe blast dealing dot around himself applying stacking dmg output reduction/ healing caused reduction/ ms slow
----------------------------------
---------------------
--draugr golem stomp --low cd ground stomp covering large aoe applying low duration stun and low damage + chance to proc on aa
---------------------
--------------------
--draugr golem infected wound --single target close range spell apply undispellable infect wound on single target lose % current heath every second
--------------------
--------------------
--draugr golem disease cloud -- linear projectile disease cloud slowly spilling from him deal high damage on contract ( like necro in tb but this doesnt heal and  boi still move)
--------------------