hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}

hg.achievements.MenuPanel = hg.achievements.MenuPanel or nil
hg.achievements.DetailPanel = hg.achievements.DetailPanel or nil

local curent_panel_ach
concommand.Add("hg_achievements", function()
	print("use esc menu")
end)

BlurBackground = BlurBackground or hg.DrawBlur
local gradient_u = Material("vgui/gradient-u")
local gradient_d = Material("vgui/gradient-d")
local gradient_l = Material("vgui/gradient-l")
local fallback_img = Material("homigrad/vgui/models/star.png")
local xbars = 17
local ybars = 30

local function ResolveAchMaterial(img)
	if isstring(img) and img ~= "" then
		local mat = Material(img)
		if mat and not mat:IsError() then return mat end
	elseif type(img) == "IMaterial" then
		return img
	end
	return fallback_img
end

local function PaintButton(self, w, h)
	surface.SetDrawColor(155, 0, 0, 108)
	if gradient_l and not gradient_l:IsError() then
		surface.SetMaterial(gradient_l)
		surface.DrawTexturedRect(0, 0, w, h)
	else
		surface.DrawRect(0, 0, w, h)
	end
end

-- Left ESC nav dock is ScrW()/4 and transparent — keep achievements clear of it
local function GetContentLeft()
	return math.floor(ScrW() / 4) + ScreenScale(8)
end

local function createButton_2(frame, ach, text, func, y)
	local button = vgui.Create("DButton", frame)

	ach.img = ResolveAchMaterial(ach.img)

	function button:Paint(w, h)
		PaintButton(self, w, h)

		local localach = hg.achievements.GetLocalAchievements()
		local val = localach[ach.key] and localach[ach.key].value or ach.start_value or 0
		local needed = ach.needed_value or 1

		surface.SetFont("HomigradFont")

		self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, curent_panel_ach == ach and 1 or 0)

		local base = (curent_panel_ach == ach and string.upper(ach.name or "") or (ach.name or ""))
			.. (ach.showpercent and (" | " .. math.Round(val / needed * 100) .. "%") or "")

		local result = ""
		for i = 1, #base do
			result = result .. (i <= math.ceil(#base * self.HoverLerp) and string.upper(base:sub(i, i)) or base:sub(i, i))
		end

		local _, ht = surface.GetTextSize(result)
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(ScreenScale(4), math.max(0, (h - ht) / 2))
		surface.DrawText(result)
	end

	button:SetText("")
	button:SetSize(frame:GetWide(), ScreenScale(22))
	button:SetPos(0, y)
	button.DoClick = function(self)
		curent_panel_ach = ach
		func(self)
		for i = 1, 3 do
			surface.PlaySound("shitty/tap_depress.wav")
		end
	end
	return button
end

local function ClearAchievementPanels()
	if IsValid(hg.achievements.MenuPanel) then
		hg.achievements.MenuPanel:Remove()
	end
	if IsValid(hg.achievements.DetailPanel) then
		hg.achievements.DetailPanel:Remove()
	end
	hg.achievements.MenuPanel = nil
	hg.achievements.DetailPanel = nil
end

function hg.DrawAchievmentsMenu(ParentPanel)
	if not IsValid(ParentPanel) then
		print("[hg.achievements] DrawAchievmentsMenu requires a valid parent panel (open via ESC menu).")
		return
	end

	hg.achievements.LoadAchievements()
	ClearAchievementPanels()

	local left = GetContentLeft()
	local gap = ScreenScale(6)
	local contentW = math.max(ScreenScale(200), ParentPanel:GetWide() - left - ScreenScale(10))
	local listW = math.floor(contentW * 0.40)
	local detailW = math.floor(contentW * 0.58)
	local panelH = math.min(ScreenScale(22) * 8.25 + ScreenScale(2.5), ParentPanel:GetTall() * 0.72)
	local panelY = math.floor(ParentPanel:GetTall() / 2 - panelH / 2)

	-- Only paint the content region (do not cover the left nav / KIRO CITY title)
	ParentPanel:SetAlpha(0)
	ParentPanel.Paint = function(self, w, h)
		local x0 = GetContentLeft()
		local cw = w - x0

		surface.SetDrawColor(28, 28, 28, 240)
		surface.DrawRect(x0, 0, cw, h)

		surface.SetDrawColor(107, 107, 107, 20)
		for i = 1, (ybars + 1) do
			surface.DrawRect(x0 + (cw / ybars) * i - (CurTime() * 30 % (cw / ybars)), 0, ScreenScale(1), h)
		end
		for i = 1, (xbars + 1) do
			surface.DrawRect(x0, (h / xbars) * (i - 1) + (CurTime() * 30 % (h / xbars)), cw, ScreenScale(1))
		end

		surface.SetDrawColor(0, 0, 0, 180)
		if gradient_l and not gradient_l:IsError() then
			surface.SetMaterial(gradient_l)
			surface.DrawTexturedRect(x0, 0, ScreenScale(3), h)
		end
	end

	if hg.DrawBlur then
		hg.DrawBlur(ParentPanel, 5)
	end
	ParentPanel:AlphaTo(255, 0.15, 0)

	local frame = vgui.Create("DPanel", ParentPanel)
	frame:SetSize(listW, panelH)
	frame:SetPos(left, panelY)
	frame.Paint = function() end
	frame:SetMouseInputEnabled(true)
	hg.achievements.MenuPanel = frame

	local scroll = vgui.Create("DScrollPanel", frame)
	scroll:Dock(FILL)
	frame.scroll = scroll

	local sbar = scroll:GetVBar()
	sbar:SetWide(ScreenScale(3))
	sbar:SetHideButtons(true)
	function sbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
	end
	function sbar.btnGrip:Paint(w, h)
		self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.2, (self:IsHovered() and 0.8 or 0.6))
		draw.RoundedBox(0, 0, 0, w, h, Color(100 * self.lerpcolor, 10, 10))
	end

	local function FillScroll(scrollPanel)
		scrollPanel:Clear()
		local y = 0
		local wide = frame:GetWide() - ScreenScale(4)
		local list = hg.achievements.achievements_data.created_achevements or {}

		local ordered = {}
		for _, ach in pairs(list) do
			ordered[#ordered + 1] = ach
		end
		table.sort(ordered, function(a, b)
			return tostring(a.name or "") < tostring(b.name or "")
		end)

		for _, ach in ipairs(ordered) do
			local bbb = createButton_2(scrollPanel, ach, ach.name, function() end, y)
			bbb:SetWide(wide)
			y = bbb:GetTall() + y + 3
			scrollPanel:AddItem(bbb)
			if not curent_panel_ach then
				curent_panel_ach = ach
			end
		end
	end

	function frame:UpdateValues()
		if IsValid(self.scroll) then
			FillScroll(self.scroll)
		end
	end

	FillScroll(scroll)

	local frame2 = vgui.Create("DPanel", ParentPanel)
	frame2:SetSize(detailW, panelH)
	frame2:SetPos(left + listW + gap, panelY)
	frame2:SetMouseInputEnabled(true)
	hg.achievements.DetailPanel = frame2

	frame2.Paint = function(self, w, h)
		surface.SetDrawColor(92, 0, 0, 108)
		surface.SetMaterial(gradient_d)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(40, 36, 36, 255)
		surface.DrawRect(0, h - h / 6, w, h / 6)
		surface.SetDrawColor(22, 21, 21)
		surface.DrawRect(0, h - 3, w, 3)

		if not curent_panel_ach then return end

		self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, 1)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(ResolveAchMaterial(curent_panel_ach.img))
		local icon = math.min(w, h) * 0.28
		surface.DrawTexturedRect(w / 2 - icon / 2, h * 0.28 - icon / 2, icon, icon)

		surface.SetFont("ZCity_Small")
		local name = curent_panel_ach.name or ""
		local res = ""
		for i = 1, #name do
			res = res .. (i <= math.ceil(#name * self.HoverLerp) and name:sub(i, i) or "")
		end
		local wt, ht = surface.GetTextSize(res)
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(w / 2 - wt / 2, h - h / 6)
		surface.DrawText(res)

		surface.SetFont("ZCity_Tiny")
		local desc = curent_panel_ach.description or ""
		local res2 = ""
		for i = 1, #desc do
			res2 = res2 .. (i <= math.ceil(#desc * self.HoverLerp) and desc:sub(i, i) or "")
		end
		local lines = string.Explode("\n", res2:gsub("\\n", "\n"))
		surface.SetTextColor(170, 170, 170)
		local lnh = math.max(ht / 2, ScreenScale(6))
		for i, line in ipairs(lines) do
			local lwt = surface.GetTextSize(line)
			surface.SetTextPos(w / 2 - lwt / 2, h - h / 12 + (i - 1) * lnh)
			surface.DrawText(line)
		end
	end

	-- Keep ESC left nav clickable / on top
	if IsValid(MainMenu) and MainMenu.BringNavToFront then
		MainMenu:BringNavToFront()
	end
end

local time_wait = 0
function hg.achievements.LoadAchievements()
	if time_wait > CurTime() then return end
	time_wait = CurTime() + 2

	net.Start("req_ach")
	net.SendToServer()
end

function hg.achievements.GetLocalAchievements()
	local ply = LocalPlayer()
	if not IsValid(ply) then return {} end
	local sid = tostring(ply:SteamID())
	local data = hg.achievements.achievements_data.player_achievements[sid]
	if not istable(data) then
		data = {}
		hg.achievements.achievements_data.player_achievements[sid] = data
	end
	return data
end

net.Receive("req_ach", function()
	hg.achievements.achievements_data.created_achevements = net.ReadTable() or {}
	local ply = LocalPlayer()
	if IsValid(ply) then
		hg.achievements.achievements_data.player_achievements[tostring(ply:SteamID())] = net.ReadTable() or {}
	else
		net.ReadTable()
	end

	if IsValid(hg.achievements.MenuPanel) and hg.achievements.MenuPanel.UpdateValues then
		hg.achievements.MenuPanel:UpdateValues()
	end
end)

hg.achievements.NewAchievements = hg.achievements.NewAchievements or {}
local AchTable = hg.achievements.NewAchievements
net.Receive("hg_NewAchievement", function()
	local Ach = { time = CurTime() + 7.5, name = net.ReadString(), img = net.ReadString() }
	table.insert(AchTable, 1, Ach)
	surface.PlaySound("homigrad/vgui/achievement_earned.wav")
end)

local ach_clr2 = Color(100, 25, 25)
hook.Add("HUDPaint", "hg_NewAchievement", function()
	local frametime = FrameTime() * 10
	for i = #AchTable, 1, -1 do
		local ach = AchTable[i]
		if not ach then continue end

		local txt = "Achievement! " .. (ach.name or "")
		ach.img = ResolveAchMaterial(ach.img)

		surface.SetFont("HomigradFontMedium")
		local wt = surface.GetTextSize(txt)

		ach.Lerp = Lerp(frametime, ach.Lerp or 0, math.min(ach.time - CurTime(), 1) * i)
		local WSize = (ScrW() * 0.1) + wt
		local HSize = ScrH() * 0.05
		local HPos = ScrH() - (HSize * ach.Lerp)

		draw.RoundedBox(0, 2, HPos + 2, WSize - 4, HSize - 4, ach_clr2)

		surface.SetDrawColor(155, 0, 0, 255)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect(0, HPos, WSize, HSize)

		surface.SetDrawColor(150, 0, 0, 255)
		surface.DrawOutlinedRect(0, HPos, WSize, HSize, 2.5)

		surface.SetFont("HomigradFontMedium")
		surface.SetTextColor(255, 255, 255)
		surface.SetTextPos(HSize * 1.25, (HPos + (HSize / 2) - (HSize / 4)))
		surface.DrawText(txt)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(ach.img)
		surface.DrawTexturedRect(2, HPos + 2, HSize - 4, HSize - 4)

		if ach.time < CurTime() then
			table.remove(AchTable, i)
		end
	end
end)
