local CLASS = player.RegClass("rus_drone")

function CLASS.Off(self)
    if CLIENT then return end
end

local models = {
    "models/ru/soilder_rf_02.mdl",
    "models/ru/soilder_rf_04.mdl",
    "models/ru/soilder_rf_05.mdl",
    "models/ru/soilder_rf_07.mdl",
    "models/ru/soilder_rf_08.mdl"
}

function CLASS.On(self)
    if CLIENT then return end
    ApplyAppearance(self, nil, nil, nil, true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNWString("PlayerName", Appearance.AName)
    self:SetPlayerColor(Color(190, 0, 0):ToVector())
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