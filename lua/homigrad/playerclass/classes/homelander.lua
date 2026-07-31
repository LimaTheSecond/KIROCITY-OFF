local CLASS = player.RegClass("homelander")

function CLASS.Off(self)
    if CLIENT then return end
end

function CLASS.On(self)
    if CLIENT then return end
    self:SetModel("models/theboys/homelander.mdl")
    self:SetPlayerColor(Color(190, 0, 0):ToVector())
    self:SetNWString("PlayerName", "Homelander")
    self:SetNetVar("Accessories", "none")
end

CLASS.CanUseDefaultPhrase = true
CLASS.CanEmitRNDSound = true
CLASS.CanUseGestures = true

function CLASS.Guilt(self, Victim)
    if CLIENT then return end
    return 1, true
end