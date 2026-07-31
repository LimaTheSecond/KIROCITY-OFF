SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AR-15"
SWEP.Author = "Colt's Manufacturing Company"
SWEP.Instructions = "This steel/polymer AR-15 semi-automatic pistol is in 5.56x45 caliber. With a barrel shorter than the 16-inch legal length for a rifle, and a pistol buffer tube or stabilizing brace in place of a stock, it provides a compact and powerful alternative to its longer-barreled counterparts. The pistol's compact size allows it to be used in small spaces, while its versatility and customizability have carved a niche for itself in the civilian market. A testament to the versatility of the AR platform, the AR-15 pistol symbolizes the balance between personal defense and recreational shooting.\n\nALT+E to change stance (+walk,+use)"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/ar15/w_colt6149.mdl"

SWEP.WepSelectIcon2 = Material("scrappers/ar15-pistol.png")
SWEP.IconOverride = "scrappers/ar15-pistol.png"

--models/ar15/w_smg_635.mdl
--models/ar15/w_colt6149.mdl
--models/ar15/w_kacmark012.mdl
--models/ar15/w_kacmark011.mdl
--models/ar15/w_ares_shrikemg.mdl
--models/ar15/w_magpulm.mdl
--models/ar15/w_kac_s47.mdl
SWEP.weaponInvCategory = 1
SWEP.bigNoDrop = true
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.CustomShell = "556x45"
SWEP.EjectPos = Vector(0,7,5)
SWEP.EjectAng = Angle(-25,-65,0)

SWEP.punchmul = 2
SWEP.punchspeed = 1

SWEP.StartAtt = {"ironsight3"}

SWEP.ShockMultiplier = 3

SWEP.ScrappersSlot = "Primary"

SWEP.LocalMuzzlePos = Vector(24.384,0.602,4.28)
SWEP.LocalMuzzleAng = Angle(-0.007,-0.004,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 44
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 44
SWEP.Primary.Sound = {"rifle_win1892/win1892_fire_01.wav", 75, 90, 100}
SWEP.SupressedSound = {"m4a1/m4a1_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.Wait = 0.12
SWEP.ReloadTime = 5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb2/weapons/m4a1/ru-556 clip out 1.wav",
	"none",
	"none",
	"pwb2/weapons/m4a1/ru-556 clip in 2.wav",
	"none",
	"pwb2/weapons/m4a1/ru-556 bolt back.wav",
	"pwb2/weapons/m4a1/ru-556 bolt forward.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle2" -- shared in sh_effects.lua

SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, 0.5658, 6.0085)

SWEP.RHandPos = Vector(2, -1, 1)
SWEP.LHandPos = false
SWEP.AimHands = Vector(-2, 0.45, -5.9)
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-0, -0.5, -0.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 1
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0,0,0), {}},
		[2] = {"supressor6", Vector(0,0,0), {}},
		["mount"] = Vector(-2,0.6,0),
	},
	sight = {
		["empty"] = {
			"empty",
			{
				[1] = "null"
			},
		},
		["mountType"] = {"picatinny","ironsight"},
		["mount"] = {ironsight = Vector(-12, 1.3, 0.05), picatinny = Vector(-17, 1.3, 0.05)},
		["removehuy"] = {
			[1] = "null"
		}
	}
}

SWEP.weight = 3

if CLIENT then
	function SWEP:DrawHUDAdd()
	end
	--self:DoHolo()
end

local recoilAng1 = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
local recoilAng2 = {Angle(-0.015, -0.015, 0), Angle(-0.025, 0.015, 0)}
if SERVER then
	util.AddNetworkString("send_huyhuy1")
else
	net.Receive("send_huyhuy1", function(len)
		local self = net.ReadEntity()
		local twohands = net.ReadBool()
		self.HoldType = twohands and "ar2" or "revolver"
		self.SprayRand = twohands and recoilAng1 or recoilAng2
		self.AnimShootHandMul = twohands and 0.25 or 1

		self.RHPos = not twohands and Vector(14,-6,4) or Vector(7,-6,3)
		self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-15,90)

		self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(12,1.5,-3.3)
		self.LHAng = not twohands and Angle(-0,0,-100) or Angle(-110,-180,0)
	end)
end

SWEP.weight = 3
SWEP.addweight = -1.5
SWEP.podkid = 0.25
SWEP.animposmul = 1
SWEP.PistolKinda = true

function SWEP:Step()
	self:CoreStep()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if hg.KeyDown(owner, IN_WALK) and hg.KeyDown(owner, IN_USE) and not self.reload then
		if not self.huybut then
			if SERVER then
				local twohands = self:IsPistolHoldType()
				self.HoldType = twohands and "ar2" or "revolver"
				self.SprayRand = twohands and recoilAng1 or recoilAng2
				self.AnimShootHandMul = twohands and 0.25 or 1
				self.RHPos = not twohands and Vector(14,-6,4) or Vector(7,-6,3)
				self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-15,90)
		
				self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(12,1.5,-3.3)
				self.LHAng = not twohands and Angle(-0,0,-100) or Angle(-110,-180,0)
				net.Start("send_huyhuy1")
				net.WriteEntity(self)
				net.WriteBool(twohands)
				net.Broadcast()
			end

			self.huybut = true
		end
	else
		self.huybut = false
	end
end

function SWEP:ReloadStart()
	if not IsValid(self:GetOwner()) then return end
	local twohands = self:IsPistolHoldType()
	self.OldHoldType = self.HoldType
	self.HoldType = "ar2"
	if SERVER then
		net.Start("send_huyhuy1")
			net.WriteEntity(self)
			net.WriteBool(true)
		net.Broadcast()
	end
end

function SWEP:ReloadEnd()
	self:InsertAmmo(self:GetMaxClip1() - self:Clip1() + (self.drawBullet ~= nil and not self.OpenBolt and 1 or 0))
	self.ReloadNext = CurTime() + self.ReloadCooldown --я хуй знает чо это
	self:Draw()
	local Fuck = self.HoldType == self.OldHoldType
	self.HoldType = self.OldHoldType or self.HoldType
	if SERVER then
		net.Start("send_huyhuy1")
			net.WriteEntity(self)
			net.WriteBool(Fuck)
		net.Broadcast()
	end
end

SWEP.lengthSub = 5
SWEP.holsteredPos = Vector(5, 8, -4)
SWEP.holsteredAng = Angle(-150, -10, 180)

--local to head
SWEP.RHPos = Vector(14,-6,4)
SWEP.RHAng = Angle(0,0,90)
--local to rh
SWEP.LHPos = Vector(-1,-2,-3)
SWEP.LHAng = Angle(-0,0,-100)

local finger1 = Angle(10, -15, -0)
local finger2 = Angle(-0, 30, 0)
local angZero = Angle(0, 0, 0)

function SWEP:AnimHoldPost(model)
	local th = self:IsPistolHoldType()
	if th then return end
	self:BoneSet("l_finger0", vector_zero, finger1)
	self:BoneSet("l_finger02", vector_zero, finger2)
end

--RELOAD ANIMS SMG????

-- RELOAD ANIM SR25/AR15
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-2,2,-6),
	Vector(-2,3,-6),
	Vector(-2,3,-6),
	Vector(-2,7,-10),
	Vector(-15,5,-25),
	Vector(-15,15,-25),
	Vector(-5,15,-25),
	Vector(-2,4,-6),
	Vector(-2,3,-6),
	Vector(-2,3,-6),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	"fastreload",
	Vector(-3,1,-3),
	Vector(-3,2,-3),
	Vector(-3,3,-3),
	Vector(-9,3,-3),
	Vector(-9,3,-3),
	Vector(0,3,-3),
	"reloadend",
	Vector(0,0,0),
	Vector(0,0,0),
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(-60,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(-90,0,110),
	Angle(0,0,95),
	Angle(0,0,60),
	Angle(0,0,30),
	Angle(0,0,2),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(-15,25,-15),
	Angle(-15,25,-25),
	Angle(5,28,-25),
	Angle(5,25,-25),
	Angle(1,24,-22),
	Angle(2,25,-21),
	Angle(-5,24,-22),
	Angle(1,25,-21),
	Angle(0,24,-22),
	Angle(1,25,-32),
	Angle(-5,24,-25),
	Angle(0,25,-26),
	Angle(0,0,2),
	Angle(0,0,0),
}

-- Inspect Assault

SWEP.InspectAnimLH = {
	Vector(0,0,0)
}
SWEP.InspectAnimLHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimRH = {
	Vector(0,0,0)
}
SWEP.InspectAnimRHAng = {
	Angle(0,0,0)
}
SWEP.InspectAnimWepAng = {
	Angle(0,0,0),
	Angle(15,15,15),
	Angle(15,15,24),
	Angle(15,15,24),
	Angle(15,15,24),
	Angle(15,7,24),
	Angle(10,3,-5),
	Angle(2,3,-15),
	Angle(0,4,-22),
	Angle(0,3,-45),
	Angle(0,3,-45),
	Angle(0,-2,-2),
	Angle(0,0,0)
}