SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "FN P90"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Submachine gun chambered in 5.7x28 mm\n\nRate of fire 1000 rounds per minute"
SWEP.Category = "Weapons - Machine-Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/pwb2/weapons/w_p90.mdl"
//SWEP.WorldModelFake = "models/weapons/zcity/v_p90_pdw.mdl" -- Контент инсурги https://steamcommunity.com/sharedfiles/filedetails/?id=3437590840 models/weapons/zcity/v_416c.mdl
--uncomment for funny
SWEP.FakePos = Vector(0, 3.68, 7.8)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-25.17,2.4,0)
SWEP.AttachmentAng = Angle(0,0,0)
//SWEP.MagIndex = 53
//MagazineSwap
--Entity(1):GetActiveWeapon():GetWM():SetSubMaterial(0,"NULL")

SWEP.FakeReloadSounds = {
	[0.25] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.27] = "weapons/m4a1/m4a1_magout.wav",
	[0.69] = "weapons/m4a1/m4a1_magain.wav",
	[0.83] = "weapons/m4a1/m4a1_hit.wav"
}

SWEP.FakeEmptyReloadSounds = {
	[0.22] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.25] = "weapons/m4a1/m4a1_magout.wav",
	[0.37] = "weapons/m4a1/m4a1_magrelease.wav",
	[0.65] = "weapons/m4a1/m4a1_magain.wav",
	[0.77] = "weapons/m4a1/m4a1_hit.wav",
	[0.95] = "weapons/m4a1/m4a1_boltarelease.wav",
}

SWEP.MagModel = "models/weapons/upgrades/w_magazine_m1a1_30.mdl"

local vector_full = Vector(1,1,1)
local vecPochtiZero = Vector(0.01,0.01,0.01)
SWEP.FakeReloadEvents = {
	[0.3] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			hg.CreateMag( self )
			self:GetWM():ManipulateBoneScale(75, vecPochtiZero)
			self:GetWM():ManipulateBoneScale(76, vecPochtiZero)
			self:GetWM():ManipulateBoneScale(77, vecPochtiZero)
		end 
	end,
	[0.31] = function( self, timeMul ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1.5 * timeMul, self.MagModel, {Vector(-2,-3,0), Angle(180,-180,90), 75, Vector(0,4.8,-1.8), Angle(-15,-90,180)})
		end 
	end,
	[0.57] = function( self ) 
		if CLIENT and self:Clip1() < 1 then
			self:GetWM():ManipulateBoneScale(75, vector_full)
			self:GetWM():ManipulateBoneScale(76, vector_full)
			self:GetWM():ManipulateBoneScale(77, vector_full)
		end 
	end,
}

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "base_reload",
	["reload_empty"] = "base_reloadempty",
}


SWEP.WepSelectIcon2 = Material("pwb2/vgui/weapons/p90.png")
SWEP.IconOverride = "entities/weapon_pwb2_p90.png"

SWEP.weight = 2.5

SWEP.ShockMultiplier = 2

SWEP.StartAtt = {"holo4"}

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(1, 8, -4)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.LocalMuzzlePos = Vector(16.731,0.007,4.445)
SWEP.LocalMuzzleAng = Angle(0,-0.026,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = "556x45"
--SWEP.EjectPos = Vector(0,5,5)
--SWEP.EjectAng = Angle(0,-90,0)
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.7x28 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 32
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 25
SWEP.animposmul = 2.5
SWEP.Primary.Sound = {"homigrad/weapons/pistols/p90-1.wav", 75, 120, 130}
SWEP.Primary.Wait = 0.05
SWEP.ReloadTime = 6.3
SWEP.ReloadSoundes = {
	"none",
	"none",
	"none",
	"pwb2/weapons/p90/magout.wav",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"none",
	"pwb2/weapons/p90/magin.wav",
	"none",
	"none",
	"pwb2/weapons/p90/bolt.wav",
	"none",
	"none",
	"none",
	"none",
	"none"
}

SWEP.PPSMuzzleEffect = "muzzleflash_m14" -- shared in sh_effects.lua

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-3, 0.3808, 7.956)
SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = false
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.0, 0.0, 0)
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Spray = {}
for i = 1, 50 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.01, math.cos(i * 8) * 0.02, 0) * 1
end
SWEP.randmul = 0.9

SWEP.Ergonomics = 1.1
SWEP.Penetration = 10
SWEP.AimHands = Vector(-4, 0.65, -3.1)
SWEP.WorldPos = Vector(-4, -0.6, 1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.size = 0.0006
SWEP.holo_pos = Vector(-0.97, 4.3, 8)
SWEP.scale = Vector(1, 1.1, 1)
SWEP.holo = Material("holo/huy-collimator6.png")
SWEP.holo_size = 0.25
SWEP.scale2 = 1.1
if CLIENT then
	function SWEP:DrawHUDAdd()
	end
end

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0,0,0), {}},
		[2] = {"supressor4", Vector(0,0,0), {}},
		["mount"] = Vector(-1.6,0.25,-0.5),
	},
	sight = {
		["empty"] = {
			"empty",
			{
				[4] = "null",
				[5] = "null"
			},
		},
		["mountType"] = "picatinny",
		["mount"] = Vector(-5, 3.4, -0.33),
		["removehuy"] = {
			[4] = "null",
			[5] = "null"
		}
	},
	underbarrel = {
		["mount"] = {["picatinny_small"] = Vector(10, 2.35, -2.4),["picatinny"] = Vector(5,0,0)},
		["mountAngle"] = {["picatinny_small"] = Angle(0, 0, 180),["picatinny"] = Angle(0, 0, 0)},
		["mountType"] = {"picatinny_small","picatinny"},
		["removehuy"] = {
			["picatinny"] = {
				[2] = "null"
			},
			["picatinny_small"] = {
			}
		}
	}
}

SWEP.lengthSub = 30
SWEP.handsAng = Angle(-10, 8, 0)
SWEP.DistSound = "mp5k/mp5k_dist.wav"

--local to head
SWEP.RHPos = Vector(6,-7.5,3.5)
SWEP.RHAng = Angle(0,-10,90)
--local to rh
SWEP.LHPos = Vector(5,0,-3.5)
SWEP.LHAng = Angle(-15,-10,-90)

local finger1 = Angle(15,15,0)
local finger2 = Angle(-15,0,-5)

function SWEP:AnimHoldPost(model)
	self:BoneSet("l_finger0", vector_zero, finger1)
    self:BoneSet("l_finger02", vector_zero, finger2)
end

-- RELOAD ANIM AKM
SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(-5,0,5),
	Vector(-6,2,7),
	Vector(-5,4,1),
	Vector(-5,4,-7),
	Vector(-5,4,-15),
	Vector(-6,2,7),
	Vector(-5,0,5),
	Vector(-5,0,5),
	Vector(-4,0,4),
	Vector(-4,0,3),
	Vector(-3,0,3),
	"fastreload",
	Vector(12,4,2),
	Vector(8,4,2),
	Vector(-8,4,2),
	"reloadend",
	Vector(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}

SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,-90,90),
	Angle(0,0,0),
}

SWEP.ReloadAnimRHAng = {
	Angle(0,0,0),
}

SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(25,35,25),
	Angle(25,35,26),
	Angle(25,35,27),
	Angle(25,35,26),
	Angle(25,35,25),
	Angle(25,35,24),
	Angle(25,35,25),
	Angle(-5,-15,-15),
	Angle(-10,-5,-15),
	Angle(15,-15,-15),
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