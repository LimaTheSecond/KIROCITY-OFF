local PANEL = {}
local curent_panel
local red_select = Color(105, 105, 105)

DISCORD_URL = "https://discord.gg/DrmtAyb3dy"
WEBSITE_URL = "https://kirocity.vercel.app/"

local function NormalizeWebsiteURL(url)
    url = string.Trim(tostring(url or ""))
    if url == "" then return WEBSITE_URL end
    if not string.match(url, "^[%w]+://") then
        url = "https://" .. url
    end
    return url
end

function hg.DrawWebsite(parent, startUrl)
    if not IsValid(parent) then return end

    local leftPad = math.floor(ScrW() / 4)
    local pad = ScreenScale(10)
    local barH = ScreenScale(18)
    local url = NormalizeWebsiteURL(startUrl or WEBSITE_URL)

    parent:SetMouseInputEnabled(true)
    parent:SetAlpha(0)
    parent.Paint = function(self, w, h)
        surface.SetDrawColor(18, 18, 18, 220)
        surface.DrawRect(leftPad, 0, w - leftPad, h)
    end
    parent:AlphaTo(255, 0.15, 0)

    local root = vgui.Create("DPanel", parent)
    root:SetPos(leftPad + pad, pad)
    root:SetSize(ScrW() - leftPad - pad * 2, ScrH() - pad * 2)
    root:SetPaintBackground(false)

    local bar = vgui.Create("DPanel", root)
    bar:Dock(TOP)
    bar:SetTall(barH)
    bar:DockMargin(0, 0, 0, ScreenScale(4))
    bar:SetPaintBackground(false)

    local btnOpen = vgui.Create("DButton", bar)
    btnOpen:Dock(RIGHT)
    btnOpen:SetWide(ScreenScale(52))
    btnOpen:SetFont("ZCity_Tiny")
    btnOpen:SetText("BROWSER")
    btnOpen:DockMargin(ScreenScale(3), 0, 0, 0)

    local btnGo = vgui.Create("DButton", bar)
    btnGo:Dock(RIGHT)
    btnGo:SetWide(ScreenScale(28))
    btnGo:SetFont("ZCity_Tiny")
    btnGo:SetText("GO")
    btnGo:DockMargin(ScreenScale(3), 0, 0, 0)

    local btnReload = vgui.Create("DButton", bar)
    btnReload:Dock(LEFT)
    btnReload:SetWide(ScreenScale(28))
    btnReload:SetFont("ZCity_Tiny")
    btnReload:SetText("↻")
    btnReload:DockMargin(0, 0, ScreenScale(3), 0)

    local entry = vgui.Create("DTextEntry", bar)
    entry:Dock(FILL)
    entry:SetFont("ZCity_Tiny")
    entry:SetText(url)
    entry:SetUpdateOnType(true)
    entry:SetDrawLanguageID(false)

    local html = vgui.Create("DHTML", root)
    html:Dock(FILL)
    html:SetAllowLua(false)
    html:OpenURL(url)

    local function Navigate(target)
        target = NormalizeWebsiteURL(target or entry:GetValue())
        entry:SetText(target)
        html:OpenURL(target)
        surface.PlaySound("homigrad/vgui/panorama/submenu_select_01.wav")
    end

    function btnGo:DoClick()
        Navigate(entry:GetValue())
    end

    function btnReload:DoClick()
        Navigate(entry:GetValue())
    end

    function btnOpen:DoClick()
        gui.OpenURL(NormalizeWebsiteURL(entry:GetValue()))
    end

    function entry:OnEnter()
        Navigate(self:GetValue())
    end

    function html:OnDocumentReady(docUrl)
        if isstring(docUrl) and docUrl ~= "" and docUrl ~= "about:blank" then
            entry:SetText(docUrl)
        end
    end

    local function StyleToolBtn(btn)
        function btn:Paint(w, h)
            local hovered = self:IsHovered()
            draw.RoundedBox(4, 0, 0, w, h, hovered and Color(70, 70, 70, 230) or Color(40, 40, 40, 220))
            surface.SetDrawColor(120, 120, 120)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
        end
    end
    StyleToolBtn(btnGo)
    StyleToolBtn(btnReload)
    StyleToolBtn(btnOpen)

    function entry:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(28, 28, 28, 240))
        surface.SetDrawColor(90, 90, 90)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(Color(230, 230, 230), Color(80, 80, 80), Color(230, 230, 230))
    end

    return html
end

local Selects = {
    {Title = "Disconnect", Func = function(luaMenu) RunConsoleCommand("disconnect") end},
    {Title = "Main Menu", Func = function(luaMenu) gui.ActivateGameUI() luaMenu:Close() end},
    {Title = "Traitor Role",
    GamemodeOnly = true,
    CreatedFunc = function(self, parent, luaMenu)
        local btn = vgui.Create( "DLabel", self )
        btn:SetText( "SOE" )
        btn:SetMouseInputEnabled( true )
        btn:SizeToContents()
        btn:SetFont( "ZCity_Small" )
        btn:SetTall( ScreenScale( 15 ) )
        btn:Dock(BOTTOM)
        btn:DockMargin(ScreenScale(20),ScreenScale(10),0,0)
        btn:SetTextColor(Color(255,255,255))
        btn:InvalidateParent()
        btn.RColor = Color(225, 225, 225, 0)
        btn.WColor = Color(225, 225, 225, 255)
        btn.x = btn:GetX()

        function btn:DoClick()
            luaMenu:Close()
            hg.SelectPlayerRole(nil, "soe")
        end
    
        local selfa = self
        function btn:Think()
            self.HoverLerp = selfa.HoverLerp
            self.HoverLerp2 = LerpFT(0.2, self.HoverLerp2 or 0, self:IsHovered() and 1 or 0)
                
            self:SetTextColor(self.RColor:Lerp(self.WColor:Lerp(red_select, self.HoverLerp2), self.HoverLerp))
            self:SetX(self.x + ScreenScaleH(40) + self.HoverLerp * ScreenScaleH(50))
        end

        local btn = vgui.Create( "DLabel", btn )
        btn:SetText( "STD" )
        btn:SetMouseInputEnabled( true )
        btn:SizeToContents()
        btn:SetFont( "ZCity_Small" )
        btn:SetTall( ScreenScale( 15 ) )
        btn:Dock(BOTTOM)
        btn:DockMargin(0,ScreenScale(2),0,0)
        btn:SetTextColor(Color(255,255,255))
        btn:InvalidateParent()
        btn.RColor = Color(225, 225, 225, 0)
        btn.WColor = Color(225, 225, 225, 255)
        btn.x = btn:GetX()

        function btn:DoClick()
            luaMenu:Close()
            hg.SelectPlayerRole(nil, "standard")
        end
    
        function btn:Think()
            self.HoverLerp = selfa.HoverLerp
            self.HoverLerp2 = LerpFT(0.2, self.HoverLerp2 or 0, self:IsHovered() and 1 or 0)
    
            self:SetTextColor(self.RColor:Lerp(self.WColor:Lerp(red_select, self.HoverLerp2), self.HoverLerp))
            self:SetX(self.x + ScreenScaleH(35))
        end
    end,
    Func = function(luaMenu)
        
    end,
    },
    {Title = "Achievements", Func = function(luaMenu, pp)
        if isfunction(hg.DrawAchievmentsMenu) then
            hg.DrawAchievmentsMenu(pp)
        else
            notification.AddLegacy("Achievements menu not loaded", NOTIFY_ERROR, 3)
        end
    end},
    {Title = "Rules", Func = function(luaMenu,pp)
        if hg.DrawRules then hg.DrawRules(pp) end
    end},
    {Title = "Binds", Func = function(luaMenu,pp)
        if hg.DrawBinds then hg.DrawBinds(pp) end
    end},
    {Title = "Donate", Func = function(luaMenu) RunConsoleCommand("igs") end},
    {Title = "Settings", Func = function(luaMenu,pp) 
        hg.DrawSettings(pp) 
    end},
    {Title = "Discord", Func = function(luaMenu) luaMenu:Close() gui.OpenURL(DISCORD_URL)  end},
    {Title = "Website", Func = function(luaMenu, pp)
        if hg.DrawWebsite then
            hg.DrawWebsite(pp, WEBSITE_URL)
        else
            gui.OpenURL(WEBSITE_URL)
        end
    end},
    {Title = "Appearance", Func = function(luaMenu, pp)
        local fn = hg.CreateApperanceMenu or hg.CreateAppearanceMenu or hg._AppearanceMenuBase
        if not isfunction(fn) then
            notification.AddLegacy("Appearance menu not loaded", NOTIFY_ERROR, 3)
            return
        end
        local ok, err = pcall(fn, pp)
        if not ok then
            ErrorNoHalt("[ZCity] Appearance menu error: " .. tostring(err) .. "\n")
            if isfunction(hg._AppearanceMenuBase) and fn ~= hg._AppearanceMenuBase then
                pcall(hg._AppearanceMenuBase, pp)
            else
                notification.AddLegacy("Appearance mod broken - disable Z-City Appearance Mod", NOTIFY_ERROR, 5)
            end
        end
    end},
    {Title = "Return", Func = function(luaMenu) luaMenu:Close() end},
}

local ImmediateActions = {
    ["return"] = true,
    ["disconnect"] = true,
    ["main menu"] = true,
    ["discord"] = true,
    ["traitor role"] = true,
}

local splasheh = {
    'KIROGRAD DEAD',
    'OKIRO BOTIK',
    'OKIRO BOT BECAUSE SLIV KIROGRAD',
    'YA BOTARA',
    't.me/ok1rohgzcitypro',
    'https://discord.gg/2X9pgvVZ8',
    'HOP ON K-CITY',
    'okiro K-CITY',
    'I feel... GREAT',
    'OG LIL NIGGA',
    'RUBI FURRY',
    'OwO',
    'Say no to cheats!',
    'KILL EVERYONE'
}

surface.CreateFont("ZC_MM_Title", {
    font = "Bahnschrift",
    size = ScreenScale(42),
    weight = 800,
    antialias = true
})

local Pluv = Material("pluv/pluvkid.jpg")

function PANEL:InitializeMarkup()
	local mapname = game.GetMap()
	local prefix = string.find(mapname, "_")
	if prefix then
		mapname = string.sub(mapname, prefix + 1)
	end
	local gm = splasheh[math.random(#splasheh)] .. " | " .. string.NiceName(mapname) 

    if hg.PluvTown and hg.PluvTown.Active then
        local text = "<font=ZC_MM_Title><colour=105, 105, 105>    </colour>City</font>\n<font=ZCity_Tiny><colour=105, 105, 105>" .. gm .. "</colour></font>"

        self.SelectedPluv = table.Random(hg.PluvTown.PluvMats)

        return markup.Parse(text)
    end

    local text = "<font=ZC_MM_Title><colour=105, 105, 105>KIRO</colour>CITY</font>\n<font=ZCity_Tiny><colour=105, 105, 105>" .. gm .. "</colour></font>"
    return markup.Parse(text)
end

local color_red = Color(105, 105, 105)
local clr_gray = Color(105, 105, 105)
local clr_verygray = Color(0, 0, 0)

function PANEL:ForceFullscreen()
    self:SetPos(0, 0)
    self:SetSize(ScrW(), ScrH())
    if self.DockPadding then self:DockPadding(0, 0, 0, 0) end
    if self.SetSizable then self:SetSizable(false) end
end

function PANEL:BringNavToFront()
    if IsValid(self.lDock) then self.lDock:MoveToFront() end
    if IsValid(self.rightCredits) then self.rightCredits:MoveToFront() end
end

function PANEL:CreatePanelParent()
    local pp = vgui.Create("DPanel", self)
    pp:SetPos(0, 0)
    pp:SetSize(ScrW(), ScrH())
    pp:SetMouseInputEnabled(false)
    pp:SetPaintBackground(false)
    pp.Paint = function(this, w, h) end
    self.panelparrent = pp
    self:BringNavToFront()
    return pp
end

function PANEL:ResetPanelParent(onReady)
    local old = self.panelparrent
    local menu = self
    local token = (self._ppToken or 0) + 1
    self._ppToken = token

    local function finish()
        if not IsValid(menu) or menu._ppToken ~= token then return end
        local pp = menu:CreatePanelParent()
        if onReady then onReady(pp) end
    end

    if IsValid(old) then
        old:Stop()
        old:AlphaTo(0, 0.2, 0, function()
            if IsValid(old) then old:Remove() end
            if IsValid(menu) and menu.panelparrent == old then
                menu.panelparrent = nil
            end
            finish()
        end)
    else
        finish()
    end
end

function PANEL:Init()
    self:SetAlpha(0)
    self:ForceFullscreen()
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetBorder(false)
    self:SetColorBG(clr_verygray)
    self:ShowCloseButton(false)
    curent_panel = nil
    self.Title, self.TitleShadow = self:InitializeMarkup()

    timer.Simple(0, function()
        if not IsValid(self) then return end
        self:ForceFullscreen()
        if self.First then
            self:First()
        end
    end)

    self.lDock = vgui.Create("DPanel", self)
    local lDock = self.lDock
    lDock:Dock(LEFT)
    lDock:SetWide(ScrW() / 4)
    lDock:DockMargin(0, 0, 0, 0)
    lDock:DockPadding(0, ScreenScaleH(40), 0, ScreenScaleH(12))
    lDock:SetPaintBackground(false)
    lDock.Paint = function(this, w, h)
        if hg.PluvTown and hg.PluvTown.Active then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.SelectedPluv or Pluv)
            surface.DrawTexturedRect(0, ScreenScale(42), ScreenScale(35), ScreenScale(27))
        end

        if self.Title then
            self.Title:Draw(ScreenScale(15), ScreenScale(70), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 255, TEXT_ALIGN_LEFT)
        end
    end

    -- Left footer (default): Release + GitHub under the nav.
    local bottomDock = vgui.Create("DPanel", lDock)
    bottomDock:Dock(BOTTOM)
    bottomDock:DockMargin(0, ScreenScaleH(8), 0, 0)
    bottomDock:SetTall(ScreenScaleH(41))
    bottomDock:SetPaintBackground(false)
    bottomDock.Paint = function(this, w, h) end
    self.bottomDock = bottomDock

    local gitOwner = hg.GitHub_ReposOwner or "uzelezz123"
    local gitName = hg.GitHub_ReposName or "Z-City"

    local git = vgui.Create("DLabel", bottomDock)
    git:Dock(BOTTOM)
    git:DockMargin(ScreenScale(10), 0, 0, 0)
    git:SetFont("ZCity_Tiny")
    git:SetTextColor(clr_gray)
    git:SetText("GitHub: github.com/" .. gitOwner .. "/" .. gitName)
    git:SetContentAlignment(4)
    git:SetMouseInputEnabled(true)
    git:SizeToContents()

    function git:DoClick()
        gui.OpenURL("https://github.com/" .. gitOwner .. "/" .. gitName)
    end

    local version = vgui.Create("DLabel", bottomDock)
    version:Dock(BOTTOM)
    version:DockMargin(ScreenScale(10), 0, 0, 0)
    version:SetFont("ZCity_Tiny")
    version:SetTextColor(clr_gray)
    version:SetText(hg.Version or "Release ?")
    version:SetContentAlignment(4)
    version:SizeToContents()

    local zteam = vgui.Create("DLabel", bottomDock)
    zteam:Dock(BOTTOM)
    zteam:DockMargin(ScreenScale(10), 0, 0, 0)
    zteam:SetFont("ZCity_Tiny")
    zteam:SetTextColor(clr_gray)
    zteam:SetText("Authors: uzelezz, Sadsalat, \nMr.Point, Zac90, Deka, Mannytko")
    zteam:SetContentAlignment(4)
    zteam:SizeToContents()

    timer.Simple(0, function()
        if not IsValid(bottomDock) then return end
        local h = 0
        for _, child in ipairs(bottomDock:GetChildren()) do
            h = h + child:GetTall()
        end
        bottomDock:SetTall(math.max(ScreenScaleH(56), h + ScreenScaleH(4)))
    end)

    local rightCredits = vgui.Create("DLabel", self)
    rightCredits:SetFont("ZCity_Tiny")
    rightCredits:SetTextColor(clr_gray)
    rightCredits:SetText("Authors: ok1ro, Rubi)\nsupport | Klxcyn |")
    rightCredits:SetContentAlignment(6)
    rightCredits:SetMouseInputEnabled(false)
    rightCredits:SizeToContents()
    self.rightCredits = rightCredits

    local function PlaceRightCredits()
        if not IsValid(rightCredits) then return end
        rightCredits:SizeToContents()
        local padX = ScreenScale(6)
        local padY = ScreenScale(4)
        rightCredits:SetPos(ScrW() - rightCredits:GetWide() - padX, ScrH() - rightCredits:GetTall() - padY)
    end
    PlaceRightCredits()
    rightCredits.Think = PlaceRightCredits

    self.Buttons = {}
    for k, v in ipairs(Selects) do
        if v.GamemodeOnly and engine.ActiveGamemode() != "zcity" then continue end
        self:AddSelect(lDock, v.Title, v)
    end

    self:CreatePanelParent()
    self:BringNavToFront()
end

function PANEL:Think()
    if self:IsVisible() and self:GetAlpha() > 0 then
        gui.EnableScreenClicker(true)
    end
end

function PANEL:First( ply )
    self:ForceFullscreen()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    gui.EnableScreenClicker(true)
    self:AlphaTo( 255, 0.1, 0, nil )
end

function PANEL:PerformLayout(w, h)
    local sw, sh = ScrW(), ScrH()
    if self:GetWide() ~= sw or self:GetTall() ~= sh or self:GetX() ~= 0 or self:GetY() ~= 0 then
        self:SetPos(0, 0)
        self:SetSize(sw, sh)
    end

    if IsValid(self.panelparrent) then
        if self.panelparrent:GetWide() ~= sw or self.panelparrent:GetTall() ~= sh then
            self.panelparrent:SetPos(0, 0)
            self.panelparrent:SetSize(sw, sh)
        end
    end

    if IsValid(self.lDock) then
        if self.lDock:GetWide() ~= sw / 4 then
            self.lDock:SetWide(sw / 4)
        end
    end

    self:BringNavToFront()
end

local gradient_d = surface.GetTextureID("vgui/gradient-d")
local gradient_r = surface.GetTextureID("vgui/gradient-u")
local gradient_l = surface.GetTextureID("vgui/gradient-l")

local clr_1 = Color(41, 41, 41)
local function GetMenuBgAlpha()
    if hg.GetMenuTransparencyMul then
        return math.floor(255 * hg.GetMenuTransparencyMul())
    end
    local cv = GetConVar("hg_menu_transparency")
    local t = cv and math.Clamp(cv:GetInt(), 0, 100) or 0
    return math.floor(255 * (1 - t / 100))
end

function PANEL:Paint(w,h)
    if w < ScrW() - 2 or h < ScrH() - 2 then
        self:ForceFullscreen()
        w, h = ScrW(), ScrH()
    end
    local a = GetMenuBgAlpha()
    local bg = Color(0, 0, 0, a)
    draw.RoundedBox( 0, 0, 0, w, h, bg )
    if hg.DrawBlur then
        hg.DrawBlur(self, 5 * (a / 255))
    end
    surface.SetDrawColor( 0, 0, 0, a )
    surface.SetTexture( gradient_l )
    surface.DrawTexturedRect(0,0,w,h)
    surface.SetDrawColor( clr_1.r, clr_1.g, clr_1.b, math.floor(a * 0.85) )
    surface.SetTexture( gradient_d )
    surface.DrawTexturedRect(0,0,w,h)
end

function PANEL:AddSelect( pParent, strTitle, tbl )
    local id = #self.Buttons + 1
    self.Buttons[id] = vgui.Create( "DLabel", pParent )
    local btn = self.Buttons[id]
    btn:SetText( strTitle )
    btn:SetMouseInputEnabled( true )
    btn:SizeToContents()
    btn:SetFont( "ZCity_Small" )
    btn:SetTall( ScreenScale( 15 ) )
    btn:Dock(BOTTOM)
    btn:DockMargin(ScreenScale(15), ScreenScale(1.5), 0, 0)
    btn.Func = tbl.Func
    btn.HoveredFunc = tbl.HoveredFunc
    local luaMenu = self 
    if tbl.CreatedFunc then tbl.CreatedFunc(btn, self, luaMenu) end
    btn.RColor = Color(92, 92, 92)
    function btn:DoClick()
        local key = string.lower(strTitle)

        if ImmediateActions[key] then
            btn.Func(luaMenu, luaMenu.panelparrent)
            for i = 1, 3 do
                surface.PlaySound("homigrad/vgui/panorama/submenu_select_01.wav")
            end
            return
        end

        if curent_panel == key then
			for i = 1, 3 do
				surface.PlaySound("homigrad/vgui/panorama/sidemenu_rollover_02.wav")
			end
            luaMenu:ResetPanelParent(function()
                curent_panel = nil
            end)
            return 
        end

        luaMenu:ResetPanelParent(function(pp)
            if not IsValid(luaMenu) then return end
            pp:SetMouseInputEnabled(true)
            btn.Func(luaMenu, pp)
            curent_panel = key
            luaMenu:BringNavToFront()
        end)

		for i = 1, 3 do
			surface.PlaySound("homigrad/vgui/panorama/submenu_select_01.wav")
		end
    end

    function btn:Think()
        self.HoverLerp = LerpFT(0.2, self.HoverLerp or 0, (self:IsHovered() or (IsValid(self:GetChild(0)) and self:GetChild(0):IsHovered()) or (IsValid(self:GetChild(0)) and IsValid(self:GetChild(0):GetChild(0)) and self:GetChild(0):GetChild(0):IsHovered())) and 1 or 0)

        local v = self.HoverLerp
        self:SetTextColor(self.RColor:Lerp(red_select, v))

        local targetText = (self:IsHovered()) and string.upper(strTitle) or strTitle
        local crw = self:GetText()
        local key = string.lower(strTitle)

        if (crw ~= targetText) or (curent_panel == key) then
            local ntxt = ""
            -- was: `not strTitle == 'Traitor Role'` (always false due to Lua operator precedence)
            local will_text = (curent_panel == key and strTitle ~= "Traitor Role") and ("[ " .. string.upper(strTitle) .. " ]") or strTitle
            for i = 1, #will_text do
                local char = will_text:sub(i, i)
                if i <= math.ceil(#will_text * v) then
                    ntxt = ntxt .. string.upper(char)
                else
                    ntxt = ntxt .. char
                end
            end
			if self:GetText() ~= ntxt then
				surface.PlaySound("homigrad/vgui/panorama/sidemenu_rollover_02.wav")
			end
            self:SetText(ntxt)
        end
        self:SizeToContents()
    end
end

function PANEL:Close()
    self._ppToken = (self._ppToken or 0) + 1
    self:AlphaTo( 0, 0.1, 0, function()
        if IsValid(self) then self:Remove() end
        gui.EnableScreenClicker(false)
    end)
    self:SetKeyboardInputEnabled(false)
    self:SetMouseInputEnabled(false)
end

vgui.Register( "ZMainMenu", PANEL, "ZFrame")

hook.Add("OnPauseMenuShow","OpenMainMenu",function()
    local run = hook.Run("OnShowZCityPause")
    if run != nil then
        return run
    end

    if MainMenu and IsValid(MainMenu) then
        MainMenu:Close()
        MainMenu = nil
        return false
    end

    MainMenu = vgui.Create("ZMainMenu")
    MainMenu:ForceFullscreen()
    MainMenu:MakePopup()
    MainMenu:SetMouseInputEnabled(true)
    MainMenu:SetKeyboardInputEnabled(true)
    MainMenu:MoveToFront()
    gui.EnableScreenClicker(true)
    return false
end)
