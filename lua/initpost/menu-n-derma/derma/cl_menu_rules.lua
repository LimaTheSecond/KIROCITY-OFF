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
surface.CreateFont("KIRO_RulesCat", {
    font = "Bahnschrift",
    size = ScreenScale(16),
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

local colRed    = Color(255, 100, 100)
local colYellow = Color(255, 255, 100)
local colOrange = Color(255, 180, 100)

local rulesList = {
    { category = "0. Основное", items = {
        { name = "0.1", desc = "Незнание правил не освобождает от ответственности." },
        { name = "0.2", desc = "Решение администрации является окончательным." }
    }},
    { category = "1. Общие правила", items = {
        { name = "1.1 — Дискредитация сервера", desc = "Запрещено оскорблять сервер, рекламировать другие проекты или распространять ложную информацию.", punishment = "бан навсегда", color = colRed },
        { name = "1.3 — Выдача себя за другого", desc = "Запрещено копировать ник или аватар, а также притворяться другим игроком. Срок увеличивается при выдаче себя за админа.", punishment = "бан 16 часов (при выдаче за админа 3 дня)", color = colOrange },
        { name = "1.4 — Обход наказания", desc = "Использование твинков или других способов обхода наказания.", punishment = "бан навсегда", color = colRed },
        { name = "1.5 — Спам", desc = "Флуд, спам звуками (Soundpad), засорение чата. В том числе включение NSFW звуков. Использовать soundpad разрешено в меру.", punishment = "бан — 20 минут; повтор — до 5 часов", color = colYellow },
        { name = "1.6 — Провокации", desc = "Подставы и намеренные попытки заставить другого игрока нарушить правила.", punishment = "бан до 3 недель", color = colOrange },
        { name = "1.7 — Запрещённый контент", desc = "NSFW, шок-контент, экстремистская символика, фурри спреи!", punishment = "бан 2 дня", color = colRed },
        { name = "1.8 — Угрозы и слив данных", desc = "Любые угрозы или распространение личной информации.", punishment = "бан навсегда", color = colRed },
        { name = "1.9 — Злоупотребление лазейками", desc = "Использование недоработок правил или механик в свою пользу. В частности — использование багов сервера в личных целях.", punishment = "бан до 5 дней", color = colOrange },
        { name = "1.10 — Давление на администрацию", desc = "Спам жалобами, споры после финального решения, угрозы.", punishment = "бан до 2 дней", color = colYellow },
        { name = "1.11 — Неадекватное поведение", desc = "Крики в микрофон, троллинг, намеренное раздражение игроков.", punishment = "бан до 6 часов", color = colYellow }
    }},
    { category = "2. Игровые правила (KIROCITY)", items = {
        { name = "2.1 — Читы", desc = "Любые сторонние программы, дающие преимущество.", punishment = "бан навсегда + снятие доната", color = colRed },
        { name = "2.2 — Баги и абузы", desc = "Использование багов, дюпов и абуз механик.", punishment = "2 недели; серьезное нарушение — до 3 месяцев", color = colOrange },
        { name = "2.3 — Сговор (тиминг)", desc = "Помощь врагам или игра в сговоре ради преимущества.", punishment = "бан 1 час", color = colYellow },
        { name = "2.4 — Мониторинг", desc = "Передача информации после смерти.", punishment = "бан 2 часа", color = colYellow },
        { name = "2.5 — Помеха игре", desc = "Блокировка проходов, спам объектами, мешание другим игрокам.", punishment = "бан от 1 часа до 1 дня", color = colOrange },
        { name = "2.6 — Лив от наказания", desc = "Выход во время разборки или перед наказанием.", punishment = "бан до 2 дней", color = colOrange },
        { name = "2.7 — Обман администрации", desc = "Ложные жалобы или поддельные доказательства.", punishment = "бан до 1 дня", color = colOrange },
        { name = "2.8 — Руин (порча игры)", desc = "Намеренные действия, портящие игру другим игрокам.", punishment = "бан до 7 дней", color = colRed },
        { name = "2.9 — Массовые нарушения", desc = "Многократные или систематические нарушения.", punishment = "вплоть до перманента", color = colRed },
        { name = "2.10 — Намеренный лаг сервера", desc = "Создание лагов любыми способами.", punishment = "бан вплоть до перманента", color = colRed }
    }}
}

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

local function EscapeMarkup(str)
    return tostring(str or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

local function ColorMarkup(col)
    return string.format("%d, %d, %d", col.r or 255, col.g or 255, col.b or 255)
end

function hg.DrawRules(parent)
    if not IsValid(parent) then return end

    local function forceFullscreen(pnl)
        if not IsValid(pnl) then return end
        pnl:SetPos(0, 0)
        pnl:SetSize(ScrW(), ScrH())
    end
    forceFullscreen(parent)

    local leftPad = math.floor(ScrW() / 4)
    local pad = ScreenScale(20)

    parent:SetMouseInputEnabled(true)
    parent:SetAlpha(0)
    parent.anim = 0

    -- Static grid (no RealTime scroll) — stops the "flying" look.
    parent.Paint = function(self, w, h)
        if w < ScrW() - 2 or h < ScrH() - 2 then
            forceFullscreen(self)
            w, h = ScrW(), ScrH()
        end
        self.anim = Lerp(FrameTime() * 8, self.anim, 1)
        local mul = hg.GetMenuTransparencyMul and hg.GetMenuTransparencyMul() or 1

        local x0 = leftPad
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
    titleLabel:SetText("ПРАВИЛА")
    titleLabel:SizeToContents()
    titleLabel:SetTextColor(Color(255, 255, 255, 0))
    titleLabel.alpha = 0
    titleLabel.Paint = function(self, w, h)
        self.alpha = Lerp(FrameTime() * 10, self.alpha, 1)
        local a = self.alpha * 255
        local t = RealTime() * 4
        local title = "ПРАВИЛА"
        surface.SetFont("KIRO_Title")
        local chars = {}
        if utf8 then
            for _, c in utf8.codes(title) do chars[#chars + 1] = utf8.char(c) end
        else
            for i = 1, #title do chars[i] = title:sub(i, i) end
        end
        local cx = 0
        for i, ch in ipairs(chars) do
            local cw = surface.GetTextSize(ch)
            local shimmer = (math.sin(t - i * 0.4) + 1) / 2
            local gray = 100 + shimmer * 155
            draw.SimpleText(ch, "KIRO_Title", cx + 2, 2, Color(0, 0, 0, 150 * (a / 255)))
            draw.SimpleText(ch, "KIRO_Title", cx, 0, Color(gray, gray, gray, a))
            cx = cx + cw
        end
    end

    local scroll = vgui.Create("DScrollPanel", parent)
    scroll:SetSize(parent:GetWide() - leftPad - pad * 2, parent:GetTall() - ScreenScale(90))
    scroll:SetPos(leftPad + pad, ScreenScale(70))
    scroll.Paint = function() end

    local vbar = scroll:GetVBar()
    vbar:SetWide(ScreenScale(8))
    vbar.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 40, 200))
    end
    vbar.btnUp.Paint = function() end
    vbar.btnDown.Paint = function() end
    vbar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, s:IsHovered() and Color(100, 100, 130) or Color(70, 70, 90))
    end

    local y = 0
    local rowW = math.max(1, scroll:GetWide() - ScreenScale(15))
    local textW = math.max(1, rowW - ScreenScale(24))
    local padX = ScreenScale(12)
    local padY = ScreenScale(8)
    local gap = ScreenScale(5)

    for _, cat in ipairs(rulesList) do
        local catLabel = vgui.Create("DLabel", scroll)
        catLabel:SetPos(ScreenScale(10), y)
        catLabel:SetFont("KIRO_RulesCat")
        catLabel:SetText(cat.category)
        catLabel:SetTextColor(Color(200, 200, 200))
        catLabel:SizeToContents()
        y = y + catLabel:GetTall() + ScreenScale(8)

        for _, item in ipairs(cat.items) do
            local nameMU = markup.Parse(
                "<font=KIRO_RulesNum><colour=180, 180, 180>" .. EscapeMarkup(item.name) .. "</colour></font>",
                textW
            )
            local descMU = markup.Parse(
                "<font=KIRO_RulesDesc><colour=150, 150, 150>" .. EscapeMarkup(item.desc) .. "</colour></font>",
                textW
            )

            local punMU
            if item.punishment then
                local c = item.color or colRed
                punMU = markup.Parse(
                    "<font=KIRO_RulesDesc><colour=" .. ColorMarkup(c) .. ">Наказание: " .. EscapeMarkup(item.punishment) .. "</colour></font>",
                    textW
                )
            end

            local contentH = nameMU:GetHeight() + gap + descMU:GetHeight()
            if punMU then
                contentH = contentH + gap + punMU:GetHeight()
            end
            local panelH = padY * 2 + contentH

            local rulePanel = vgui.Create("DPanel", scroll)
            rulePanel:SetSize(rowW, panelH)
            rulePanel:SetPos(ScreenScale(5), y)
            rulePanel.hover = 0
            rulePanel.nameMU = nameMU
            rulePanel.descMU = descMU
            rulePanel.punMU = punMU

            rulePanel.Paint = function(self, pw, ph)
                self.hover = Lerp(FrameTime() * 10, self.hover, self:IsHovered() and 1 or 0)
                draw.RoundedBox(4, 0, 0, pw, ph, Color(40 + self.hover * 15, 40 + self.hover * 15, 40 + self.hover * 15, 180))
                local accent = item.color or Color(180, 180, 180)
                surface.SetDrawColor(accent.r, accent.g, accent.b, 60 + self.hover * 120)
                surface.DrawRect(0, 0, 3, ph)

                local cy = padY
                self.nameMU:Draw(padX, cy, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                cy = cy + self.nameMU:GetHeight() + gap
                self.descMU:Draw(padX, cy, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                cy = cy + self.descMU:GetHeight() + gap
                if self.punMU then
                    self.punMU:Draw(padX, cy, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
            end

            y = y + panelH + ScreenScale(6)
        end
        y = y + ScreenScale(10)
    end
end
