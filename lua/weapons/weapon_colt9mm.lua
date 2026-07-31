SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Colt 9mm SMG"
SWEP.Author = "Colt's Manufacturing Company"
SWEP.Instructions = "AR15 pistol chambered in 9x19 mm\n\nALT+E to change stance (+walk,+use)"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/ar15/w_smg_635.mdl"

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,10,5)
SWEP.EjectAng = Angle(-55,80,0)

SWEP.ScrappersSlot = "Primary"

SWEP.WepSelectIcon2 = Material("scrappers/colt9.png")
SWEP.IconOverride = "scrappers/colt9.png"
--models/ar15/w_smg_635.mdl
--models/ar15/w_colt6149.mdl
--models/ar15/w_kacmark012.mdl
--models/ar15/w_kacmark011.mdl
--models/ar15/w_ares_shrikemg.mdl
--models/ar15/w_magpulm.mdl
--models/ar15/w_kac_s47.mdl
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 32
SWEP.Primary.DefaultClip = 32
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"m16a4/m16a4_fp.wav", 75, 120, 130}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 4.3
SWEP.bigNoDrop = true
SWEP.podkid = 0.4

SWEP.punchmul = 2
SWEP.punchspeed = 1

SWEP.ReloadSoundes = {
	"none",
	"none",
	"weapons/tfa_ins2/mp5k/mp5k_magout.wav",
	"none",
	"none",
	"weapons/tfa_ins2/browninghp/magin.wav",
	"weapons/tfa_ins2/browninghp/maghit.wav",
	"weapons/tfa_ins2/browninghp/boltback.wav",
	"none",
	"weapons/tfa_ins2/browninghp/boltrelease.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.LocalMuzzlePos = Vector(25.426,0.32,5.341)
SWEP.LocalMuzzleAng = Angle(-0.0,-0,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, 0.389, 7.8962)
SWEP.RHandPos = Vector(2, -1, 1)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.00, -0.02, 0), Angle(-0.01, 0.02, 0)}
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-2.5, -1, 0.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 2
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0.38, -0.1, 0)
function SWEP:ModelCreated(model)
	self:SetBodyGroups("01")
end

SWEP.weight = 3
SWEP.addweight = -1.5
SWEP.PistolKinda = true

local recoilAng1 = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
local recoilAng2 = {Angle(-0.015, -0.015, 0), Angle(-0.025, 0.015, 0)}
if SERVER then
	util.AddNetworkString("send_huyhuy3")
else
	net.Receive("send_huyhuy3", function(len)
		local self = net.ReadEntity()
		local twohands = net.ReadBool()
		self.HoldType = twohands and "ar2" or "revolver"
		self.SprayRand = twohands and recoilAng1 or recoilAng2
		self.AnimShootHandMul = twohands and 0.25 or 1

		self.RHPos = not twohands and Vector(14,-5,4) or Vector(7,-7,5)
		self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-10,90)

		self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(5,-1.5,-3)
		self.LHAng = not twohands and Angle(-0,0,-100) or Angle(0,0,-90)
	end)
end

function SWEP:Step()
	self:CoreStep()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if hg.KeyDown(owner, IN_WALK) and hg.KeyDown(owner, IN_USE) then
		if not self.huybut then
			if SERVER then
				local twohands = self:IsPistolHoldType()
				self.HoldType = twohands and "ar2" or "revolver"
				self.SprayRand = twohands and recoilAng1 or recoilAng2
				self.AnimShootHandMul = twohands and 0.25 or 1
				self.RHPos = not twohands and Vector(14,-5,4) or Vector(7,-7,5)
				self.RHAng = not twohands and Angle(0,0,90) or Angle(0,-10,90)
		
				self.LHPos = not twohands and Vector(-1,-2,-3) or Vector(5,-1.5,-3)
				self.LHAng = not twohands and Angle(-0,0,-100) or Angle(0,0,-90)
				net.Start("send_huyhuy3")
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

SWEP.lengthSub = 5
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredPos = Vector(5, 8, -6)
SWEP.holsteredAng = Angle(-150, -10, 180)


SWEP.RHPos = Vector(14,-5,4)
SWEP.RHAng = Angle(0,0,90)

SWEP.LHPos = Vector(-1,-2,-3)
SWEP.LHAng = Angle(-0,0,-100)

--RELOAD ANIMS SMG????

SWEP.ReloadAnimLH = {
	Vector(0,0,0),
	Vector(0,-2,-2),
	Vector(-15,5,-7),
	Vector(-15,5,-15),
	Vector(0,0,0),
	Vector(0,0,0),
	Vector(0,0,0),
	"fastreload",
	Vector(5,0,5),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(-2,1,1),
	Vector(0,0,0),
	"reloadend",
	Vector(0,0,0)
}
SWEP.ReloadAnimLHAng = {
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(0,0,0),
	Angle(-35,0,0),
	Angle(-55,0,0),
	Angle(-75,0,0),
	Angle(-75,0,0),
	Angle(-75,0,0),
	Angle(-25,0,0),
	Angle(0,0,0),
}

SWEP.ReloadAnimRH = {
	Vector(0,0,0)
}
SWEP.ReloadAnimRHAng = {
	Angle(0,0,0)
}
SWEP.ReloadAnimWepAng = {
	Angle(0,0,0),
	Angle(0,25,25),
	Angle(15,25,25),
	Angle(-25,25,25),
	Angle(0,0,-25),
	Angle(0,0,-35),
	Angle(-25,0,-25),
	Angle(-15,0,-15),
	Angle(0,0,0)
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