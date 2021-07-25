local meta = FindMetaTable("Player")

GM.PropsHP = {}

if GAMEMODE then
	GM.PropsHP = GAMEMODE.PropsHP
end

if CLIENT then
	net.Receive("SyncData", function()
		GAMEMODE.PropsHP = net.ReadTable()
		blackListModel = net.ReadTable()
	end)
end

allowClasses = {}
allowClasses['prop_physics'] = true
allowClasses['prop_physics_multiplayer'] = true

blackListModel = blackListModel or {}
//blackListModel['models/props/cs_office/computer_mouse.mdl'] = true
Totor = Totor or {}

function Totor.DisableModelExpa(ply)
	if ply:Team() != TEAM_HUNT then
		return false
	end
	return true
end

ConfigPH = ConfigPH or {}
ConfigPH['AR2Secondary'] = 1
ConfigPH['SMGSecondary'] = 1
ConfigPH['Grenade'] = 1
ConfigPH['MaxRounds'] = 20

if SERVER then
	function GM:LoadDataProps() 
		local json = file.Read("prophunt/" .. game.GetMap() .. "/propHP.txt", "DATA")
		if json then
			self.PropsHP = util.JSONToTable(json)
		end
		local json = file.Read("prophunt/" .. game.GetMap() .. "/blackListModel.txt", "DATA")
		if json then  
			blackListModel = util.JSONToTable(json)
		end
	end
	function GM:SyncDataProps(plys)
		net.Start("SyncData")
		net.WriteTable( self.PropsHP )
		net.WriteTable( blackListModel )
		if plys then
			net.Send(plys)
		else
			net.Broadcast()
		end
	end

	function GM:SaveDataProps()
		if !file.Exists("prophunt/","DATA") then
			file.CreateDir("prophunt")
		end

		local mapName = game.GetMap()
		if !file.Exists("prophunt/" .. mapName .. "/","DATA") then
			file.CreateDir("prophunt/" .. mapName)
		end
		
		local json = util.TableToJSON(self.PropsHP)
		file.Write("prophunt/" .. mapName .. "/propHP.txt", json)
		
		local json = util.TableToJSON(blackListModel)
		file.Write("prophunt/" .. mapName .. "/blackListModel.txt", json)
		//print(json)
		self:SyncDataProps() 
	end
end

-- function ulx.openSpisok( calling_ply )
-- 	GAMEMODE:OpenWindowBoo(calling_ply)
-- end

-- local openSpisok = ulx.command( "PROPHUNT", "ulx propeditor", ulx.openSpisok )
-- openSpisok:defaultAccess( ULib.ACCESS_SUPERADMIN )
-- openSpisok:help( "Открытие окна, который позволяет редактировать разрешенные пропы." )

function meta:CanProp(ent)

	if !self:Alive() then return false end
	if self:Team() != TEAM_PROP then return false end
	if !IsValid(ent) then return false end
	
	if !allowClasses[ent:GetClass()] then
		return false
	end
	if blackListModel[ent:GetModel()] then
		return false
	end

	return true
end

function meta:CanFitHull(hullx, hully, hullz)
	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = self:GetPos()
	trace.filter = self
	trace.maxs = Vector(hullx, hully, hullz)
	trace.mins = Vector(-hullx, -hully, 0)
	local tr = util.TraceHull(trace)
	if tr.Hit then 
		return false
	end
	return true
end

local function colMul(color, mul)
	color.r = math.Clamp(math.Round(color.r * mul), 0, 255)
	color.g = math.Clamp(math.Round(color.g * mul), 0, 255)
	color.b = math.Clamp(math.Round(color.b * mul), 0, 255)
end