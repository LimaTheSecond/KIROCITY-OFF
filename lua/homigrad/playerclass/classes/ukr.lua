local CLASS = player.RegClass("ukr")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/uk/ukrainian_soldier.mdl"
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self, nil, nil, nil, true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNWString("PlayerName", Appearance.AName)
    self:SetPlayerColor(Color(0, 120, 255):ToVector())
    self:SetModel(models[math.random(#models)])
    for _, bg in ipairs(self:GetBodyGroups()) do
        self:SetBodygroup(bg.id, math.random(0, bg.num))
    end

    local inv = self:GetNetVar("Inventory", {})
    inv["Weapons"] = inv["Weapons"] or {}
    inv["Weapons"]["hg_sling"] = true
    self:SetNetVar("Inventory", inv)

    self:SetSubMaterial()
    self.CurAppearance = Appearance
end