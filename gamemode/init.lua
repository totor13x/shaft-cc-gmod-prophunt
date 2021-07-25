AddCSLuaFile( "cl_crosshair.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_player.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "sh_entity.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_communicating.lua" )

include( "shared.lua" )

include( "sh_player.lua" )
include( "sh_entity.lua" )
include( "sv_props.lua" )
include( "sv_rounds.lua" )
include( "sv_player.lua" )

include( "sv_communicating.lua" )

AddCSLuaFile( "mv/cl_mv.lua" )
AddCSLuaFile( "mv/sh_mv.lua" )
include( "mv/sv_mv.lua" )

RunConsoleCommand("sv_friction", 10)
RunConsoleCommand("sv_sticktoground", 0)
RunConsoleCommand("sv_airaccelerate", 120)
RunConsoleCommand("sv_gravity", 860)
RunConsoleCommand("mp_show_voice_icons", 0)

function GM:Think()
	self:RoundThink()
end

function GM:Initialize() 
	self.LastDeath = CurTime()
	
	self:LoadDataProps() 
	self:SyncDataProps()
end

hook.Add("AllowPlayerPickup", "fix another button use WOOB", function( ply, ent )
	//print( ply, ent.GetModel and ent:GetModel() or "" )
	if ply:Team() == TEAM_PROP then return false end
end)

hook.Add("KeyPress","KeyFunctions", function(ply, key)
	if ply:Team() == TEAM_PROP and ply:Alive() and key == IN_RELOAD then
		ply:ConCommand("ph_taunt rand")
	end
	if ply:Team() == TEAM_PROP and ply:Alive() and key == IN_USE then
		local tr = ply:GetEyeTrace()
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 150 then
				if ply:CanProp(tr.Entity) then
					print(tr.Entity:GetClass())
					ply:Prop_ChangeModel(tr.Entity)
				end
			end
		end
	end
end)

function GM:EntityTakeDamage( ent, dmginfo )
	
	if self:GetRound( 1 ) then
		local target = ent
			
		local attacker = dmginfo:GetAttacker()
		local inf = dmginfo:GetInflictor()
		// disable all prop damage
		
		if IsValid(dmginfo:GetAttacker()) && (dmginfo:GetAttacker():GetClass() == "env_fire" || dmginfo:GetAttacker():GetClass() == "prop_physics" || dmginfo:GetAttacker():GetClass() == "prop_physics_multiplayer" || dmginfo:GetAttacker():GetClass() == "func_physbox") then
			dmginfo:SetDamage(0)
		end

		if IsValid(dmginfo:GetInflictor()) && (dmginfo:GetAttacker():GetClass() == "env_fire" || dmginfo:GetInflictor():GetClass() == "prop_physics" || dmginfo:GetInflictor():GetClass() == "prop_physics_multiplayer" || dmginfo:GetAttacker():GetClass() == "func_physbox") then
			dmginfo:SetDamage(0)
		end
		if attacker:IsPlayer() and ent:IsPlayer() and attacker:Team() == ent:Team() and attacker ~= ent then
			ent:SetBloodColor(DONT_BLEED)
			dmginfo:SetDamage(0)
		end
		if attacker:IsPlayer() and ent:IsPlayer() and attacker == target then
			if dmginfo:GetDamageBonus() != 999 then
				ent:SetBloodColor(DONT_BLEED)
				dmginfo:SetDamage(0)
				return	
			end
			
			dmginfo:SetDamageBonus( 0 )
		end
		
		if attacker:IsPlayer() and attacker:Team() != TEAM_HUNT and allowClasses[ent:GetClass()] then
			//print(allowClasses[ent:GetClass()])
			attacker:SetBloodColor(DONT_BLEED)
			local Dmg = DamageInfo()
			Dmg:SetAttacker(attacker)
			Dmg:SetInflictor(attacker)
			Dmg:SetDamage(5)
			attacker:TakeDamageInfo( Dmg )
		end
		
		if IsValid(target) && !target:IsPlayer() && attacker && attacker:IsPlayer() && attacker:Team() == TEAM_HUNT && attacker:Alive() then
			
			-- //print(attacker:CanProp(target), 'hhh')
			if allowClasses[ent:GetClass()] and !blackListModel[ent:GetModel()]then
				attacker:SetHealth(attacker:Health() - 5)
			end
			if attacker:Health() <= 0 then
			
				local tt = 'убил себя'
				local ms = NotificationText()
				ms:Add(attacker:Nick(), team.GetColor(attacker:Team()))
				ms:Add(" "..tt, Color(255, 255, 255))
				ms:Send()
				
				attacker:Kill()
				
			end
			
		end
		if attacker:IsPlayer() and target:IsPlayer() and attacker:Team() ~= target:Team() then
			target:SetBloodColor(DONT_BLEED)
			attacker:SetHealth(attacker:Health()+5)
			if attacker:Health() > 100 then
				attacker:SetHealth(100)
			end
			
			local dmg2 = dmginfo:GetDamage()
			dmginfo:SetDamage(0)
			
			target:SetHealth(target:Health()-dmg2)
			if target:Health() <= 0 then
				target:Kill()
				attacker:AddFrags(1)
				if attacker:Team() == TEAM_HUNT then
					local tt = table.Random({
						'обнаружил и уничтожил',
            'стер с лица земли',
            'обезглавил',
            'растер в порошок'
					})
					local ms = NotificationText()
					ms:Add(attacker:Nick(), team.GetColor(attacker:Team()))
					ms:Add(" "..tt.." ", Color(255, 255, 255))
					ms:Add(target:Nick(), team.GetColor(target:Team()))
					ms:Send()
					
					RewardPlayer( attacker, 500, "за убийство пропа" )
				end
			end

		end
	else
		dmginfo:SetDamage(0)
	end
end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
end
