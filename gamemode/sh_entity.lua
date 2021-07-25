local meta = FindMetaTable("Entity")

function meta:GetPropSize(bool)
	local hullxy = math.Round(math.Max(self:OBBMaxs().x - self:OBBMins().x, self:OBBMaxs().y - self:OBBMins().y) / 2)
	local hullg =  math.Round(math.Min(self:OBBMaxs().x - self:OBBMins().x, self:OBBMaxs().y - self:OBBMins().y) / 2)
	local hullz = math.Round(self:OBBMaxs().z - self:OBBMins().z)
	if bool then
		return hullxy, hullz, hullg
	end
	return hullxy, hullz
end

function meta:CSGetPropSize(bool)
	local OBBMins, OBBMaxs = self:GetRenderBounds()
	local hullxy = math.Round(math.Min(OBBMaxs.x, OBBMaxs.y))
	local hullg =  math.Round(math.Min(OBBMaxs.x - OBBMins.x, OBBMaxs.y - OBBMins.y) / 2)
	local hullz = math.Round(OBBMaxs.z - OBBMins.z)
	if bool then
		return hullxy, hullz, hullg
	end
	return hullxy, hullz
end