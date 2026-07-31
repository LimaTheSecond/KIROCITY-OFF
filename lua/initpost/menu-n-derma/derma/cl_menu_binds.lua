local blurMat = Material("pp/blurscreen")

surface.CreateFont("KIRO_Title", {
    font = "Bahnschrift",
    size = ScreenScale(40),
    weight = 800,
    antialias = true
})
surface.CreateFont("KIRO_RulesCat", {
    font = "Bahnschrift",
    size = ScreenScale(14),
    weight = 700,
    antialias = true
})
surface.CreateFont("KIRO_RulesNum", {
    font = "Bahnschrift",
    size = ScreenScale(12),
    weight = 600,
    antialias = true
})
surface.CreateFont("KIRO_RulesDesc", {
    font = "Bahnschrift",
    size = ScreenScale(10),
    weight = 400,
    antialias = true
})

local SAVE_FILE = "zcity_keybinds.txt"

local Binds = {
    { command = "hg_kick",           desc = "С помощью этого бинда вы сможете пинаться", hold = false },
    { command = "fake",              desc = "Это необходимый бинд, он поможет вам вставать/ложиться из положения регдолла", hold = false },
    { command = "+alt1",             desc = "Наклон влево, менее необходимый бинд но для тдм, контрстрайк, дм, сво пойдёт", hold = true  },
    { command = "+alt2",             desc = "Наклон вправо менее необходимый бинд но для тдм, контрстрайк, дм, сво пойдёт", hold = true  },
    { command = "+hmcd_holdbreath",  desc = "Задержать дыхание спасёт вам жизнь чтобы не надышаться угарным газом от огня или цианидом", hold = true  },
    { command = "+altlook",          desc = "Осмотреться, я считаю он бесполезный", hold = true  },
    { command = "+hg_zoom",          desc = "Приблизить камеру, очень полезный бинд (лучше на F) для дальной стрельбы", hold = true  }
}

local function GetBindTitle(cmd)
    local map = {
        hg_kick = "Пинок (hg_kick)",
        fake = "Регдолл (fake)",
        ["+alt1"] = "Наклон влево (+alt1)",
        ["+alt2"] = "Наклон вправо (+alt2)",
        ["+hmcd_holdbreath"] = "Задержка дыхания (+hmcd_holdbreath)",
        ["+altlook"] = "Осмотреться (+altlook)",
        ["+hg_zoom"] = "Приближение (+hg_zoom)"
    }
    return map[cmd] or cmd
end

-- если тебя смутят блоки дальше не считая функцию отрисовки то держи https://steamcommunity.com/sharedfiles/filedetails/?id=3737887777
-- из этого мода была взята логика сохронения биндов и команды которые я вижу первый раз в своей жизни, я только о фейке, пинке, задержке дыхания знал
local function GetNativeBind(command)
    local native = input.LookupBinding(command)
    return native and string.upper(native) or nil
end

local function SaveBinds()
    local data = {}
    for _, b in ipairs(Binds) do
        data[b.command] = b.key or KEY_NONE
    end
    file.Write(SAVE_FILE, util.TableToJSON(data, true))
end

local function LoadBinds()
    if not file.Exists(SAVE_FILE, "DATA") then
        for _, b in ipairs(Binds) do b.key = KEY_NONE end
        SaveBinds()
        return
    end
    local raw = file.Read(SAVE_FILE, "DATA")
    if not raw then return end
    local data = util.JSONToTable(raw)
    if not data then return end
    for _, b in ipairs(Binds) do
        local saved = data[b.command]
        if saved then
            b.key = tonumber(saved) or KEY_NONE
        else
            b.key = KEY_NONE
        end
    end
end

LoadBinds()

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

function hg.DrawBinds(parent)
    if not IsValid(parent) then return end

    local function forceFullscreen(pnl)
        if not IsValid(pnl) then return end
        pnl:SetPos(0, 0)
        pnl:SetSize(ScrW(), ScrH())
    end
    forceFullscreen(parent)

    local leftPad = ScrW() / 4
    local pad = ScreenScale(20)

    parent:SetMouseInputEnabled(true)
    parent:SetAlpha(0)
    parent.anim = 0

    parent.Paint = function(self, w, h)
        if w < ScrW() - 2 or h < ScrH() - 2 then
            forceFullscreen(self)
            w, h = ScrW(), ScrH()
        end
        self.anim = Lerp(FrameTime() * 8, self.anim, 1)
        local mul = hg.GetMenuTransparencyMul and hg.GetMenuTransparencyMul() or 1

        local x0 = math.floor(leftPad)
        local sx, sy = self:LocalToScreen(x0, 0)
        render.SetScissorRect(sx, sy, sx + (w - x0), sy + h, true)

        drawBlur(self, 8 * mul)
        surface.SetDrawColor(10, 10, 15, 220 * self.anim * mul)
        surface.DrawRect(x0, 0, w - x0, h)

        local grid = math.max(8, math.floor(ScreenScale(25)))
        surface.SetDrawColor(200, 200, 200, 12 * self.anim * mul)
        for x = x0, w, grid do
            surface.DrawRect(x, 0, 1, h)
        end
        for y = 0, h, grid do
            surface.DrawRect(x0, y, w - x0, 1)
        end

        render.SetScissorRect(0, 0, 0, 0, false)
    end

    parent:AlphaTo(255, 0.15, 0)
    local titleLabel = vgui.Create("DLabel", parent)
    titleLabel:SetPos(leftPad + pad, ScreenScale(20))
    titleLabel:SetFont("KIRO_Title")
    titleLabel:SetText("НАЗНАЧЕНИЕ КЛАВИШ")
    titleLabel:SizeToContents()
    titleLabel:SetTextColor(Color(255, 255, 255, 0))
    titleLabel.alpha = 0
    titleLabel.Paint = function(self, w, h)
        self.alpha = Lerp(FrameTime() * 10, self.alpha, 1)
        local a = self.alpha * 255
        local t = RealTime() * 4
        local text = "НАЗНАЧЕНИЕ КЛАВИШ"
        surface.SetFont("KIRO_Title")
        local chars = {}
        if utf8 then
            for _, c in utf8.codes(text) do chars[#chars+1] = utf8.char(c) end
        else
            for i = 1, #text do chars[i] = text:sub(i, i) end
        end
        local x = 0
        for i, ch in ipairs(chars) do
            local cw = surface.GetTextSize(ch)
            local pulse = (math.sin(t - i * 0.4) + 1) * 0.5
            local gray = 100 + pulse * 155
            local col = Color(gray, gray, gray, a)
            draw.SimpleText(ch, "KIRO_Title", x + 2, 2, Color(0, 0, 0, 150 * (a/255)))
            draw.SimpleText(ch, "KIRO_Title", x, 0, col)
            x = x + cw
        end
    end

    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetSize(parent:GetWide() - leftPad - pad * 2, parent:GetTall() - ScreenScale(90))
    scroll:SetPos(leftPad + pad, ScreenScale(70))
    scroll.Paint = function() end

    local bar = scroll:GetVBar()
    bar:SetSize(ScreenScale(8), 0)
    bar.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 200))
    end
    bar.btnUp.Paint = function() end
    bar.btnDown.Paint = function() end
    bar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, s:IsHovered() and Color(100, 100, 130) or Color(70, 70, 90))
    end

    local y = 0
    for _, bind in ipairs(Binds) do
        local row = vgui.Create("DPanel", scroll)
        row:SetSize(scroll:GetWide() - ScreenScale(15), ScreenScale(68))
        row:SetPos(ScreenScale(5), y)
        row.hover = 0
        row.Paint = function(self, w, h)
            self.hover = Lerp(FrameTime() * 10, self.hover, self:IsHovered() and 1 or 0)
            draw.RoundedBox(4, 0, 0, w, h, Color(40 + self.hover * 15, 40 + self.hover * 15, 40 + self.hover * 15, 180))
            surface.SetDrawColor(180, 180, 180, 60 + self.hover * 120)
            surface.DrawRect(0, 0, 3, h)
        end

        local name = vgui.Create("DLabel", row)
        name:SetPos(ScreenScale(10), ScreenScale(6))
        name:SetFont("KIRO_RulesNum")
        name:SetText(GetBindTitle(bind.command))
        name:SetTextColor(Color(200, 200, 200))
        name:SizeToContents()

        local desc = vgui.Create("DLabel", row)
        desc:SetPos(ScreenScale(10), ScreenScale(26))
        desc:SetFont("KIRO_RulesDesc")
        desc:SetText(bind.desc)
        desc:SetTextColor(Color(150, 150, 150))
        desc:SetWide(row:GetWide() - ScreenScale(180))
        desc:SetWrap(true)
        desc:SetAutoStretchVertical(true)

        local natBind = GetNativeBind(bind.command)
        if natBind then
            local nat = vgui.Create("DLabel", row)
            nat:SetPos(ScreenScale(10), ScreenScale(44))
            nat:SetFont("KIRO_RulesDesc")
            nat:SetText("Своя привязка: " .. natBind)
            nat:SetTextColor(Color(130, 130, 130))
            nat:SizeToContents()
        end

        local binder = vgui.Create("DBinder", row)
        binder:SetSize(ScreenScale(90), ScreenScale(24))
        binder:SetPos(row:GetWide() - ScreenScale(175), ScreenScale(10))
        binder:SetValue(bind.key)
        binder.OnChange = function(self, key)
            if not key then return end
            bind.key = key
            SaveBinds()
        end
        local oldPaint = binder.Paint
        binder.Paint = function(self, w, h)
            if oldPaint then oldPaint(self, w, h) end
            surface.SetDrawColor(140, 140, 140, 200)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        binder:SetTooltip(false)

        local clearBtn = vgui.Create("DButton", row)
        clearBtn:SetSize(ScreenScale(70), ScreenScale(24))
        clearBtn:SetPos(row:GetWide() - ScreenScale(80), ScreenScale(10))
        clearBtn:SetText("Очистить")
        clearBtn:SetFont("KIRO_RulesNum")
        clearBtn:SetTextColor(Color(220, 120, 120))
        clearBtn.Paint = function(self, w, h)
            local hover = self:IsHovered()
            draw.RoundedBox(2, 0, 0, w, h, hover and Color(180, 80, 80, 200) or Color(60, 60, 60, 200))
            surface.SetDrawColor(140, 140, 140, 200)
            surface.DrawOutlinedRect(0, 0, w, h)
            self:SetTextColor(hover and Color(255, 160, 160) or Color(220, 120, 120))
        end
        clearBtn.DoClick = function()
            bind.key = KEY_NONE
            SaveBinds()
            binder:SetValue(KEY_NONE)
        end

        y = y + ScreenScale(68) + ScreenScale(5)
    end
end
local ZoomDown = false

hook.Add("PlayerButtonDown", "ZCity_BindsMenu_Down", function(ply, button)
    if ply ~= LocalPlayer() then return end
    if gui.IsGameUIVisible() then return end
    if IsValid(vgui.GetKeyboardFocus()) then return end

    for _, b in ipairs(Binds) do
        if b.key == KEY_NONE or button ~= b.key then continue end
        if b.hold then
            if not ZoomDown then
                ZoomDown = true
                RunConsoleCommand(b.command)
            end
        else
            RunConsoleCommand(b.command)
        end
        return
    end
end)

hook.Add("PlayerButtonUp", "ZCity_BindsMenu_Up", function(ply, button)
    if ply ~= LocalPlayer() then return end

    for _, b in ipairs(Binds) do
        if not b.hold or b.key == KEY_NONE or button ~= b.key then continue end
        if ZoomDown then
            ZoomDown = false
            local cmd = b.command
            if string.StartWith(cmd, "+") then
                RunConsoleCommand("-" .. string.sub(cmd, 2))
            end
        end
    end
end)

hook.Add("ShutDown", "ZCity_BindsMenu_Save", function()
    SaveBinds()
end)