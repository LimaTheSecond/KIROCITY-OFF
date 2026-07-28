if CLIENT then
    local RTVPanel = nil
    local CachedMaps, CachedEndTime, CachedVotes = nil, 0, {}
    local RTV_CloseTimer = nil
    local RTV_Music = nil

    surface.CreateFont('RTV.TitleFont', { font = 'Roboto', size = ScreenScale(18), weight = 1000 })
    surface.CreateFont('RTV.TimeFont',  { font = 'Roboto', size = ScreenScale(8), weight = 1, italic = true })
    surface.CreateFont('RTV.StayFont', { font = 'Roboto', size = ScreenScale(10), weight = 1000 })

    if not ConVarExists('rtv_icon_debug') then
        CreateClientConVar('rtv_icon_debug', '0', true, false, 'Лог иконок RTV в консоль')
    end
    local function RTVDbg(msg)
        if GetConVar('rtv_icon_debug'):GetBool() then
            MsgC(Color(120, 200, 255), '[RTV-ICON] ', Color(220, 220, 220), tostring(msg), '\n')
        end
    end

    local ServerMapWSID = {}
    function RTV_SetServerWSID(tbl)
        ServerMapWSID = tbl or {}
        if GetConVar('rtv_icon_debug'):GetBool() then
            RTVDbg('получено wsid от сервера: ' .. table.Count(ServerMapWSID) .. ' шт.')
            for m, id in pairs(ServerMapWSID) do RTVDbg('  ' .. m .. ' -> ' .. tostring(id)) end
        end
    end

    local SteamMat = {}
    local Pending = {}
    local IconQueue = {}
    local IconActive = 0
    local ICON_PARALLEL = 2

    local function MakeMaterialFromPath(path)
        local mat
        if isfunction(AddonMaterial) then mat = AddonMaterial(path) end
        if not mat or mat:IsError() then mat = Material(path, 'noclamp smooth') end
        if mat and not mat:IsError() then return mat end
    end

    local function FromDataFile(wsid)
        return MakeMaterialFromPath('data/rtv_icons/' .. wsid .. '.png')
    end

    local pumpQueue

    local function FinishIcon(wsid, mat)
        if mat and not mat:IsError() then
            SteamMat[wsid] = mat
            for _, cb in ipairs(Pending[wsid] or {}) do cb(mat) end
        end
        Pending[wsid] = nil
        IconActive = math.max(0, IconActive - 1)
        pumpQueue()
    end

    local function TryPreviewURL(wsid, info)
        if not (info.previewurl and info.previewurl ~= '') then return FinishIcon(wsid, nil) end
        local fileName = 'rtv_icons/' .. wsid .. '.png'
        if file.Exists(fileName, 'DATA') then return FinishIcon(wsid, FromDataFile(wsid)) end
        http.Fetch(info.previewurl, function(body)
            if not body or body == '' then return FinishIcon(wsid, nil) end
            file.CreateDir('rtv_icons')
            file.Write(fileName, body)
            FinishIcon(wsid, FromDataFile(wsid))
        end, function() FinishIcon(wsid, nil) end)
    end

    local function RunIcon(wsid)
        if file.Exists('rtv_icons/' .. wsid .. '.png', 'DATA') then
            local mat = FromDataFile(wsid)
            if mat then return FinishIcon(wsid, mat) end
        end
        if not (steamworks and steamworks.FileInfo) then return FinishIcon(wsid, nil) end
        steamworks.FileInfo(wsid, function(info)
            if not info then return FinishIcon(wsid, nil) end
            if info.previewid and steamworks.Download then
                steamworks.Download(info.previewid, true, function(path)
                    local mat = path and MakeMaterialFromPath(path)
                    if mat then return FinishIcon(wsid, mat) end
                    TryPreviewURL(wsid, info)
                end)
            else
                TryPreviewURL(wsid, info)
            end
        end)
    end

    pumpQueue = function()
        while IconActive < ICON_PARALLEL and #IconQueue > 0 do
            local wsid = table.remove(IconQueue, 1)
            IconActive = IconActive + 1
            RunIcon(wsid)
        end
    end

    local function FetchSteamIcon(mapName, cb)
        local wsid = ServerMapWSID[mapName]
        if not wsid then RTVDbg(mapName .. ': нет wsid от сервера') return end
        if SteamMat[wsid] then return cb(SteamMat[wsid]) end
        if Pending[wsid] then
            Pending[wsid][#Pending[wsid] + 1] = cb
            return
        end
        Pending[wsid] = { cb }
        IconQueue[#IconQueue + 1] = wsid
        pumpQueue()
    end

    --KartaKartochkaKartaKartochkaKartaKartochkaKartaKartochka eto kvadratic v korotom naxoditca karta
    local KartaKartochka = {}
    function KartaKartochka:Init()
        self.ImyaKarti = ''
        self.Avatarki = {}
        self.Pobeditel = false
        self.Vybrannaya = false
        self.Mat = nil
    end

    function KartaKartochka:Setup(name, parent)
        self.ImyaKarti = name
        self.Roditel = parent

        if name == 'random' then
            local m = Material('icon64/random.png', 'smooth')
            self.Mat = m:IsError() and nil or m -- nil -> Paint нарисует серый бокс с подписью "random"
            return
        end

        --Локальные превью карты, если они вообще есть
        for _, p in ipairs({ 'maps/thumb/' .. name .. '.png', 'maps/' .. name .. '.png' }) do
            local m = Material(p, 'smooth')
            if not m:IsError() then self.Mat = m return end
        end
        self.Mat = nil
        FetchSteamIcon(name, function(mat)
            if IsValid(self) and mat and not mat:IsError() then
                self.Mat = mat
            end
        end)
    end

    function KartaKartochka:Paint(w, h)
        if self.Mat then
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(self.Mat)
            surface.DrawTexturedRect(0, 0, w, h)
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(50,50,50,255))
        end
        draw.RoundedBox(0, 0, 0, w, 20, Color(0,0,0,180))
        draw.SimpleText(self.ImyaKarti:gsub('_', ' '), 'DermaDefault', w/2, 4, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

        if self.Vybrannaya then
            surface.SetDrawColor(255,200,0,240)
            surface.DrawOutlinedRect(0,0,w,h,2)
        end
        if self.Pobeditel then
            local alpha = math.abs(math.sin(RealTime() * 10)) * 255
            surface.SetDrawColor(255,255,0,alpha)
            surface.DrawOutlinedRect(0,0,w,h,3)
        end
    end

    function KartaKartochka:DoClick()
        if self.Roditel.VoteCooldown > CurTime() then return end
        self.Roditel:LocalVote(self.ImyaKarti)
        net.Start('ZB_RockTheVote_vote')
            net.WriteString(self.ImyaKarti)
        net.SendToServer()
        self.Roditel.VoteCooldown = CurTime() + 1
    end
    function KartaKartochka:OnMousePressed(code)
        if code == MOUSE_LEFT then self:DoClick() end
    end

    function KartaKartochka:UpdateAvatars(voters)
        for _, av in ipairs(self.Avatarki) do if av:IsValid() then av:Remove() end end
        self.Avatarki = {}
        if not voters then return end
        for _, sid64 in ipairs(voters) do
            local ply = player.GetBySteamID64(sid64)
            if IsValid(ply) then
                local av = vgui.Create('AvatarImage', self)
                av:SetPlayer(ply, 32)
                av:SetPaintedManually(false)
                av:SetMouseInputEnabled(false)
                table.insert(self.Avatarki, av)
            end
        end
        self:InvalidateLayout()
    end

    function KartaKartochka:PerformLayout(w, h)
        local avatarSize = 32
        local padding = 1
        local x, y = padding, h - avatarSize - padding
        local maxX = w - padding
        for _, av in ipairs(self.Avatarki) do
            if av:IsValid() then
                if x + avatarSize > maxX then x = padding; y = y - avatarSize - padding end
                av:SetPos(x, y)
                av:SetSize(avatarSize, avatarSize)
                x = x + avatarSize + padding
            end
        end
    end
    vgui.Register('RTVMapCard', KartaKartochka, 'DPanel')

    -- menushka golosovaniya!!!
    local PanelGolosovaniya = {}
    function PanelGolosovaniya:Init()
        self:SetSize(ScrW(), ScrH())
        self:SetPos(0,0)
        self:SetAlpha(0)
        self:AlphaTo(255, 0.5, 0)
        self:MakePopup()
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(true)

        self.VoteMaps = {}
        self.VoteEndTime = 0
        self.TotalDuration = 30
        self.Votes = {}
        self.WinnerMap = nil
        self.Kartochki = {}
        self.KartochkiOrder = {}
        self.VoteCooldown = 0
        self.MoySteamID64 = LocalPlayer():SteamID64()
        self.MoyGolos = nil

        self.Fon = function(_, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 220))
            local speed = 40
            local spacing = 50
            local offsetX = (CurTime() * speed) % spacing
            local offsetY = (CurTime() * 0.7 * speed) % spacing
            surface.SetDrawColor(255, 255, 255, 15)
            for x = offsetX, w, spacing do surface.DrawLine(x, 0, x, h) end
            for y = offsetY, h, spacing do surface.DrawLine(0, y, w, y) end
        end

        self.TopBar = vgui.Create('DPanel', self)
        self.TopBar:Dock(TOP)
        self.TopBar:SetTall(ScrH()*0.12)
        self.TopBar:DockMargin(ScrW()*0.05, ScrH()*0.03, ScrW()*0.05, 0)
        self.TopBar.Paint = function(_, w, h)
            local timeLeft = math.max(0, self.VoteEndTime - CurTime())
            local frac = math.Clamp(timeLeft / self.TotalDuration, 0, 1)
            local timeFormatted = string.FormattedTime(math.ceil(timeLeft), '%02i:%02i')
            local barY = h * 0.55
            local barH = h * 0.28
            local titleX = 10
            local titleY = barY - 50

            draw.SimpleTextOutlined('ГОЛОСОВАНИЕ ЗА СМЕНУ КАРТЫ', 'RTV.TitleFont', titleX, titleY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,15))
            draw.SimpleTextOutlined('ГОЛОСОВАНИЕ ЗА СМЕНУ КАРТЫ', 'RTV.TitleFont', titleX, titleY, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,30))
            local titleW = draw.SimpleText('ГОЛОСОВАНИЕ ЗА СМЕНУ КАРТЫ', 'RTV.TitleFont', titleX, titleY, Color(0,0,0,0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) or 120
            draw.SimpleTextOutlined(timeFormatted, 'RTV.TimeFont', titleX + titleW + 15, titleY + 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,15))
            draw.SimpleTextOutlined(timeFormatted, 'RTV.TimeFont', titleX + titleW + 15, titleY + 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0,0,0,30))

            local barW = w * 0.65
            local barX = titleX
            draw.RoundedBox(4, barX-2, barY-2, barW+4, barH+4, Color(0,0,0,30))
            draw.RoundedBox(4, barX-1, barY-1, barW+2, barH+2, Color(0,0,0,60))
            draw.RoundedBox(4, barX, barY, barW, barH, Color(60,60,60,200))
            if frac > 0 then
                local fillW = barW * frac
                draw.RoundedBox(4, barX, barY, fillW, barH, Color(255,255,255,240))
                draw.RoundedBox(2, barX+2, barY+2, fillW-4, barH*0.4, Color(255,255,255,80))
            end
            surface.SetDrawColor(255,255,255,200)
            surface.DrawOutlinedRect(barX, barY, barW, barH, 2)
        end

        self.KnopkaOst = vgui.Create('DPanel', self.TopBar)
        self.KnopkaOst:SetWidth(ScrW() * 0.15)
        self.KnopkaOst.AvatarkiOst = {}
        self.KnopkaOst.Vybrannaya = false
        self.KnopkaOst.Pobeditel = false
        self.KnopkaOst.Paint = function(pnl, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Color(0,0,0,180))
            local bg = pnl:IsHovered() and Color(100,100,100,240) or Color(70,70,70,230)
            draw.RoundedBox(6, 0, 0, w, h, bg)
            surface.SetDrawColor(255,255,255,40)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            if pnl.Vybrannaya then
                surface.SetDrawColor(255,200,0,240)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
            draw.SimpleText('ОСТАТЬСЯ', 'RTV.StayFont', w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        self.KnopkaOst.OnMousePressed = function(pnl, code)
            if code == MOUSE_LEFT then
                if self.VoteCooldown > CurTime() then return end
                self:LocalVote('stay')
                net.Start('ZB_RockTheVote_vote')
                    net.WriteString('stay')
                net.SendToServer()
                self.VoteCooldown = CurTime() + 1
            end
        end
        self.KnopkaOst.PerformLayout = function(pnl, w, h)
            local avatarSize = 20
            local padding = 2
            local x, y = padding + 3, h - avatarSize - padding - 2
            local maxX = w - padding - 3
            for _, av in ipairs(pnl.AvatarkiOst) do
                if av:IsValid() then
                    if x + avatarSize > maxX then x = padding + 3; y = y - avatarSize - padding end
                    av:SetPos(x, y)
                    av:SetSize(avatarSize, avatarSize)
                    x = x + avatarSize + padding
                end
            end
        end

        self.TopBar.PerformLayout = function(pnl, w, h)
            if IsValid(self.KnopkaOst) then
                local barY = h * 0.55
                local barH = h * 0.28
                local barW = w * 0.65
                local titleX = 10
                local barX = titleX
                local stayX = barX + barW + 20
                local stayW = w * 0.20
                self.KnopkaOst:SetPos(stayX, barY)
                self.KnopkaOst:SetSize(stayW, barH)
            end
        end

        self.MapsContainer = vgui.Create('DPanel', self)
        self.MapsContainer:Dock(FILL)
        self.MapsContainer:DockMargin(ScrW()*0.05, ScrH()*0.01, ScrW()*0.05, ScrH()*0.04)
        self.MapsContainer.Paint = nil

        self.Scroll = vgui.Create('DScrollPanel', self.MapsContainer) --https://gmodwiki.com/DScrollPanel
        self.Scroll:Dock(FILL)

        self.MapsInner = vgui.Create('DPanel')
        self.MapsInner.Paint = nil
        self.Scroll:AddItem(self.MapsInner)
    end

    function PanelGolosovaniya:LocalVote(mapName)
        if not mapName then return end
        local mySid = self.MoySteamID64
        if self.MoyGolos and self.Votes[self.MoyGolos] then
            for i, sid in ipairs(self.Votes[self.MoyGolos]) do
                if sid == mySid then table.remove(self.Votes[self.MoyGolos], i) break end
            end
            if #self.Votes[self.MoyGolos] == 0 then self.Votes[self.MoyGolos] = nil end
        end
        self.Votes[mapName] = self.Votes[mapName] or {}
        table.insert(self.Votes[mapName], mySid)
        self.MoyGolos = mapName
        for m, card in pairs(self.Kartochki) do
            if card:IsValid() then
                card.Vybrannaya = (m == mapName)
                card:UpdateAvatars(self.Votes[m] or {})
            end
        end
        if self.KnopkaOst then
            self.KnopkaOst.Vybrannaya = (mapName == 'stay')
            for _, av in ipairs(self.KnopkaOst.AvatarkiOst) do if av:IsValid() then av:Remove() end end
            self.KnopkaOst.AvatarkiOst = {}
            for _, sid64 in ipairs(self.Votes['stay'] or {}) do
                local ply = player.GetBySteamID64(sid64)
                if IsValid(ply) then
                    local av = vgui.Create('AvatarImage', self.KnopkaOst)
                    av:SetPlayer(ply, 32)
                    av:SetPaintedManually(false)
                    av:SetMouseInputEnabled(false)
                    table.insert(self.KnopkaOst.AvatarkiOst, av)
                end
            end
            self.KnopkaOst:InvalidateLayout()
        end
    end

    function PanelGolosovaniya:ZapolnitKartami(maps)
        self.MapsInner:Clear()
        self.Kartochki = {}
        self.KartochkiOrder = {}
        for _, m in ipairs(maps) do
            if m ~= 'stay' then
                local card = vgui.Create('RTVMapCard', self.MapsInner)
                card:Setup(m, self)
                self.Kartochki[m] = card
                self.KartochkiOrder[#self.KartochkiOrder + 1] = card -- порядок с сервера
            end
        end
        timer.Simple(0, function() if IsValid(self) then self:PereRisovka() end end)
    end

    function PanelGolosovaniya:PereRisovka() --scolko vsego mi mosem razmestit kartochek y igroka na ekrane
        local order = self.KartochkiOrder or {}
        local cardCount = #order
        if cardCount == 0 then return end
        local parentW = self.MapsContainer:GetWide()
        if parentW <= 0 then return end
        local cols = math.max(4, math.min(6, math.floor(parentW / 130)))
        local spacing = 8
        local totalSpacing = spacing * (cols + 1)
        local cardW = (parentW - totalSpacing) / cols
        local cardH = cardW
        local x, y = spacing, spacing
        local col = 0
        for _, card in ipairs(order) do
            if card:IsValid() then
                card:SetSize(cardW, cardH)
                card:SetPos(x, y)
                col = col + 1
                if col >= cols then
                    col = 0; x = spacing; y = y + cardH + spacing
                else
                    x = x + cardW + spacing
                end
            end
        end
        local totalRows = math.ceil(cardCount / cols)
        self.MapsInner:SetSize(parentW, totalRows * (cardH + spacing) + spacing)
    end

    function PanelGolosovaniya:PerformLayout(w, h)
        self:PereRisovka()
        if self.KnopkaOst then self.KnopkaOst:SetPos(w * 0.62, ScrH() * 0.065) end
    end
    function PanelGolosovaniya:Paint(w, h)
        self.Fon(self, w, h)
    end
    vgui.Register('ModernRTVPanel', PanelGolosovaniya, 'DPanel')

    --Esli xot ktoto skazet chto eto jbt to ya naxyi zastrlus
    function CloseRTV()
        if RTV_CloseTimer then
            timer.Remove("RTV_Close")
            RTV_CloseTimer = nil
        end
        if RTV_Music then
            RTV_Music:Stop()
            RTV_Music = nil
        end
        if IsValid(RTVPanel) then
            RTVPanel:Remove()
            RTVPanel = nil
        end
    end

    function OpenRTVPanel(maps, endTime, votes, isTest)
        CloseRTV()
        if not maps or #maps == 0 then return end
        RTVPanel = vgui.Create('ModernRTVPanel')
        RTVPanel.VoteMaps = maps
        RTVPanel.VoteEndTime = endTime
        RTVPanel.TotalDuration = endTime - CurTime()
        RTVPanel.Votes = votes or {}
        RTVPanel.MoyGolos = nil
        RTVPanel.IsTest = isTest and true or false
        RTVPanel:ZapolnitKartami(maps)

        if RTVPanel.IsTest then
            RTVPanel:SetKeyboardInputEnabled(true)
            RTVPanel.Think = function()
                if input.IsKeyDown(KEY_ESCAPE) then CloseRTV() end
            end
            local basePaint = RTVPanel.Paint
            RTVPanel.Paint = function(s, w, h)
                basePaint(s, w, h)
                draw.SimpleText('ТЕСТ RTV  —  ESC чтобы закрыть  (голоса и смена карты отключены)', 'RTV.StayFont', w / 2, h - 18, Color(255, 220, 120, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
        end

        RTV_Music = CreateSound(LocalPlayer(), "rtv/rtv_musica.wav")
        RTV_Music:Play()
    end

    net.Receive('ZB_RockTheVote_start', function()
        local maps = net.ReadTable()
        local endTime = net.ReadFloat()
        local wsids = net.ReadTable()
        local isTest = net.ReadBool()
        RTV_SetServerWSID(wsids)
        if not isTest then
            CachedMaps, CachedEndTime, CachedVotes = maps, endTime, {}
        end
        OpenRTVPanel(maps, endTime, {}, isTest)
    end)

    net.Receive('ZB_RockTheVote_voteCLreg', function()
        local votes = net.ReadTable()
        CachedVotes = votes
        if IsValid(RTVPanel) then
            RTVPanel.Votes = votes
            for map, card in pairs(RTVPanel.Kartochki) do
                if card:IsValid() then
                    card:UpdateAvatars(votes[map] or {})
                    card.Vybrannaya = (map == RTVPanel.MoyGolos)
                end
            end
            if RTVPanel.KnopkaOst then
                RTVPanel.KnopkaOst.Vybrannaya = (RTVPanel.MoyGolos == 'stay')
                for _, av in ipairs(RTVPanel.KnopkaOst.AvatarkiOst) do av:Remove() end
                RTVPanel.KnopkaOst.AvatarkiOst = {}
                for _, sid64 in ipairs(votes['stay'] or {}) do
                    local ply = player.GetBySteamID64(sid64)
                    if IsValid(ply) then
                        local av = vgui.Create('AvatarImage', RTVPanel.KnopkaOst)
                        av:SetPlayer(ply, 32)
                        av:SetPaintedManually(false)
                        av:SetMouseInputEnabled(false)
                        table.insert(RTVPanel.KnopkaOst.AvatarkiOst, av)
                    end
                end
                RTVPanel.KnopkaOst:InvalidateLayout()
            end
        end
    end)

    net.Receive('ZB_RockTheVote_end', function()
        local winner = net.ReadString()
        CachedMaps = nil
        if IsValid(RTVPanel) then
            RTVPanel.WinnerMap = winner
            if winner ~= 'stay' and RTVPanel.Kartochki[winner] then
                RTVPanel.Kartochki[winner].Pobeditel = true
            elseif winner == 'stay' and RTVPanel.KnopkaOst then
                RTVPanel.KnopkaOst.Pobeditel = true
                local oldPaint = RTVPanel.KnopkaOst.Paint
                RTVPanel.KnopkaOst.Paint = function(pnl, w, h)
                    oldPaint(pnl, w, h)
                    if pnl.Pobeditel then
                        local alpha = math.abs(math.sin(RealTime() * 10)) * 255
                        surface.SetDrawColor(255,255,0,alpha)
                        surface.DrawOutlinedRect(0,0,w,h,3)
                    end
                end
            end
            RTVPanel.VoteCooldown = math.huge
            surface.PlaySound('buttons/combine_button_locked.wav')
            if RTV_CloseTimer then timer.Remove("RTV_Close") end
            RTV_CloseTimer = "RTV_Close"
            timer.Create("RTV_Close", 5, 1, function() CloseRTV() end)
        end
    end)

    net.Receive('RTVMenu', function()
        if IsValid(RTVPanel) then RTVPanel:MoveToFront() return end
        if CachedMaps and CachedEndTime > CurTime() then
            OpenRTVPanel(CachedMaps, CachedEndTime, CachedVotes)
        end
    end)
end