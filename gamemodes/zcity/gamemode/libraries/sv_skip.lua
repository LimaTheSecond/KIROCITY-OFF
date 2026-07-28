-- ████ █   █ ████  █████ ████     ████  ███ █████ ████   ███  █████  ███  █████     ████ █   █ ███ ████      ███   ███  █      ███   ████  ███  █   █  ███  █   █ ███ █████ 
--█      █ █  █   █ █     █   █    █   █  █     █  █   █ █   █   █   █   █ █        █     █  █   █  █   █    █     █   █ █     █   █ █     █   █ █   █ █   █ ██  █  █  █     
-- ███    █   ████  ████  ████     ████   █    █   █   █ █████   █   █   █ ████      ███  ███    █  ████     █  ██ █   █ █     █   █  ███  █   █ █   █ █████ █ █ █  █  ████  
--    █   █   █     █     █  █     █      █   █    █   █ █   █   █   █   █ █            █ █  █   █  █        █   █ █   █ █     █   █     █ █   █  █ █  █   █ █  ██  █  █     
--████    █   █     █████ █   █    █     ███ █████ ████  █   █   █    ███  █████    ████  █   █ ███ █         ███   ███  █████  ███  ████   ███    █   █   █ █   █ ███ █████ 

if SERVER then
    local skipVotes = {} -- крч в эту таблицу добаляются игроки которые проголосавали а точнее в нее добовляем их стим айдди
    local skipEnded = false --если проголосуют то флаг будет тру

    local function SkipNeeded()
        return math.ceil(player.GetCount() * 0.51) --0.7 это нужно 70 процентов сервера чтобы проголосало для скипа
    end

    local function CheckSkip()
        if skipEnded then return end
        if table.Count(skipVotes) >= SkipNeeded() then -- если if table.Count(skipVotes) достигло 0.7 то скипаем раунд (оно округляет ещо)
            skipEnded = true
            for _, v in player.Iterator() do
                v:ChatPrint("Набралось достаточное количество за скип раунда")
            end
            zb:EndRound()
        end
    end

    COMMANDS.skip = {function(ply, args)
        if skipEnded then return end
        local sid = ply:SteamID()
        if skipVotes[sid] then --если его стим айди есть в талице спиквоут тогда он забирает свой гоос и флаг ставим на фалз
            skipVotes[sid] = nil
            for _, v in player.Iterator() do
                v:ChatPrint(ply:Nick() .. " забрал свой голос за скип")
            end
        else
            skipVotes[sid] = true
            local needed = SkipNeeded()
            local left = needed - table.Count(skipVotes)
            for _, v in player.Iterator() do --если не голосовал то добавляем его в таблицу и ставим флаг на тру и вычисляем сколько ещё нужно
                v:ChatPrint(ply:Nick() .. " проголосовал за скип, ещё нужно " .. left .. " голосов. Напишите повторно !skip если хотите отменить голос")
            end
            CheckSkip()
        end
    end, 0}

    hook.Add("PlayerDisconnected", "SkipVoteDisconnect", function(ply) --если бро вышел то убираем его стим айди из таблицы
        if skipVotes[ply:SteamID()] then
            skipVotes[ply:SteamID()] = nil
            CheckSkip()
        end
    end)

    hook.Add("ZB_PreRoundStart", "ClearSkipVotes", function() --очищяет таблицу скипов если в прошлом раунде скипа небыло то в новом таблица очиститься
        table.Empty(skipVotes)
        skipEnded = false
    end)
end

--для даунов код расписываю чтобы не пиздели что джбт
--это буквально точно такаяже логика как с голосованием !rtv
--щяс пиздеть будуте что если в коде есть коменты то это джбтт