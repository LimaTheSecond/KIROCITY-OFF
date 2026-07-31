if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_hands_sh"
SWEP.PrintName = "Strong Fists"
SWEP.Category = "ZCity Other"
SWEP.Instructions = "LMB - raise fists / punch\nUSE + LMB - power kick\nRMB - block\nRELOAD - lower fists"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.HomicideSWEP = true
SWEP.NoDrop = true
SWEP.Slot = 0
SWEP.SlotPos = 1

SWEP.ReachDistance = 55
SWEP.DamagePrimary = 80
SWEP.DamageMul = 8
SWEP.PowerMul = 6
SWEP.Penetration = 4
SWEP.ShockMultiplier = 3
SWEP.PainMultiplier = 3
SWEP.BreakBoneMul = 2
SWEP.KickDamage = 1500
SWEP.KickReachDistance = 120
SWEP.KickCooldown = 0.85
SWEP.KickPlayerVelocity = 5200
SWEP.KickPhysicsForce = 850000
SWEP.KickUpForce = 90000
SWEP.KickSelfBack = 120

if CLIENT then
    SWEP.BounceWeaponIcon = false
end


function SWEP:PrimaryAttack(forcespecial)
    local owner = self:GetOwner()
    if IsValid(owner) and owner:KeyDown(IN_USE) then
        self:PowerKick()
        return
    end

    local base = weapons.GetStored("weapon_hands_sh")
    if base and base.PrimaryAttack then
        return base.PrimaryAttack(self, forcespecial)
    end
end

function SWEP:PowerKick()
    local owner = self:GetOwner()
    if not IsValid(owner) or owner:InVehicle() then return end

    local time = CurTime()
    if (self.NextPowerKick or 0) > time then return end

    self.NextPowerKick = time + (self.KickCooldown or 1)
    self.attacked = time + (self.KickCooldown or 1)
    self:SetFists(true)
    self:SetBlocking(false)
    self:SetNextPrimaryFire(self.NextPowerKick)
    self:SetNextSecondaryFire(self.NextPowerKick)
    self:SetNextDown(time + 7)

    if self.DoBFSAnimation then
        self:DoBFSAnimation("fists_uppercut", 1.4)
    end

    if owner.ViewPunch then
        owner:ViewPunch(Angle(10, 0, 0))
    end

    if SERVER then
        owner:EmitSound("weapons/tfa/melee" .. math.random(1, 6) .. ".wav", 80, 80)
        owner:LagCompensation(true)

        local filter = {owner}
        if hg and hg.GetCurrentCharacter then
            local char = hg.GetCurrentCharacter(owner)
            if IsValid(char) then filter[#filter + 1] = char end
        end

        local startPos = owner.EyePos and owner:EyePos() or owner:GetShootPos()
        local aim = owner:GetAimVector()
        local tr = util.TraceHull({
            start = startPos,
            endpos = startPos + aim * (self.KickReachDistance or 120),
            filter = filter,
            mins = Vector(-14, -14, -10),
            maxs = Vector(14, 14, 10),
            mask = MASK_SHOT_HULL
        })

        local ent = tr.Entity
        if IsValid(ent) or (ent and ent.IsWorld and ent:IsWorld()) then
            local hitPos = tr.HitPos
            local dmg = DamageInfo()
            dmg:SetAttacker(owner)
            dmg:SetInflictor(self)
            dmg:SetDamage(self.KickDamage or 1500)
            dmg:SetDamageType(DMG_CLUB + DMG_CRUSH)
            dmg:SetDamagePosition(hitPos)
            dmg:SetDamageForce(aim * (self.KickPhysicsForce or 850000))

            PenetrationGlobal = 10
            MaxPenLenGlobal = 10
            ent:TakeDamageInfo(dmg)

            if ent:IsPlayer() or ent:IsNPC() or ent:IsRagdoll() then
                owner:EmitSound("weapons/tfa/melee_hit_world" .. math.random(1, 3) .. ".wav", 90, 80)
            else
                owner:EmitSound("physics/metal/weapon_impact_hard3.wav", 90, 80)
            end

            if ent:IsPlayer() then
                ent:SetVelocity(aim * (self.KickPlayerVelocity or 5200) + Vector(0, 0, 260))
                ent:ViewPunch(Angle(-45, 0, 0))
                if ent.organism then
                    ent.organism.immobilization = math.max(ent.organism.immobilization or 0, 2)
                    ent.organism.painadd = (ent.organism.painadd or 0) + 25
                    ent.organism.shock = (ent.organism.shock or 0) + 20
                end
            elseif ent:IsNPC() or ent:IsNextBot() then
                if ent.SetVelocity then ent:SetVelocity(aim * (self.KickPlayerVelocity or 5200) + Vector(0, 0, 260)) end
            end

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:ApplyForceOffset(aim * (self.KickPhysicsForce or 850000) + Vector(0, 0, self.KickUpForce or 90000), hitPos)
            end

            if isfunction(hgIsDoor) and isfunction(hgBlastThatDoor) and hgIsDoor(ent) then
                hgBlastThatDoor(ent, aim * 16000 + owner:GetVelocity())
            end

            util.ScreenShake(hitPos, 12, 160, 0.35, 450)
        end

        owner:SetVelocity(-aim * (self.KickSelfBack or 120) + Vector(0, 0, 80))
        owner:LagCompensation(false)
    end
end

function SWEP:AttackFront(special_attack, rand)
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local oldMul = owner.MeleeDamageMul
    owner.MeleeDamageMul = (oldMul or 1) * (self.PowerMul or 1)

    local base = weapons.GetStored("weapon_hands_sh")
    if base and base.AttackFront then
        base.AttackFront(self, special_attack, rand)
    end

    owner.MeleeDamageMul = oldMul
end
