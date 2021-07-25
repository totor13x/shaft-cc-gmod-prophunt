AddCSLuaFile()

ENT.Type   = "anim"

ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Entity",0,"Puppet")
	self:NetworkVar("Entity",1,"User")
end

function ENT:OnRemove()
	local ply = self:GetOwner()
	if IsValid(ply) then
		ply:SetRenderMode(RENDERMODE_TRANSALPHA)
		if SERVER then
			ply:SetSolid(SOLID_VPHYSICS)
			ply:DrawShadow(true)
			ply:SetNotSolid(true)
			ply:DrawViewModel(true)
			ply:SetMoveType(MOVETYPE_WALK)
			ply:PlayerResetHull()
		end
	end
end

function ENT:Initialize()
	local ply = self:GetOwner()
	ply:SetRenderMode(RENDERMODE_NONE)
	if SERVER then
		ply:SetModel("models/player/chicken.mdl")
		self:SetModel("models/player/chicken.mdl")
		self:SetPos(ply:GetPos())
		self:SetParent(ply)
		self:DrawShadow(false)
		self:SetUser(ply)
		
		ply:DrawShadow(false)
		ply:DrawViewModel(false)
		ply:SetMoveType(MOVETYPE_WALK)
	
		local puppet=ents.Create("ph_puppet")
		puppet:SetModel("models/player/chicken.mdl")
		puppet:SetRenderMode(RENDERMODE_TRANSALPHA)
		puppet:Spawn()
		ply:SetNWEntity('propme', puppet)
		
		ply.Ang = puppet:GetAngles()
		
		local hullxy, hullz, hully = puppet:GetPropSize(true)
		print(hullxy, hullz, hullly) 
		ply:PlayerSetHull(hully, hully, hullz, hullz)

		self:SetPuppet(puppet)	 
		self:DeleteOnRemove(puppet)
		ply:DeleteOnRemove(self)	
	end
end

function ENT:ChangeModel(ent)
	local ply = self:GetUser()
	local puppet = self:GetPuppet()
	
	timer.Simple(0, function() 
		if IsValid(self) then
			local phys = ent:GetPhysicsObject()
			local maxHealth = 1
			local hpphys = math.Round(phys:GetVolume() / 500)
			if GAMEMODE.PropsHP[ent:GetModel()] then
				hpphys = GAMEMODE.PropsHP[ent:GetModel()]
			end
			if IsValid(phys) then
				maxHealth = math.Clamp(hpphys, 1, 200)
			end
			self.PercentageHealth = math.min(ply:Health() / ply:GetMaxHealth(), self.PercentageHealth or 1)
			ply:SetNWInt("HPPer", self.PercentageHealth)
			local per = math.Clamp(self.PercentageHealth * maxHealth, 1, 200)
			ply:SetHealth(per)
			ply:SetMaxHealth(maxHealth)
		end
	end)
	
	puppet:SetModel(ent:GetModel())
	puppet:SetSkin(ent:GetSkin())
	ply:SetModel(ent:GetModel())
	ply:SetNWEntity('propme', puppet)
	local hullxy, hullz, hully = puppet:GetPropSize(true)
	print(hullxy, hullz, hully) 
	ply:PlayerSetHull(hully+1, hully+1, hullz, hullz)
end

function ENT:Think()
	local ply = self:GetUser()
	local puppet = self:GetPuppet()
	
	if ply:Alive() then
		local vel=ply:GetVelocity():Length()
		if SERVER then
			puppet:SetPos(ply:GetPos() - Vector(0, 0, IsValid(puppet) and puppet.OBBMins and puppet:OBBMins().z or 0))
		else
			puppet:SetRenderOrigin(ply:GetPos() - Vector(0, 0, IsValid(puppet) and puppet.OBBMins and puppet:OBBMins().z or 0))
		end
		
		if ply:KeyDown(IN_ATTACK2) then
			local angs=ply:EyeAngles()
			angs.p=0
			if SERVER then
				ply.Ang = angs
				puppet:SetAngles(angs)
			else
				puppet:SetRenderAngles(angs)
			end
		end
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:Draw()
end