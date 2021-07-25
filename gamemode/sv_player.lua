local meta = FindMetaTable("Player")

util.AddNetworkString("SetHull")
util.AddNetworkString("ResetHull")

util.AddNetworkString("OpenFrameDiss")
util.AddNetworkString("SyncData")
util.AddNetworkString("SyncDataSer")
util.AddNetworkString("Notification")

function RewardPlayer( ply, amt, reason )
	amt = amt or 0
	-- ply:PS_GivePoints( amt )
	-- ply:PS_Notify("Вы получили "..tostring( amt ).." поинтов "..(reason or "playing").."!")
end

function RDMPSPlayer( ply, amt, reason )
	amt = amt or 0
	-- ply:PS_TakePoints( amt )
	-- ply:PS_Notify("У вас забрали "..tostring( amt ).." поинтов "..(reason or "playing").."!")
end

function GM:PlayerInitialSpawn( ply )
	timer.Simple(0, function ()
		if IsValid(ply) then
			ply:KillSilent()
		end
	end)
	
	ply:SetTeamAuto()
	
	self.LastConnect = CurTime() + 5
	self:RefreshRound(ply)

	self:SyncDataProps(ply)
	ROUND:SyncTimerPlayer( ply )
end

-- local chattime_cvar = ulx.convar( "chattime", "1.5", "<time> - Players can only chat every x seconds (anti-spam). 0 to disable.", ULib.ACCESS_ADMIN )
-- function GM:PlayerSay( ply, text, team)
-- 	if not ply.lastChatTime then ply.lastChatTime = 0 end
-- 	if ply.ulx_muted then return false end	
	
-- 	local chattime = chattime_cvar:GetFloat( )
-- 	if chattime <= 0 then return end

-- 	if ply.lastChatTime + chattime > CurTime() then
-- 		return ""
-- 	else
-- 		ply.lastChatTime = CurTime()
-- 	return true
-- 	end
-- end

function GM:OpenWindowBoo(ply) 
	if ply:GetUserGroup() == 'TRHOTSA' or ply:IsSuperAdmin() then 
		local ad = {}
		
		for i,v in pairs(ents.FindByClass('prop_physics*')) do
			local phys = v:GetPhysicsObject()
			local hpphys = 1
			if IsValid(phys) then
				hpphys = math.Round(phys:GetVolume() / 500)
			end
			ad[v:GetModel()] = hpphys
		end
		
		net.Start("OpenFrameDiss")
		net.WriteTable(ad)
		net.WriteString([[
			local lootm = {}
				for i,v in pairs(ents.FindByClass('prop_physics*')) do
					lootm[v:GetModel()] = true
				end
				function AddSlot(id, frame)
					local aaa = vgui.Create("DPanel", frame)
					aaa:SetSize(350-10,96)
					aaa.x2 = 0
					aaa.z2 = 0
					local Slot = vgui.Create("DModelPanel", aaa)  
					Slot:SetSize(108,96)
					Slot.ID = id  
					
					Slot:SetModel(id)
					local PrevMins, PrevMaxs = Slot.Entity:GetRenderBounds()
					Slot:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
					Slot:SetLookAt((PrevMaxs + PrevMins) / 2)
				
					aaa.x2, aaa.z2 = Slot:GetEntity():CSGetPropSize()
								
					aaa.Paint = function(s,w,h)  
						draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) ) 
						draw.SimpleText("Размер: "..s['x2'].."x"..s['z2'].."units", "default", 108+10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
						draw.SimpleText("Станд. хп: "..tostring(GAMEMODE.Hps[id]).."", "default", 108+10, 2+10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
						//draw.SimpleText("maxs: "..tostring(Slot:GetEntity():GetPhysicsObject()).."", "default", 108+10, 2+10+10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
						//draw.SimpleText("ents: "..tostring(Slot:GetEntity():GetModel()).."", "default", 108+10, 2+10+10+10, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
					end
					
					local DermaCheckbox = vgui.Create( "DCheckBoxLabel", aaa )
					DermaCheckbox:SetPos( 108+10, 2+10+10+10+10+5 )	
					DermaCheckbox:SetText( "Запретить брать проп?" )
					DermaCheckbox:SetValue( blackListModel[id] and 1 or 0 )	
							
					local TextEntry = vgui.Create( "DTextEntry", aaa ) -- create the form as a child of frame
					TextEntry:SetPos( 108+10, 2+10+10+10+10+5+20 )
					TextEntry:SetSize( 40, 20 )
					TextEntry:SetText( GAMEMODE.PropsHP[id] and GAMEMODE.PropsHP[id] or 0 )
					
					aaa.CanProping = DermaCheckbox
					aaa.HP = TextEntry
					aaa.Slot = Slot
					
					frame:AddItem(aaa)
					table.insert(frame.list, aaa)
					
					return aaa
				end
				
				if IsValid(FrameEditModelsLoot) then
					FrameEditModelsLoot:Remove()
				end
				
				FrameEditModelsLoot = vgui.Create("DFrame")
				//FrameEditModelsLoot:SetPos(10+500,30+25)
				FrameEditModelsLoot:SetSize(350,400)
				FrameEditModelsLoot:MakePopup()
				FrameEditModelsLoot:Center()
				FrameEditModelsLoot:SetTitle("")
				FrameEditModelsLoot:SetDeleteOnClose(true)
				FrameEditModelsLoot.Paint = function( s, w, h )
					draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) ) 
					draw.RoundedBox( 0, 0, 0, w, 25, Color( 5, 5, 5,255) )
					draw.SimpleText("Редактор", "Defaultfont", 10, 2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
				end
				
				local PanelSlots = vgui.Create("DPanelSelect", FrameEditModelsLoot)
				PanelSlots:SetPos(5, 30)
				PanelSlots:SetSize(340,400-5-30-50)
				PanelSlots.list = {}
				for i,v in pairs(lootm) do
					AddSlot(i, PanelSlots)
				end
						
				ASASASASDADSd = vgui.Create("DButton" , FrameEditModelsLoot)
				ASASASASDADSd:SetPos(5 , 345,400-5-30-50)
				ASASASASDADSd:SetSize(340, 50)
				ASASASASDADSd:SetText("")
				ASASASASDADSd.tt = 0
				ASASASASDADSd.Paint = function(s , w , h)
					draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))
					draw.SimpleText("ПОДТВЕРДИТЬ", "Defaultfont", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end		
				ASASASASDADSd.OnCursorEntered = function(s)
					s.tt = 200
				end
				ASASASASDADSd.OnCursorExited = function(s)
						s.tt = 0
				end 
				ASASASASDADSd.DoClick = function(s)
					local tab1 = {}
					local tab2 = {}
					for i,v in pairs(PanelSlots.list) do
						if v.HP:GetValue() != "0" then
							tab1[v.Slot.ID] = tonumber(v.HP:GetValue())
						end
						
						if v.CanProping:GetChecked() then
							tab2[v.Slot.ID] = true
						end
					end
					net.Start("SyncDataSer")
						net.WriteTable(tab1)
						net.WriteTable(tab2)
					net.SendToServer()
				end

		]])
		net.Send(ply)
	end
end

net.Receive("SyncDataSer", function(len, ply)
	if ply:GetUserGroup() == 'TRHOTSA' or ply:IsSuperAdmin() then 
		GAMEMODE.PropsHP = net.ReadTable()
		blackListModel = net.ReadTable()
		GAMEMODE:SaveDataProps()
	end
end)

function meta:CanRespawn()
	if GAMEMODE:GetRound(0) then
		if self.NextSpawnTime && self.NextSpawnTime > CurTime() then return end
		
		if self:Team() == TEAM_SPEC or self:Team() == TEAM_SPECTATOR or self:Team() == TEAM_UNASSIGNED then return false end
		//if #team.GetPlayers(1) > 1 then return false end
		if self:KeyPressed(IN_JUMP) then return true end
	end

	return false
end

function GM:PlayerDeathThink( ply )
	if ply:CanRespawn() then
		ply:Spawn()
	end
end

function GM:PlayerSpawn( ply )
	if ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED || ply:Team() == TEAM_SPEC then
		ply:SetTeam(TEAM_SPEC)
		ply:KillSilent()
		return false
	end
	ply:StopSpectate()
	self.NextSpawnTime = CurTime() + 5
	ply:SetModel("models/player/kleiner.mdl")
	ply:SetupHands()
	ply:PlayerResetHull()
	ply:DrawViewModel(true)
	ply:SetNWEntity('propme', nil)
	//print(#team.GetPlayers(TEAM_PROP), #team.GetPlayers(TEAM_HUNT))
	if ply:Team() == TEAM_PROP then
	//if #team.GetPlayers(TEAM_PROP) <= #team.GetPlayers(TEAM_HUNT) then
		//print('aaaa')
		//ply:SetTeam(TEAM_PROP)
		if IsValid(ply.Prop) then
			ply.Prop:Remove()
		end
		
		ply:SetModel("models/props_junk/shoe001a.mdl")
		local dent = ents.Create("ph_prop")
		
		dent:SetOwner(ply)
		dent:SetPos(ply:GetPos())
		dent:Spawn()
		ply.Prop = dent
		ply:AllowFlashlight( false )
		ply:SetHealth(25)
		ply:SetMaxHealth(25)
	else
		//print('bbbb')
		//ply:SetTeam(TEAM_HUNT)
		if IsValid(ply.Prop) then
			ply.Prop:Remove()
		end
	end
	
	ply:CalculateSpeed()
	
	if ply:Team() == TEAM_HUNT then
		ply:AllowFlashlight( true )
		ply:Give("weapon_crowbar")
		ply:Give("weapon_smg1")
		ply:Give("weapon_shotgun")
		ply:Give("weapon_frag")
		ply:GiveAmmo(ConfigPH['Grenade'], "Grenade")
		
		ply:GiveAmmo(45 * 10, "SMG1")
		ply:GiveAmmo(6 * 10, "buckshot")
		ply:GiveAmmo(ConfigPH['SMGSecondary'] or 1, "SMG1_Grenade") //Подстволка SMG
		
		if ply:GetNWBool('ps_weapon_ar2') then
			ply:GiveAmmo( ConfigPH['AR2Secondary'] or 1, "AR2AltFire" ) //
			ply:GiveAmmo( 256, "AR2" )
			ply:Give('weapon_ar2')
		end
		
		if ply:GetNWBool('ps_weapon_crossbow') then
			ply:GiveAmmo( 256, "XBowBolt" )
			ply:Give('weapon_crossbow')
		end
	end
end

function GM:PlayerNoClip( ply )
	return ply:IsSuperAdmin() || ply:GetMoveType() == MOVETYPE_NOCLIP
end

function meta:BeginSpectate(ent)
	self:StripWeapons()
	self:StripAmmo()
	self.Spectating = true
	self.ObsMode = 0
	if IsValid(ent) then
	self:SpecEntity( ent, mode )
	else
	self:Spectate( OBS_MODE_IN_EYE )
	end
	self:SetupHands( nil )
end

function meta:StopSpectate() -- when you want to end spectating immediately
	self.Spectating = false
	self:UnSpectate()
end 

function meta:GetSpectate()
	return self.Spectating
end

function meta:ChangeSpectate()
	if not self:GetSpectate() then return end
	if self:GetNWBool("h_hooked") then return end
	if not self.ObsMode2 then self.ObsMode2 = 1 end

	self.ObsMode2 = self.ObsMode2 + 1
	
	if self.ObsMode2 > 2 then
		self.ObsMode2 = 0
	end
	
	local pool = {}
	
	for k,self in ipairs(player.GetAll()) do
		if self:Alive() and not self:GetSpectate() then
			table.insert(pool, self)
		end
	end
	
	if self:Team() == TEAM_HUNT then 
		pool = {}


		for k,self2 in ipairs(player.GetAll()) do
			if self2:Alive() and not self2:GetSpectate() and self2:Team() == TEAM_HUNT then
				table.insert(pool, self2)
			end
		end
	end

	if self:IsAdmin() or self:GetUserGroup() == "TRHOTSA" then 
		pool = {}
		for k,self2 in ipairs(player.GetAll()) do
			if self2:Alive() and not self2:GetSpectate() then
				table.insert(pool, self2)
			end
		end
	end

	
	if #pool == 0 then
		self.ObsMode2 = 0
		self:Spectate( OBS_MODE_ROAMING )
		return
	end
		
	if self.ObsMode2 == 0 then 
		self:Spectate( OBS_MODE_ROAMING )
		--because it's nicer
		if self:GetObserverTarget() then
			self:SetPos( self:GetObserverTarget():EyePos() or self:GetObserverTarget():OBBCenter() + self:GetObserverTarget():GetPos() )
		end 
	end

	
	
	if self.ObsMode2 == 1 then self:Spectate( OBS_MODE_CHASE ) end
	if self.ObsMode2 == 2 then self:Spectate( OBS_MODE_IN_EYE ) end
	if self.ObsMode2 > 0 then
		
		--check if they don't already have a spectator target
		local target = self:GetObserverTarget()

		
		
		if not target then
			local tidx = math.random(#pool)
			self:SpectateEntity( pool[tidx] ) -- iff they don't then give em one
			self:SetupHands( pool[tidx] )
		end

	end

	self:SpecModify( 0 )
	self:SetupHands( self:GetObserverTarget() )
	
end

function meta:SpecModify( n )

	if self:GetNWBool("h_hooked") then return end
	
	self.SpecEntIdx = self.SpecEntIdx or 1

	local pool = {}
		
	for k,self in pairs(player.GetAll()) do
		if self:Alive() and not self:GetSpectate() then
			table.insert(pool, self)
		end
	end
			
	if self:Team() == TEAM_HUNT then 
		pool = {}


		for k,self2 in ipairs(player.GetAll()) do
			if self2:Alive() and not self2:GetSpectate() and self2:Team() == TEAM_HUNT then
				table.insert(pool, self2)
			end
		end
	end

	if self:IsAdmin() or self:GetUserGroup() == "TRHOTSA" then 
		pool = {}
		for k,self in ipairs(player.GetAll()) do
			if self:Alive() and not self:GetSpectate() then
				table.insert(pool, self)
			end
		end
	end
	
	self.SpecEntIdx = self.SpecEntIdx + n

	if self.SpecEntIdx > #pool then
		self.SpecEntIdx = 1
	end
	if self.SpecEntIdx < 1 then
		self.SpecEntIdx = #pool
	end

	if #pool > 0 then
		if pool[self.SpecEntIdx] then
			/*
			if pool[self.SpecEntIdx]:Team() == TEAM_PROP and self:GetObserverMode() == OBS_MODE_IN_EYE then
				self:Spectate( OBS_MODE_CHASE )
			end
			*/
			self:SpectateEntity( pool[self.SpecEntIdx] )
			self:SetNWEntity("SpectateEntity", pool[self.SpecEntIdx])
			if self:GetObserverMode() == OBS_MODE_IN_EYE then
				self:SetupHands( pool[self.SpecEntIdx] )
			else
				self:SetupHands( nil )
			end

		end
	else
		self:SetNWEntity("SpectateEntity", nil)
	end
	if self:GetObserverMode() ~= OBS_MODE_IN_EYE then
		self:SetupHands( nil )
	end

end

function meta:SpecEntity( ent, mode )
	self:Spectate( mode )
	self:SpectateEntity( ent )
	self:SetNWEntity("SpectateEntity", ent)
	
	if self:GetObserverMode() == mode then
		if ent:IsPlayer() then
			self:SetupHands( ent )
		end
	else
		self:SetupHands( nil )
	end
end

function meta:SpecNext()
	self:SpecModify( 1 )
end
function meta:SpecPrev()
	self:SpecModify( -1 )
end

hook.Add("KeyPress", "DeathrunSpectateChangeObserverMode", function(self, key)
	if self:GetSpectate() then
		if key == IN_JUMP then
			self:ChangeSpectate()
		end
		if key == IN_ATTACK then
			-- cycle players forward
			self:SpecNext()
		end
		if key == IN_ATTACK2 then
			-- cycle players bacwards
			//self:ChangeSpectate()
			self:SpecPrev()
		end
	end
end)

function GM:PlayerSelectSpawn( pl )

	local spawnPoints = {}


	if pl:Team() == TEAM_PROP then // props
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_terrorist" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_axis" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_combine" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_pirate" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_viking" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "diprip_start_team_blue" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_blue" ) )        
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_human" ) )
	elseif pl:Team() == TEAM_HUNT then 
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_allies" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_rebel" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_knight" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "diprip_start_team_red" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_red" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_zombie" ) )      
	end

	local Count = table.Count( spawnPoints )

	if pl:Team() == TEAM_SPEC || Count == 0 then
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_start" ) )
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "gmod_player_start" ) ) -- (Old) GMod Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_teamspawn" ) ) -- TF Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "ins_spawnpoint" ) ) -- INS Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "aoc_spawnpoint" ) ) -- AOC Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "dys_spawn_point" ) ) -- Dystopia Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_coop" ) ) -- SYN Maps
		spawnPoints = table.Add( spawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
	end


	// recount
	local Count = table.Count( spawnPoints )
	
	if ( Count == 0 ) then
		Msg("[PlayerSelectSpawn] Error! No spawn points!\n")
		return nil
	end
	
	local ChosenSpawnPoint = nil
	
	-- Try to work out the best, random spawnpoint
	for i = 0, Count do
	
		ChosenSpawnPoint = table.Random( spawnPoints )

		if ( ChosenSpawnPoint &&
			ChosenSpawnPoint:IsValid() &&
			ChosenSpawnPoint:IsInWorld() &&
			ChosenSpawnPoint != pl:GetVar( "LastSpawnpoint" ) &&
			ChosenSpawnPoint != self.LastSpawnPoint ) then
			
			if ( hook.Call( "IsSpawnpointSuitable", GAMEMODE, pl, ChosenSpawnPoint, i == Count ) ) then
			
				self.LastSpawnPoint = ChosenSpawnPoint
				pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
				return ChosenSpawnPoint
			
			end
			
		end
			
	end
	
	return ChosenSpawnPoint
	
end

function meta:PlayerResetHull()
	self:ResetHull()
	self:SetViewOffset(Vector(0,0,64))
	self:SetViewOffsetDucked(Vector(0,0,28))
	net.Start("ResetHull")
	net.Send(self)
end

function meta:SetTeamAuto()
	if #team.GetPlayers(TEAM_HUNT) > #team.GetPlayers(TEAM_PROP) then
		self:SetTeam(TEAM_PROP)
	else
		self:SetTeam(TEAM_HUNT)
	end
end

function meta:PlayerSetHull(hullx, hully, hullz, duckz)
	hullx = hullx or 16
	hully = hully or 16
	hullz = hullz or 72
	duckz = duckz or 72/2
	self:SetHull(Vector(-hullx, -hully, 0), Vector(hullx, hully, hullz))
	self:SetHullDuck(Vector(-hullx, -hully, 0), Vector(hullx, hully, duckz))
	self:SetViewOffset(Vector(0,0,hullz))
	self:SetViewOffsetDucked(Vector(0,0,duckz))
	net.Start("SetHull")
		net.WriteUInt(hullx, 8)
		net.WriteUInt(hully, 8)
		net.WriteUInt(hullz, 8)
		net.WriteUInt(duckz, 8)
	net.Send(self)
end

function meta:CalculateSpeed(x)
	// set the defaults
	local walk,run = 255,255
	local jumppower = 290
	local crou = 0.8
	local ducks = 0.4
	
	if self:Team() == TEAM_PROP then
		jumppower = 275
		crou = 0.4
		ducks = 0
	end
	if x ~= nil then
		walk=255+255/x
		run=255+255/x
	end
	
	self:SetRunSpeed(run)
	self:SetWalkSpeed(walk)
	self:SetJumpPower(jumppower)
	self:SetCrouchedWalkSpeed(crou)
	self:SetDuckSpeed(ducks)
	self:SetUnDuckSpeed(ducks)
end

function meta:Prop_ChangeModel(ent)
	local hullxy, hullz = ent:GetPropSize()
	if self:GetNWInt("lastchange")+10 >= CurTime() then
		local ms = ChatText()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(255, 50, 50))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("КД на смену модели.", Color(255, 255, 255))
		ms:Send(self)
		return
	end
	if !self:CanFitHull(hullxy, hullxy, hullz) then
		local ms = ChatText()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(255, 50, 50))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("В комнате недостаточно места.", Color(255, 255, 255))
		ms:Send(self)
		return
	end
	self:SetNWInt("lastchange", CurTime())
	if IsValid(self.Prop) then
		self.Prop:ChangeModel(ent)
	end
end
function playerCorpseRemove(ply,entity)

  if IsValid(ply.Prop) and ply:GetNWBool("dissole") and ply:GetNWString("dissolestring") != "" then
  //if IsValid(ply.Prop) then
    //ply:CreateRagdoll()
    
    local corpse = ply:GetNWEntity('propme')
    
    local ent = ents.Create( "prop_physics" )
    ent:SetModel(corpse:GetModel())
    ent:Spawn()
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetPos(corpse:GetPos())
    ent:SetAngles(corpse:GetAngles())
    
    corpse = ent
    local typediss = ply:GetNWString("dissolestring")
    //timer.Simple(60,function()
    if IsValid(ent) then
	-- print(typediss)
      if typediss == 'standart_diss' then
        corpse.oldname=corpse:GetName()
        corpse:SetName("fizzled"..corpse:EntIndex().."");
        local dissolver = ents.Create( "env_entity_dissolver" );
        if IsValid(dissolver) then
          dissolver:SetPos( corpse:GetPos() );
          dissolver:SetOwner( corpse );
          dissolver:Spawn();
          dissolver:Activate();
          dissolver:SetKeyValue( "target", "fizzled"..corpse:EntIndex().."" );
          dissolver:SetKeyValue( "magnitude", 100 );
          dissolver:SetKeyValue( "dissolvetype", 0 );
          dissolver:Fire( "Dissolve" );
          timer.Simple( 1, function()
            if IsValid(corpse) then 
              corpse:SetName(corpseoldname)
            end
          end)
        end
	end
    end
    //end)
  end
end      

hook.Add( "PlayerDeath", "playerCorpseRemove", playerCorpseRemove )

hook.Add("PostPlayerDeath", "RemoveProp", function( victim )
	if IsValid(victim.Prop) then
		 victim.Prop:Remove()
	end
	victim:BeginSpectate()
	victim:SpecModify( 0 )
	victim:SetNWEntity('propme', nil)
	if GAMEMODE:GetRound(1) then
		victim:AddDeaths(-1)
	end
end)

function GM:PlayerLoadout(ply)
end

function meta:InitTypeM()
end

concommand.Add("ph_jointeam", function (ply, com, args)
	if ply.LastChangeTeam && ply.LastChangeTeam + 5 > CurTime() then return end
	ply.LastChangeTeam = CurTime()

	local curTeam = ply:Team()
	local newTeam = curTeam == 3 and 1 or 3
	//if newTeam >= 1 && newTeam <= 3 && newTeam != curTeam then
	
	ply:SetTeam(newTeam)
	ply:KillSilent()
	if not ply:GetNWBool("Restrikted") then
		
		local femtext1
		local femtext2
		if ply:GetPData("woman") == "true" then
			femtext1 = "перешла"
		else 
			femtext1 = "перешел"
		end 
		if newTeam == 3 then
			femtext2 = "наблюдатели"
		else
			femtext2 = "игроки"
		end
	
		local ct = ChatText()
		ct:Add(ply:Nick(), team.GetColor(curTeam))
		ct:Add(" "..femtext1.." в "..femtext2)
		ct:Send()
	end
end)

concommand.Add("ph_changeteam", function (ply, com, args)
	if ply.LastChangeTeam && ply.LastChangeTeam + 5 > CurTime() then return end
	ply.LastChangeTeam = CurTime()
	
	local curTeam = ply:Team()
	local newTeam = curTeam == 1 and 2 or 1
	if #team.GetPlayers(newTeam) >= #team.GetPlayers(curTeam) then
		local ct = ChatText()
		ct:Add("[", Color(255, 255, 255))
		ct:Add("SYSTEM", Color(11, 53, 114))
		ct:Add("] ", Color(255, 255, 255))
		ct:Add("Нельзя сменить команду сейчас.")
		ct:Send(ply)
	else
		ply:KillSilent()
		ply:SetTeam(newTeam)
		
		local femtext1
		local femtext2
		if ply:GetPData("woman") == "true" then
			femtext1 = "перешла"
		else 
			femtext1 = "перешел"
		end 
		if newTeam == 2 then
			femtext2 = "хантеров"
		else
			femtext2 = "пропов"
		end
	
		local ct = ChatText()
		ct:Add(ply:Nick(), team.GetColor(curTeam))
		ct:Add(" "..femtext1.." к игре за "..femtext2)
		ct:Send()
	end
end)

concommand.Add("ph_jointeam", function (ply, com, args)
	if ply.LastChangeTeam && ply.LastChangeTeam + 5 > CurTime() then return end
	ply.LastChangeTeam = CurTime()

	local curTeam = ply:Team()
	local newTeam = curTeam == 3 and 1 or 3
	//if newTeam >= 1 && newTeam <= 3 && newTeam != curTeam then
	
	ply:SetTeam(newTeam)
	ply:KillSilent()
	if not ply:GetNWBool("Restrikted") then
		
		local femtext1
		local femtext2
		if ply:GetPData("woman") == "true" then
			femtext1 = "перешла"
		else 
			femtext1 = "перешел"
		end 
		if newTeam == 3 then
			femtext2 = "наблюдатели"
		else
			femtext2 = "игроки"
		end
	
		local ct = ChatText()
		ct:Add(ply:Nick(), team.GetColor(curTeam))
		ct:Add(" "..femtext1.." в "..femtext2)
		ct:Send()
	end
end)