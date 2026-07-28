if SERVER then
    util.AddNetworkString("ZB_RockTheVote_start")
    util.AddNetworkString("ZB_RockTheVote_vote")
    util.AddNetworkString("ZB_RockTheVote_voteCLreg")
    util.AddNetworkString("ZB_RockTheVote_end")
    util.AddNetworkString("RTVMenu")

    zb = zb or {}
    local kd_golosa = {}
    local golosa = {}
    zb.votestarted = false
    local playervote = {}
    local vse_karti = {}
    zb.currentVoteMaps = {}

    CreateConVar("zb_rtv_max_maps", 7, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Максимум карт в голосовании ртв")
    CreateConVar("zb_rtv_recent_exclude", 5, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Сколько недавно выбранных карт не показывать") --чтобы небыло скучно играть на одном дайскрапере
    CreateConVar("zb_rtv_stay_cooldown", 30, {FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE}, "Кулдаун после победы опции остаться") --бесполезная херня но она нужна была мне

    zb.LastMaps = zb.LastMaps or {}
    local chernyy_spisok = {
        ["gm_construct"] = true, ["gm_flatgrass"] = true, ["gm_altarskforest"] = true,
        ["gm_renostruct_v2"] = true, ["gm_renostruct_v2_night"] = true,
        ["gm_city_of_silence"] = true, ["ttt_hogwarts"] = true,
    }
    local razreshennye_prefiksy = {
        ["ttt"] = true, ["hmcd"] = true, ["mu"] = true, ["ze"] = false,
        ["zs"] = true, ["tdm"] = true, ["zb"] = false, ["zbattle"] = false,
        ["gm"] = true, ["ph"] = true, ["cs"] = true, ["de"] = true
    }

    local function obnovit_karti()
        table.Empty(vse_karti)
        local maps = file.Find("maps/*.bsp", "GAME")
        for _, map in ipairs(maps) do
            map = map:sub(1, -5)
            local mapstr = map:Split("_")
            if (razreshennye_prefiksy[mapstr[1]] or not string.find(map, "_")) and not chernyy_spisok[map] then
                table.insert(vse_karti, map)
            end
        end
    end

    zb.RTVManualWSID = zb.RTVManualWSID or {}
    local mapWSID = {}
    local wsidGotov = false
    local function NormName(s)
        return (string.lower(tostring(s)):gsub("[^%w]", ""))
    end

    local WSID_CACHE_FILE = "rtv_wsid_cache.json"
    local function SaveWSIDCache()
        file.Write(WSID_CACHE_FILE, util.TableToJSON(mapWSID))
    end

    local function LoadWSIDCache()
        if not file.Exists(WSID_CACHE_FILE, "DATA") then return end
        local t = util.JSONToTable(file.Read(WSID_CACHE_FILE, "DATA") or "")
        if istable(t) then
            for m, id in pairs(t) do
                if id and id ~= "" then mapWSID[m] = tostring(id) end
            end
        end
    end

    local function AllResolved()
        if #vse_karti == 0 then return false end
        for _, m in ipairs(vse_karti) do
            if not mapWSID[m] then return false end
        end
        return true
    end

    local function ScanLocalGMA()
        if not (engine and engine.GetAddons and isfunction(game.MountGMA)) then return end
        for _, addon in ipairs(engine.GetAddons()) do
            if not addon.mounted then continue end
            local wsid = addon.wsid
            if not wsid or wsid == "" or wsid == "0" then continue end
            local ok, files = pcall(game.MountGMA, addon.file)
            if ok and istable(files) then
                for _, f in ipairs(files) do
                    local mp = string.match(f, "^maps/([%w_%.%-]+)%.bsp$")
                    if mp then mapWSID[mp] = wsid end
                end
            end
        end
    end

    local function ResolveViaCollection(done)
        done = done or function() end
        local cv = GetConVar("host_workshop_collection")
        local colId = cv and cv:GetString() or ""
        if colId == "" or colId == "0" then return done() end
        if not (http and http.Post) then return done() end

        http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetCollectionDetails/v1/",
            { collectioncount = "1", ["publishedfileids[0]"] = colId },
            function(body)
                local ok, data = pcall(util.JSONToTable, body)
                local cd = ok and data and data.response and data.response.collectiondetails
                local kids = cd and cd[1] and cd[1].children
                if not kids or #kids == 0 then return done() end

                local params = { itemcount = tostring(#kids) }
                for i, c in ipairs(kids) do
                    params["publishedfileids[" .. (i - 1) .. "]"] = tostring(c.publishedfileid)
                end

                http.Post("https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/",
                    params,
                    function(body2)
                        local ok2, d2 = pcall(util.JSONToTable, body2)
                        local items = ok2 and d2 and d2.response and d2.response.publishedfiledetails
                        if not items then return done() end

                        local mapItems = {}
                        for _, it in ipairs(items) do
                            local isMap = false
                            if it.tags then
                                for _, t in ipairs(it.tags) do
                                    if string.lower(tostring(t.tag)) == "map" then isMap = true break end
                                end
                            end
                            if isMap and it.publishedfileid then
                                table.insert(mapItems, { id = tostring(it.publishedfileid), nt = NormName(it.title) })
                            end
                        end

                        for _, m in ipairs(vse_karti) do
                            if mapWSID[m] then continue end
                            local nm = NormName(m)
                            if nm == "" then continue end
                            for _, mi in ipairs(mapItems) do
                                if mi.nt == nm or string.find(mi.nt, nm, 1, true)
                                or (#mi.nt > 2 and string.find(nm, mi.nt, 1, true)) then
                                    mapWSID[m] = mi.id
                                    break
                                end
                            end
                        end
                        done()
                    end,
                    function() done() end)
            end,
            function() done() end)
    end

    local function ApplyManual()
        for m, id in pairs(zb.RTVManualWSID) do
            if id and id ~= "" then mapWSID[m] = tostring(id) end
        end
    end
    local function obnovit_wsid(done)
        wsidGotov = true
        ApplyManual()
        if AllResolved() then
            SaveWSIDCache()
            if done then done() end
            return
        end
        ScanLocalGMA()
        ApplyManual()
        if AllResolved() then
            SaveWSIDCache()
            if done then done() end
            return
        end
        ResolveViaCollection(function()
            ApplyManual()
            SaveWSIDCache()
            if done then done() end
        end)
    end

    hook.Add("InitPostEntity", "zb_ObnovitKarti", function()
        zb.votestarted = false
        obnovit_karti()
        LoadWSIDCache()
        timer.Simple(10, function() obnovit_wsid() end)
    end)

    concommand.Add("rtv_wsid_dump", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        obnovit_karti()
        obnovit_wsid(function()
            local n = 0
            for _, m in ipairs(vse_karti) do
                print(string.format("[RTV-WSID] %-34s -> %s", m, mapWSID[m] or "<нет>"))
                if mapWSID[m] then n = n + 1 end
            end
            print("[RTV-WSID] карт с wsid: " .. n .. " / " .. #vse_karti)
        end)
        print("[RTV-WSID] запрос отправлен, жду ответ Steam (1-3 сек)...")
    end)

    concommand.Add("rtv_test", function(ply)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        obnovit_karti()

        local function fire()
            local maps = table.Copy(vse_karti)
            if #maps == 0 then maps = { "gm_construct" } end
            for i = #maps, 2, -1 do
                local j = math.random(i)
                maps[i], maps[j] = maps[j], maps[i]
            end
            table.insert(maps, "random")

            local wsids = {}
            for _, m in ipairs(maps) do
                if mapWSID[m] then wsids[m] = mapWSID[m] end
            end

            if not IsValid(ply) then return end
            net.Start("ZB_RockTheVote_start")
                net.WriteTable(maps)
                net.WriteFloat(CurTime() + 30)
                net.WriteTable(wsids)
                net.WriteBool(true)
            net.Send(ply)
        end
        if not wsidGotov then obnovit_wsid(fire) else fire() end
    end)

    net.Receive("ZB_RockTheVote_vote", function(len, ply)
        if not zb.votestarted then return end
        if kd_golosa[ply:EntIndex()] and kd_golosa[ply:EntIndex()] > CurTime() then return end
        kd_golosa[ply:EntIndex()] = CurTime() + 1

        local playerIdx = ply:EntIndex()
        local sid64 = ply:SteamID64()
        local karta = net.ReadString()
        if not karta or karta == "" then return end

        local valid = (karta == "random" or karta == "stay" or table.HasValue(zb.currentVoteMaps, karta))
        if not valid then return end

        local predKarta = playervote[playerIdx]
        if predKarta and golosa[predKarta] then
            for i, v in ipairs(golosa[predKarta]) do
                if v == sid64 then
                    table.remove(golosa[predKarta], i)
                    break
                end
            end
            if #golosa[predKarta] == 0 then golosa[predKarta] = nil end
        end

        golosa[karta] = golosa[karta] or {}
        table.insert(golosa[karta], sid64)
        playervote[playerIdx] = karta

        net.Start("ZB_RockTheVote_voteCLreg")
            net.WriteTable(golosa)
        net.Broadcast()
    end)

    local golosovanie_zaversheno = false
    local function PushRecentMap(map)
        if not map or map == "stay" then return end
        local maxRecent = GetConVar("zb_rtv_recent_exclude"):GetInt()
        if maxRecent <= 0 then return end
        for i, m in ipairs(zb.LastMaps) do
            if m == map then
                table.remove(zb.LastMaps, i)
                break
            end
        end
        table.insert(zb.LastMaps, map)
        while #zb.LastMaps > maxRecent do
            table.remove(zb.LastMaps, 1)
        end
    end

    zb.StayCooldownUntil = zb.StayCooldownUntil or 0
    function zb.EndRTV()
        if golosovanie_zaversheno then return end
        golosovanie_zaversheno = true

        local podschet = {}
        for karta, igroki in pairs(golosa) do
            podschet[karta] = #igroki
        end

        local karta_pobeditel = nil
        local maxGolosov = 0
        for karta, kolvo in pairs(podschet) do
            if kolvo > maxGolosov then
                maxGolosov = kolvo
                karta_pobeditel = karta
            elseif kolvo == maxGolosov and karta < (karta_pobeditel or "") then
                karta_pobeditel = karta
            end
        end

        if not karta_pobeditel or karta_pobeditel == "stay" then
            zb.votestarted = false
            hook.Remove("Think", "RTVThink")
            net.Start("ZB_RockTheVote_end")
                net.WriteString("stay")
            net.Broadcast()
            table.Empty(golosa)
            table.Empty(playervote)
            zb.ClearRTVVotes()
            zb.StayCooldownUntil = CurTime() + GetConVar("zb_rtv_stay_cooldown"):GetInt()
            return
        end

        if karta_pobeditel == "random" then
            net.Start("ZB_RockTheVote_end")
                net.WriteString("random")
            net.Broadcast()
            timer.Simple(3, function()
                local realMap = vse_karti[math.random(#vse_karti)]
                if not realMap then realMap = "gm_construct" end
                PushRecentMap(realMap)
                table.Empty(golosa)
                table.Empty(playervote)
                RunConsoleCommand("changelevel", realMap)
            end)
            return
        end

        if not table.HasValue(vse_karti, karta_pobeditel) then
            karta_pobeditel = "gm_construct"
        end
        PushRecentMap(karta_pobeditel)

        net.Start("ZB_RockTheVote_end")
            net.WriteString(karta_pobeditel)
        net.Broadcast()

        timer.Simple(3, function()
            table.Empty(golosa)
            table.Empty(playervote)
            RunConsoleCommand("changelevel", karta_pobeditel)
        end)
    end

    local rtvtime = 0
    function zb.ThinkRTV()
        if not zb.votestarted then return end
        if rtvtime < CurTime() then zb.EndRTV() end
    end

    function zb.StartRTV()
        if zb.votestarted then return end
        if CurTime() < zb.StayCooldownUntil then return end
        obnovit_karti()
        if not wsidGotov then obnovit_wsid() end
        rtvtime = CurTime() + 30

        golosovanie_zaversheno = false
        table.Empty(golosa)
        table.Empty(playervote)

        local vseValidnye = table.Copy(vse_karti)
        local recentSet = {}
        for _, m in ipairs(zb.LastMaps) do
            recentSet[m] = true
        end
        for i = #vseValidnye, 1, -1 do
            if recentSet[vseValidnye[i]] then
                table.remove(vseValidnye, i)
            end
        end

        if #vseValidnye == 0 then
            zb.LastMaps = {}
            vseValidnye = table.Copy(vse_karti)
        end

        local maxMaps = GetConVar("zb_rtv_max_maps"):GetInt()
        if #vseValidnye > maxMaps then
            for i = #vseValidnye, 2, -1 do
                local j = math.random(i)
                vseValidnye[i], vseValidnye[j] = vseValidnye[j], vseValidnye[i]
            end
            vseValidnye = {unpack(vseValidnye, 1, maxMaps)}
        end

        for i = #vseValidnye, 2, -1 do
            local j = math.random(i)
            vseValidnye[i], vseValidnye[j] = vseValidnye[j], vseValidnye[i]
        end

        table.insert(vseValidnye, "random")
        zb.currentVoteMaps = vseValidnye
        local wsids = {}
        for _, m in ipairs(vseValidnye) do
            if mapWSID[m] then wsids[m] = mapWSID[m] end
        end

        net.Start("ZB_RockTheVote_start")
            net.WriteTable(vseValidnye)
            net.WriteFloat(rtvtime)
            net.WriteTable(wsids)
            net.WriteBool(false)
        net.Broadcast()
        zb.votestarted = true
        hook.Add("Think", "RTVThink", zb.ThinkRTV)
    end

    function zb.RTVMenu(ply)
        net.Start("RTVMenu") net.Send(ply)
    end

    COMMANDS.forcertv = {function(ply, args)
        if not ply:IsAdmin() then ply:ChatPrint("Нету доступа!") return end
        zb.StartRTV(0)
    end, 0}

    local rtv_golosa_komandy = {}
    function zb.ClearRTVVotes()
        rtv_golosa_komandy = {}
        timer.Remove("RTVTimeout")
    end

    function zb.CheckRTVVotes(needPrint)
        local nuzhno = math.ceil(#player.GetAll() / 2)
        if table.Count(rtv_golosa_komandy) >= nuzhno then
            if needPrint then
                for _, v in player.Iterator() do
                    v:ChatPrint("Достаточно голосов для смены карты, голосование за новую карту будет в следуйщем раунде!")
                end
            end
            return true
        end
        return false
    end

    COMMANDS.rtv = {function(ply, args)
        if zb.votestarted then
            zb.RTVMenu(ply)
            return
        end
        local sid = ply:SteamID()
        if rtv_golosa_komandy[sid] then
            rtv_golosa_komandy[sid] = nil
            ply:ChatPrint("Вы забрали твой голос за смену карты!")
            return
        end
        rtv_golosa_komandy[sid] = true
        local nuzhno = math.ceil(#player.GetAll() / 2)
        local ostalos = nuzhno - table.Count(rtv_golosa_komandy)
        for _, v in player.Iterator() do
            if ostalos > 0 then
                v:ChatPrint(ply:Nick() .. " Проголосовал за смену карты " .. ostalos .. " ещё нужно, пропишите !rtv чтобы забрать голос за смену карты")
            end
        end
        if zb.CheckRTVVotes(true) then return end
    end, 0}

    hook.Add("ShutDown", "ResetRTVVotes", zb.ClearRTVVotes)
    hook.Add("PostGamemodeLoaded", "InitRTV", zb.ClearRTVVotes)

    hook.Add("PlayerDisconnected", "RTVDisconnect", function(ply)
        if rtv_golosa_komandy[ply:SteamID()] then
            rtv_golosa_komandy[ply:SteamID()] = nil
            timer.Simple(0.1, function() zb.CheckRTVVotes(false) end)
        end
    end)
end
-- да я удалил коменты от разембена, ртв меню моё, а с его коментами код стал книгой