local blurMat = Material("pp/blurscreen")

surface.CreateFont("KIRO_Title", {
    font = "Bahnschrift",
    size = ScreenScale(40),
    weight = 800,
    antialias = true
})
surface.CreateFont("KIRO_Btn", {
    font = "Bahnschrift",
    size = ScreenScale(13),
    weight = 500,
    antialias = true,
    extended = true
})
surface.CreateFont("KIRO_Small", {
    font = "Bahnschrift",
    size = ScreenScale(9),
    weight = 400,
    antialias = true
})
surface.CreateFont("KIRO_SettingsCat", {
    font = "Bahnschrift",
    size = ScreenScale(15),
    weight = 700,
    antialias = true
})
surface.CreateFont("KIRO_SettingsLabel", {
    font = "Bahnschrift",
    size = ScreenScale(12),
    weight = 500,
    antialias = true
})
surface.CreateFont("KIRO_SettingsHelp", {
    font = "Bahnschrift",
    size = ScreenScale(8),
    weight = 400,
    antialias = true
})

local colBg = Color(10, 10, 15, 220)
local colWhite = Color(220, 220, 220)
local colGrey = Color(140, 140, 140)
local colAccent = Color(180, 180, 180)
local colUser = Color(100, 255, 100)
local colGame = Color(255, 180, 100)
local colAdmin = Color(255, 100, 100)

function hg.GetMenuTransparencyMul()
    local cv = GetConVar("hg_menu_transparency")
    local t = cv and math.Clamp(cv:GetInt(), 0, 100) or 0
    return 1 - t / 100
end
local function drawBlur(panel, amount)
    local x, y = panel:LocalToScreen(0, 0)
    local frac = panel:GetAlpha() / 255
    surface.SetDrawColor(255, 255, 255, 255 * frac)
    surface.SetMaterial(blurMat)
    for i = 1, 3 do
        blurMat:SetFloat("$blur", (i / 3) * (amount or 8) * frac)
        blurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    end
end

hg.settings = hg.settings or {}
hg.settings.tbl = {}

function hg.settings:AddOpt(category, convarName, title, level, decimals, isString, convarType)
    self.tbl[category] = self.tbl[category] or {}
    self.tbl[category][convarName] = {
        convar  = convarName,
        title   = title,
        level   = level or "gameplay",
        decimals = decimals or false,
        isString = isString or false,
        convarType = convarType
    }
end

local hg_firstperson_death   = CreateClientConVar("hg_firstperson_death",   "0", true, false, "Переключение вида камеры смерти от первого лица", 0, 1)
local hg_font                = CreateClientConVar("hg_font",                "Bahnschrift", true, false, "Изменить шрифт текста")
local hg_attachment_draw_distance = CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "Расстояние прорисовки обвесов", 0, 4096)
local hg_menu_transparency   = CreateClientConVar("hg_menu_transparency", "1", true, false, "Прозрачность ESC-меню (0 = непрозрачно, 100 = прозрачно)", 0, 100)

hg.settings:AddOpt("Геймплей", "hg_old_notificate", "Старые уведомления", "gameplay")
hg.settings:AddOpt("Геймплей", "hg_cheats", "Включить читы", "admin")
hg.settings:AddOpt("Геймплей", "hg_showthoughts", "Показывать свои мысли", "gameplay")
hg.settings:AddOpt("Геймплей", "hg_hints", "Показывать подсказки", "gameplay")
hg.settings:AddOpt("Геймплей", "hg_gary", "HG GARY", "gameplay")
hg.settings:AddOpt("Геймплей", "hg_deathfadeout", "Затухание при смерти", "gameplay")

if not game.IsDedicated() then
    hg.settings:AddOpt("Сервер", "hg_toughnpcs", "Сильные NPC", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_thirdperson", "Третье лицо (WIP)", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_legacycam", "Старая камера", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_ragdollcombat", "Боевой режим ragdoll", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_movement_stamina_debuff", "Снижение выносливости", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_furcity", "Фурсити", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_appearance_access_for_all", "Полный доступ к внешности", "admin", nil, nil, "bool")
    hg.settings:AddOpt("Сервер", "hg_healanims", "Анимации лечения и еды", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_aimtoshoot", "Стрельба в стиле DarkRP (не работает)", "gameplay")
    hg.settings:AddOpt("Сервер", "hg_slings", "Sling system", "gameplay")
end

hg.settings:AddOpt("Отладка", "hg_show_hitposmuzzle", "Показывать хитпосы", "admin")
hg.settings:AddOpt("Отладка", "hg_setzoompos", "Настройка зума оружия (консоль)", "admin")
hg.settings:AddOpt("Отладка", "hg_show_hitbox", "Показывать хитбоксы", "admin")

hg.settings:AddOpt("Оптимизация", "hg_potatopc", "Режим слабого ПК", "user")
hg.settings:AddOpt("Оптимизация", "hg_anims_draw_distance", "Дистанция анимаций", "user", true, nil, "int")
hg.settings:AddOpt("Оптимизация", "hg_anim_fps", "FPS анимаций", "user", nil, nil, "int")
hg.settings:AddOpt("Оптимизация", "hg_attachment_draw_distance", "Дистанция обвесов", "user", true, nil, "int")
hg.settings:AddOpt("Оптимизация", "hg_maxsmoketrails", "Макс. дымовых следов", "user", nil, nil, "int")
hg.settings:AddOpt("Оптимизация", "hg_tpik_distance", "Дистанция рендера TPIK", "user", true, nil, "int")

hg.settings:AddOpt("Кровь", "hg_blood_draw_distance", "Дистанция крови", "user")
hg.settings:AddOpt("Кровь", "hg_blood_fps", "FPS крови", "user")
hg.settings:AddOpt("Кровь", "hg_blood_sprites", "Спрайты крови (отключены)", "user")
hg.settings:AddOpt("Кровь", "hg_old_blood", "Старая кровь", "user")

hg.settings:AddOpt("Интерфейс", "hg_font", "Пользовательский шрифт", "user", false, true)
hg.settings:AddOpt("Интерфейс", "hg_menu_transparency", "Прозрачность меню", "user", false, nil, "int")

hg.settings:AddOpt("Оружие", "hg_weaponshotblur_enable", "Размытие при стрельбе", "user")
hg.settings:AddOpt("Оружие", "hg_dynamic_mags", "Динамическая проверка магазинов", "gameplay")
hg.settings:AddOpt("Оружие", "hg_zoomsensitivity", "Чувствительность прицела", "user")
hg.settings:AddOpt("Оружие", "hg_highpitchgunfire", "Высокие частоты выстрелов", "user")

hg.settings:AddOpt("Вид", "hg_firstperson_death", "Смерть от первого лица", "user")
hg.settings:AddOpt("Вид", "hg_fov", "Поле зрения", "user")
hg.settings:AddOpt("Вид", "hg_newspectate", "Плавная камера наблюдателя", "user")
hg.settings:AddOpt("Вид", "hg_cshs_fake", "C'sHS Ragdoll камера", "user")
hg.settings:AddOpt("Вид", "hg_gun_cam", "Оружейная камера (админы)", "admin")
hg.settings:AddOpt("Вид", "hg_nofovzoom", "Отключить FOV Zoom", "user")
hg.settings:AddOpt("Вид", "hg_realismcam", "Realism camera", "user")
hg.settings:AddOpt("Вид", "hg_gopro", "GoPro камера (не работает)", "user")
hg.settings:AddOpt("Вид", "hg_newfakecam", "New fake camera", "user")
hg.settings:AddOpt("Вид", "hg_leancam_mul", "Множ. наклона камеры", "user", true, nil, "int")

hg.settings:AddOpt("Звук", "hg_dmusic", "Музыка в меню", "user")
hg.settings:AddOpt("Звук", "hg_quietshots", "Тихие выстрелы", "user")

local function guessType(cvar)
    local s = cvar:GetString()
    if s == "0" or s == "1" then return "bool" end
    if tonumber(s) then return "int" end
    return "string"
end

local function makeCategory(parent, y, text)
    local pnl = vgui.Create("DPanel", parent)
    pnl:SetSize(parent:GetWide(), ScreenScale(26))
    pnl:SetPos(0, y)
    pnl:SetMouseInputEnabled(false)
    pnl.anim = 0
    pnl.Paint = function(self, w, h)
        -- Stretch category header with the scroll width (fullscreen).
        local want = parent:GetWide()
        if w ~= want then self:SetWide(want) end
        self.anim = Lerp(FrameTime() * 8, self.anim, 1)
        local t = RealTime() * 4
        local a = self.anim * 255
        local chars = {}
        if utf8 then
            for _, c in utf8.codes(text) do chars[#chars+1] = utf8.char(c) end
        else
            for i = 1, #text do chars[i] = text:sub(i, i) end
        end
        surface.SetFont("KIRO_SettingsCat")
        local cx = ScreenScale(16)
        for i, ch in ipairs(chars) do
            local cw = surface.GetTextSize(ch)
            local shimmer = (math.sin(t - i * 0.4) + 1) / 2
            local gray = 130 + shimmer * 90
            local col = Color(gray, gray, gray, a)
            draw.SimpleText(ch, "KIRO_SettingsCat", cx + 1, h/2 + 1, Color(0,0,0,120))
            draw.SimpleText(ch, "KIRO_SettingsCat", cx, h/2, col)
            cx = cx + cw
        end
    end
    return pnl
end

local function makeOption(parent, y, data)
    local cname = data.convar
    local txt = data.title
    local lvl = data.level or "gameplay"
    if not cname then
        cname = data[2]
        txt = data[3]
        lvl = data.level or "gameplay"
    end
    if not cname then return end
    local cv = GetConVar(cname)
    if not cv then return end

    local barCol
    if lvl == "user" then barCol = colUser
    elseif lvl == "admin" then barCol = colAdmin
    else barCol = colGame end

    local ctype = data.convarType or guessType(cv)
    local w = parent:GetWide()
    local pad = ScreenScale(5)
    local barW = ScreenScale(3)
    local ctrlW = ScreenScale(140)
    local help = cv:GetHelpText()
    local hasHelp = help and help ~= ""
    local rowH = hasHelp and ScreenScale(50) or ScreenScale(35)
    local row = vgui.Create("DPanel", parent)
    row:SetSize(math.max(1, w - ScreenScale(10)), rowH)
    row:SetPos(pad, y)
    row.hover = 0
    row.Paint = function(self, w, h)
        local want = math.max(1, parent:GetWide() - ScreenScale(10))
        if self:GetWide() ~= want then self:SetWide(want) end
        self.hover = Lerp(FrameTime() * 10, self.hover, self:IsHovered() and 1 or 0)
        draw.RoundedBox(4, 0, 0, want, h, Color(40 + self.hover * 15, 40 + self.hover * 15, 40 + self.hover * 15, 180))
        surface.SetDrawColor(barCol.r, barCol.g, barCol.b, 60 + self.hover * 120)
        surface.DrawRect(0, 0, barW, h)
    end

    local lblX = ScreenScale(10)
    local lblY = ScreenScale(5)
    local label = vgui.Create("DLabel", row)
    label:SetPos(lblX, lblY)
    label:SetFont("KIRO_SettingsLabel")
    label:SetText(txt)
    label:SetTextColor(colWhite)
    label:SizeToContents()

    if hasHelp then
        local hint = vgui.Create("DLabel", row)
        hint:SetPos(lblX, ScreenScale(22))
        hint:SetFont("KIRO_SettingsHelp")
        hint:SetText(help)
        hint:SetTextColor(colGrey)
        hint:SetWide(row:GetWide() - ctrlW - ScreenScale(25))
        hint:SetWrap(true)
        hint:SetAutoStretchVertical(true)
    end

    local ctrlX = w - ctrlW - ScreenScale(15)
    local ctrlPanel
    if ctype == "bool" then
        local tw, th = ScreenScale(36), ScreenScale(16)
        local sw = vgui.Create("DPanel", row)
        sw:SetSize(tw, th)
        sw:SetPos(ctrlX, rowH/2 - th/2)
        ctrlPanel = sw
        local curVal = cv:GetBool() and 1 or 0
        local goal = curVal
        sw.Paint = function(self, w, h)
            goal = cv:GetBool() and 1 or 0
            curVal = Lerp(FrameTime() * 12, curVal, goal)
            local onCol = Color(180, 180, 180, 255)
            local offCol = Color(50, 50, 55, 200)
            draw.RoundedBox(4, 0, 0, w, h, curVal > 0.5 and onCol or offCol)
            local kx = Lerp(curVal, 2, w - h + 2)
            draw.RoundedBox(4, kx, 2, h-4, h-4, curVal > 0.5 and Color(30,30,30) or colWhite)
        end
        sw.OnMousePressed = function()
            RunConsoleCommand(cname, cv:GetBool() and "0" or "1")
        end
    elseif ctype == "int" then
        local valW = ScreenScale(30)
        local sld = vgui.Create("DNumSlider", row)
        sld:SetSize(ctrlW - valW - ScreenScale(8), ScreenScale(16))
        sld:SetPos(ctrlX + valW + ScreenScale(4), rowH/2 - ScreenScale(8))
        ctrlPanel = sld
        sld:SetText("")
        local dec = data.decimals or false
        sld:SetDecimals(dec and 2 or 0)
        sld:SetMin(cv:GetMin() or 0)
        sld:SetMax(cv:GetMax() or 100)
        sld:SetValue(dec and cv:GetFloat() or cv:GetInt())
        sld.Label:SetVisible(false)
        if sld.TextArea then sld.TextArea:SetVisible(false) end
        sld.Slider.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, h/2-2, w, 4, Color(60, 60, 65, 200))
        end
        sld.Slider.Knob.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(180, 180, 180))
        end

        local valL = vgui.Create("DLabel", row)
        valL:SetPos(ctrlX, rowH/2 - ScreenScale(8))
        valL:SetSize(valW, ScreenScale(16))
        valL:SetFont("KIRO_Small")
        valL:SetTextColor(colWhite)
        valL:SetContentAlignment(6)

        sld.OnValueChanged = function(self, val)
            if dec then
                RunConsoleCommand(cname, string.format("%.2f", val))
            else
                RunConsoleCommand(cname, tostring(math.Round(val)))
            end
            valL:SetText(dec and string.format("%.2f", cv:GetFloat()) or tostring(cv:GetInt()))
        end
        timer.Simple(0, function()
            if IsValid(valL) then
                valL:SetText(dec and string.format("%.2f", cv:GetFloat()) or tostring(cv:GetInt()))
            end
        end)

        row._valLabel = valL
        row._valW = valW
    elseif ctype == "string" then
        local box = vgui.Create("DTextEntry", row)
        box:SetSize(ctrlW, ScreenScale(18))
        box:SetPos(ctrlX, rowH/2 - ScreenScale(9))
        ctrlPanel = box
        box:SetFont("KIRO_Small")
        box:SetText(cv:GetString())
        box:SetUpdateOnType(true)
        box.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40,40,45,200))
            surface.SetDrawColor(100,100,100,180)
            surface.DrawOutlinedRect(0,0,w,h,1)
            self:DrawTextEntryText(colWhite, colAccent, colWhite)
        end
        box.OnChange = function()
            RunConsoleCommand(cname, box:GetValue())
        end
    end

    row._ctrl = ctrlPanel
    row._ctrlW = ctrlW
    row._ctype = ctype
    row.Think = function(self)
        local want = math.max(1, parent:GetWide() - ScreenScale(10))
        if self:GetWide() ~= want then self:SetWide(want) end
        local cx = want - self._ctrlW - ScreenScale(15)
        if not IsValid(self._ctrl) then return end
        local _, cy = self._ctrl:GetPos()
        if self._ctype == "int" and IsValid(self._valLabel) then
            local _, vy = self._valLabel:GetPos()
            self._valLabel:SetPos(cx, vy)
            self._ctrl:SetPos(cx + (self._valW or 0) + ScreenScale(4), cy)
        else
            local ox = select(1, self._ctrl:GetPos())
            if ox ~= cx then self._ctrl:SetPos(cx, cy) end
        end
    end
    return row
end

function hg.DrawSettings(parent)
    -- Fullscreen settings: stretch this panel (and its frame) to the whole screen.
    local function forceFullscreen(pnl)
        if not IsValid(pnl) then return end
        pnl:SetPos(0, 0)
        pnl:SetSize(ScrW(), ScrH())
        if pnl.SetDraggable then pnl:SetDraggable(false) end
        if pnl.ShowCloseButton then pnl:ShowCloseButton(false) end
        if pnl.SetSizable then pnl:SetSizable(false) end
        if pnl.SetTitle then pnl:SetTitle("") end
        if pnl.DockPadding then pnl:DockPadding(0, 0, 0, 0) end
    end

    forceFullscreen(parent)
    local outer = parent:GetParent()
    if IsValid(outer) then
        local cls = outer.ClassName or (outer.GetClassName and outer:GetClassName()) or ""
        -- Only stretch the frame / content wrapper, not the global VGUI root.
        if cls == "DFrame" or cls == "DPanel" or cls == "EditablePanel" or outer:GetWide() < ScrW() - 4 then
            forceFullscreen(outer)
        end
    end

    parent:SetAlpha(0)
    parent.bgAlpha = 0
    local leftPad = ScrW() / 4
    parent.Paint = function(self, w, h)
        -- Keep covering the screen if something tries to shrink us.
        if w < ScrW() - 2 or h < ScrH() - 2 then
            forceFullscreen(self)
            w, h = ScrW(), ScrH()
        end
        self.bgAlpha = Lerp(FrameTime() * 8, self.bgAlpha, 1)
        local x0 = leftPad
        local mul = hg.GetMenuTransparencyMul and hg.GetMenuTransparencyMul() or 1
        drawBlur(self, 8 * mul)
        surface.SetDrawColor(colBg.r, colBg.g, colBg.b, colBg.a * self.bgAlpha * mul)
        surface.DrawRect(x0, 0, w - x0, h)

        local grid = math.max(8, math.floor(ScreenScale(25)))
        surface.SetDrawColor(200, 200, 200, 15 * self.bgAlpha * mul)
        for x = x0, w, grid do
            surface.DrawRect(x, 0, 1, h)
        end
        for y = 0, h, grid do
            surface.DrawRect(x0, y, w - x0, 1)
        end
    end
    parent:AlphaTo(255, 0.15, 0)

    local titlePad = leftPad + ScreenScale(28)
    local title = vgui.Create("DLabel", parent)
    title:SetPos(titlePad, ScreenScale(18))
    title:SetFont("KIRO_Title")
    title:SetText("НАСТРОЙКИ")
    title:SizeToContents()
    title:SetTextColor(Color(0,0,0,0))
    title.anim = 0
    title.Paint = function(self, w, h)
        self.anim = Lerp(FrameTime() * 10, self.anim, 1)
        local a = self.anim * 255
        local t = RealTime() * 4
        local s = "НАСТРОЙКИ"
        surface.SetFont("KIRO_Title")
        local chars = {}
        if utf8 then
            for _, c in utf8.codes(s) do chars[#chars+1] = utf8.char(c) end
        else
            for i = 1, #s do chars[i] = s:sub(i,i) end
        end
        local cx = 0
        for i, ch in ipairs(chars) do
            local cw = surface.GetTextSize(ch)
            local shimmer = (math.sin(t - i*0.4) + 1)/2
            local gray = 100 + shimmer*155
            draw.SimpleText(ch, "KIRO_Title", cx+2, 2, Color(0,0,0,150*(a/255)))
            draw.SimpleText(ch, "KIRO_Title", cx, 0, Color(gray, gray, gray, a))
            cx = cx + cw
        end
    end

    local margin = ScreenScale(24)
    local top = ScreenScale(78)
    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetPos(leftPad + margin, top)
    scroll:SetSize(math.max(1, parent:GetWide() - leftPad - margin * 2), math.max(1, parent:GetTall() - top - margin))
    scroll.Paint = function() end
    -- If parent was resized to fullscreen after layout, stretch scroll to match.
    scroll.Think = function(self)
        local tw = math.max(1, parent:GetWide() - leftPad - margin * 2)
        local th = math.max(1, parent:GetTall() - top - margin)
        if self:GetWide() ~= tw or self:GetTall() ~= th then
            self:SetPos(leftPad + margin, top)
            self:SetSize(tw, th)
        end
    end

    local vbar = scroll:GetVBar()
    vbar:SetSize(ScreenScale(8), 0)
    vbar.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,Color(30,30,40,200)) end
    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
    vbar.btnGrip.Paint = function(s,w,h)
        draw.RoundedBox(4,2,2,w-4,h-4,s:IsHovered() and Color(100,100,130) or Color(70,70,90))
    end

    local y = 0
    for catName, catTable in pairs(hg.settings.tbl) do
        local anyValid = false
        for _, optData in pairs(catTable) do
            local cn = optData.convar or optData[2]
            if cn and GetConVar(cn) then
                anyValid = true
                break
            end
        end
        if anyValid then
            local catPnl = makeCategory(scroll, y, catName)
            y = y + catPnl:GetTall() + ScreenScale(12)

            for _, optData in pairs(catTable) do
                local row = makeOption(scroll, y, optData)
                if row then
                    y = y + row:GetTall() + ScreenScale(5)
                end
            end
            y = y + ScreenScale(10)
        end
    end
end