local MODE = MODE

local deathmatch_nozone = ConVarExists("deathmatch_nozone") and GetConVar("deathmatch_nozone") or CreateConVar("deathmatch_nozone", 0, FCVAR_REPLICATED, "Allows to disable deathmatch mode zone.", 0, 1)

MODE.name = "dm"
MODE.PrintName = "KIROCITY Deathmatch REMAKE"
MODE.LootSpawn = false
MODE.GuiltDisabled = true
MODE.randomSpawns = true

MODE.ForBigMaps = false
MODE.Chance = 0.02

local radius = nil
local mapsize = 7500
-- MODE.MapSize = mapsize

util.AddNetworkString("dm_start")
util.AddNetworkString("dm_end")

function MODE:CanLaunch()
    return true//(zb.GetWorldSize() >= ZBATTLE_BIGMAP)
end

function MODE:Intermission()
	game.CleanUpMap()

	local poses = {}
	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ApplyAppearance(ply)
		ply:SetupTeam(0)
		table.insert(poses, ply:GetPos())
	end

	local centerpoint = Vector(0, 0, 0)
	for i, pos in ipairs(poses) do
		centerpoint:Add(pos)
	end
	centerpoint:Div(#poses)

	local dist = 0
	for i, pos in ipairs(poses) do
		local dist2 = pos:Distance(centerpoint)
		if dist < dist2 then
			dist = dist2
		end
	end

	zonepoint = centerpoint
	zonedistance = dist
	
	net.Start("dm_start")
		net.WriteVector(zonepoint)
		net.WriteFloat(zonedistance)
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
	}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#zb:CheckAlive(true) <= 1)
end

local loadouts = {
	{primary = "weapon_m9beretta", attachments = {{"supressor4"},{"holo16","laser3"},{"holo15","laser1"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_px4beretta", attachments = {{"supressor4"},{"supressor4"},""}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_mp-80", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_p22", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_colt9mm", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ptrd", attachments = "", armor = {}, ammo = 12},
	{primary = "weapon_draco", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_p90", attachments = {{"holo15","supressor4"},{"laser1","supressor4"},{"holo14","supressor4"}}, armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_ar_pistol", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_pm9", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_makarov", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_kar98", attachments = "", armor = {"vest3","helmet1"}, ammo = 23},
	{primary = "weapon_skorpion", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_draco", attachments = "", armor = {"vest1","helmet1"}, ammo = 3},
	{primary = "weapon_uzi", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_fn45", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},
	{primary = "weapon_remington870", attachments = "", armor = {"vest3","helmet1"}, ammo = 30},
	{primary = "weapon_ak203", attachments = "", armor = {"vest3","helmet1"}, ammo = 3},	
}

local randomGrenades = {"weapon_hg_rgd_tpik", "weapon_hg_pipebomb_tpik", "weapon_hg_smokenade_tpik", "weapon_hg_flashbang_tpik"}
local randomMedicine = {"weapon_bandage_sh", "weapon_bigbandage_sh", "weapon_medkit_sh", "weapon_fentanyl", "weapon_morphine", "weapon_adrenaline", "weapon_tourniquet"}
local randomMelees = {"weapon_melee", "weapon_pocketknife"}

local function MakeDissolver(ent, position, dissolveType)
    local Dissolver = ents.Create("env_entity_dissolver")
    timer.Simple(5, function()
        if IsValid(Dissolver) then Dissolver:Remove() end
    end)
	if !IsValid(Dissolver) then return end
    Dissolver.Target = "dissolve"..ent:EntIndex()
    Dissolver:SetKeyValue("dissolvetype", dissolveType)
    Dissolver:SetKeyValue("magnitude", 0)
    Dissolver:SetPos(position)
    Dissolver:SetPhysicsAttacker(ent)
    Dissolver:Spawn()
    ent:SetName(Dissolver.Target)
	ent:Fire("Open")
    Dissolver:Fire("Dissolve", Dissolver.Target, 0)
    Dissolver:Fire("Kill", "", 0.1)
    return Dissolver
end

function MODE:RoundStart()
	local loadout = loadouts[math.random(#loadouts)]
	local selectedAttachments = istable(loadout.attachments) and table.Random(loadout.attachments) or loadout.attachments

	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		ply:Give("weapon_hands_sh")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)
		
		local gun = ply:Give(loadout.primary)
		if IsValid(gun) then
			ply:GiveAmmo(gun:GetMaxClip1() * loadout.ammo, gun:GetPrimaryAmmoType(), true)
			hg.AddAttachmentForce(ply, gun, selectedAttachments)
		end

		if loadout.secondary then
			local pistol = ply:Give(loadout.secondary)
			if IsValid(pistol) then
				ply:GiveAmmo(pistol:GetMaxClip1() * (loadout.ammo2 or 2), pistol:GetPrimaryAmmoType(), true)
			end
		end

		hg.AddArmor(ply, loadout.armor)
		ply:Give(loadout.melee or randomMelees[math.random(#randomMelees)])

		if not loadout.noGrenade then
			local grenadeCount = math.random(1, 2)
			local usedGrenades = {}
			for i = 1, grenadeCount do
				local grenade = randomGrenades[math.random(#randomGrenades)]
				while usedGrenades[grenade] and i > 1 do
					grenade = randomGrenades[math.random(#randomGrenades)]
				end
				usedGrenades[grenade] = true
				ply:Give(grenade)
			end
		end

		if loadout.medicine then
			for i = 1, (loadout.medicineCount or 1) do
				ply:Give(loadout.medicine[math.random(#loadout.medicine)])
			end
		elseif loadout.randomMedicine then
			for i = 1, math.random(1, 2) do
				ply:Give(randomMedicine[math.random(#randomMedicine)])
			end
		else
			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
		end

		ply:Give("weapon_walkie_talkie")
		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then ply.organism.recoilmul = 0.5 end

		timer.Simple(0.1, function() ply.noSound = false end)
		ply:SetSuppressPickupNotices(false)
		zb.GiveRole(ply, "Fighter", Color(190,15,15))
		ply:SetNetVar("CurPluv", "pluvboss")
	end
end

local cooldown = CurTime()
hook.Add("Think","bober",function(ply)
	local rnd = CurrentRound()
	if not rnd or rnd.name != "dm" then return end
	if (zb.ROUND_START or CurTime()) + 20 > CurTime() then return end
	if cooldown > CurTime() then return end
	if deathmatch_nozone:GetBool() then return end
	cooldown = CurTime() + 0.5

	local pos = zonepoint
	local radius = MODE.GetZoneRadius()
	local radiussqr = radius * radius
	
	for i, ent in ents.Iterator() do
		if pos:DistToSqr(ent:GetPos()) > radiussqr then
			if ent:IsPlayer() then
				hg.LightStunPlayer(ent)
				
				continue
			end

			if hgIsDoor(ent) then
				if !ent:GetNoDraw() then
					hgBlastThatDoor(ent)
				end

				continue
			end
			
			if string.find(ent:GetClass(), "prop_") and !hg.expItems[ent:GetModel()] then
				MakeDissolver(ent, ent:GetPos(), 0)
			end
		end
	end
end)

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end

function MODE:RoundThink()
end

function MODE:PlayerDeath(ply)
	if zb.ROUND_STATE == 1 then
		ply:GiveSkill(-0.1)
	end
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	local playersharm = {}
	for ply, tbl in pairs(zb.HarmDone) do
		for attacker, harm in pairs(tbl) do
			playersharm[attacker] = (playersharm[attacker] or 0) + harm
		end
	end

	local most_violent_player
	local curharm = 0
	for ply, harm in pairs(playersharm) do
		if harm > curharm then
			most_violent_player = ply
			curharm = harm
		end
	end

	timer.Simple(2,function()
		net.Start("dm_end")
		local ent = zb:CheckAlive(true)[1]
		
		if IsValid(ent) then
			ent:GiveExp(math.random(150,200))
			ent:GiveSkill(math.Rand(0.2,0.3))
		end

		if IsValid(most_violent_player) then
			most_violent_player:GiveExp(math.random(150,200))
			most_violent_player:GiveSkill(math.Rand(0.2,0.3))
		end

		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.WriteEntity(IsValid(most_violent_player) and most_violent_player or NULL)
		net.Broadcast()
	end)
end