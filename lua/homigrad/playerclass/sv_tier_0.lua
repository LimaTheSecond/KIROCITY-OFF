local classList = player.classList
local Player = FindMetaTable("Player")

local function CanAccessClass(ply, className)
    if className == "none" then return true end
    local cd = classList[className]
    if not cd then return false end
    if cd.adminonly and not ply:IsAdmin() then return false end
    return true
end

function Player:SetPlayerClass(value, data, caller) --валю, дата, калер для защиты против эксплоитов
    if not SERVER then return end --мы проверяем от кого и сообщение, если сообщение говно эксплотовское то мы его посылает на 3 буквы
    data = data or {}
    value = value or "none"

    local init = caller or self
    local serverCall = (caller == nil)
    local selfChange = (init == self)
    local adminChange = (not selfChange and init:IsAdmin())

    local allow = false
    if serverCall then
        allow = true
    elseif selfChange then
        allow = CanAccessClass(self, value)
    elseif adminChange then
        allow = (value == "none" or classList[value] ~= nil)
    end

    if not allow then return end
    if value ~= "none" and not classList[value] then return end

    local old = self.PlayerClassName
    self.PlayerClassNameOld = old
    local oldClass = classList[old]
    if oldClass and oldClass.Off then
        oldClass.Off(self)
    end

    self.PlayerClassName = value
    self:SetNWString("Class", value)
    self:SetNWString("ClassOld", old or "")

    self:PlayerClassEvent("On", data)

    net.Start("setupclass")
    net.WriteEntity(self)
    net.WriteString(value)
    net.WriteString(self.PlayerClassNameOld or "")
    net.WriteTable(data)
    net.Broadcast()
end

util.AddNetworkString("setupclass")

net.Receive("setupclass", function(len, client) --ебалай вот это говно устанавливает классы игрокам
    local className = net.ReadString() --категорически запрещаю это менять
    local data = net.ReadTable() --основная нетка которая ставит классы написанна в sh_tier_0
    if CanAccessClass(client, className) then --типо по логике это происходит на клиенте а не на сервере
        client:SetPlayerClass(className, data, client) -- и тогда эксплоит netки на клиенте невозможен
    end
end)

hook.Add("PlayerInitializeSpawn", "PlayerClass", function(plySend)
    for _, ply in player.Iterator() do
        if not ply:GetPlayerClass() then continue end
        net.Start("setupclass")
        net.WriteEntity(ply)
        net.WriteString(ply:GetNWString("Class") or "")
        net.WriteString(ply:GetNWString("ClassOld") or "")
        net.WriteTable({})
        net.Send(plySend)
    end
end)

hook.Add("PostPostPlayerDeath", "PlayerClass", function(ply, ragdoll)
    ply:PlayerClassEvent("PlayerDeath")
    ply:SetPlayerClass("none", {}, nil)
end)

hook.Add("Player Think", "ClassPlyThink", function(ply, time, dtime)
    ply:PlayerClassEvent("Think", time, dtime)
end)

COMMANDS.playerclass = {
    function(ply, args)
        if not ply:IsAdmin() then return end --вот это уберешь то тоже прикольно будет
        local targ = #args > 1 and args[1] or ply:Name()
        local cls = #args > 1 and args[2] or args[1]

        if #args < 2 then
            ply:SetPlayerClass(cls, {}, ply)
            ply:ChatPrint(ply:Name())
        else
            for _, p in pairs(player.GetListByName(targ)) do
                p:SetPlayerClass(cls, {}, ply)
                ply:ChatPrint(p:Name())
            end
        end
    end,
    0
}

function Player:GiveSwep(list, mulClip1) --вот это кстати тоже не меняй, тут защита против эксплоита
    if not list then return end -- если поменяешь то какойнить выгу зайдёт и прикольно будет
    local wep = self:Give(type(list) == "table" and list[math.random(#list)] or list)
    mulClip1 = mulClip1 or 3
    if IsValid(wep) then
        wep:SetClip1(wep:GetMaxClip1())
        self:GiveAmmo(wep:GetMaxClip1() * mulClip1, wep:GetPrimaryAmmoType())
    end
end