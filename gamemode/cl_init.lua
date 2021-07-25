include( "cl_crosshair.lua" )
include( "cl_communicating.lua" )
include( "cl_hud.lua" )
include( "shared.lua" )
include( "cl_player.lua" )
include( "sh_player.lua" )
include( "sh_entity.lua" )

include( "mv/cl_mv.lua" )

function GM:Initialize()
	self.ForceIvent = false
end

function GM:PostDrawTranslucentRenderables()
end

function GM:PreDrawViewModel( vm, ply, wep )
	local ply = LocalPlayer()
	if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then
		return true
	end
	if ( !IsValid( wep ) ) then return false end



	player_manager.RunClass( ply, "PreDrawViewModel", vm, wep )



	if ( wep.PreDrawViewModel == nil ) then return false end

	return wep:PreDrawViewModel( vm, wep, ply )
end

function GM:PreDrawPlayerHands( hands, vm, ply, wep )
	if ply:GetObserverMode() == OBS_MODE_CHASE or ply:GetObserverMode() == OBS_MODE_ROAMING then
		return true
	end
end

timer.Simple(1, function() hook.Remove("PostDrawViewModel", "Set player hand skin") end)

function GM:GetRound(id)
	if id ~= nil then
		return self.RoundStage == id
	end
	return self.RoundStage or 0
end

net.Receive("SetRound", function (len)
	GAMEMODE.RoundStage = net.ReadUInt(32)
	//GAMEMODE.FogEmitters = {}
	//print(GAMEMODE:GetRound())
	//print(GAMEMODE.LastThirdPers)
	if GAMEMODE:GetRound(1) then
		RunConsoleCommand("ph_thirdperson_enabled", GAMEMODE.LastThirdPers == true and 1 or 0)
		GAMEMODE.ScreenDark = CurTime()+WHENCOMBINESGOING			
	end
		//if IsValid(LocalPlayer()) and LocalPlayer():Alive() then
		//	mute_state = MUTE_NONE			
		//end
		//GAMEMODE.IsCamNabled = false
		//GAMEMODE.focus_stick = 0
		//GAMEMODE:ClearFootsteps()
end)


net.Receive("MovedAFKPlayer", function (len)
	if IsValid(FrameAFK3) then
		FrameAFK3:Remove()
	end

	FrameAFK3 = vgui.Create( "DFrame" )
	FrameAFK3:SetSize( 350, 130 )
	FrameAFK3:SetPos((ScrW() / 2) - (FrameAFK3:GetWide() / 2), (ScrH() / 2) - (FrameAFK3:GetTall() / 2))
	FrameAFK3:SetTitle( "" )
	FrameAFK3:SetVisible( true ) 
	FrameAFK3:SetDraggable( false )
	FrameAFK3:SetDeleteOnClose(true)
	FrameAFK3:MakePopup()
	FrameAFK3.Paint = function( s, w, h )
		scoreboard.blur( FrameAFK3, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
		
		draw.SimpleText("Вы были переведены в наблюдатели.", "SpinButton4", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	end	
	 
	FrameAFK3.OnClose = function(self) end

	local AcceptTrade = vgui.Create("DButton" , FrameAFK3)
	AcceptTrade:SetPos(0 , 100-20)
	AcceptTrade:SetSize(350, 50)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))

		draw.SimpleText("НАЖМИТЕ НА МЕНЯ", "SpinButton4def", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 230
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("mu_jointeam", 2)
		FrameAFK3:Remove()
	end 
end)

net.Receive("SpawnHasPlayer", function (len)
	if IsValid(FrameAFK) then
		FrameAFK:Remove()
	end

	FrameAFK = vgui.Create( "DFrame" )
	FrameAFK:SetSize( 350, 180 )
	FrameAFK:SetPos((ScrW() / 2) - (FrameAFK:GetWide() / 2), (ScrH() / 2) - (FrameAFK:GetTall() / 2))
	FrameAFK:SetTitle( "" )
	FrameAFK:SetVisible( true ) 
	FrameAFK:SetDraggable( false )
	FrameAFK:SetDeleteOnClose(true)
	FrameAFK:MakePopup()
	FrameAFK.Paint = function( s, w, h )
		scoreboard.blur( FrameAFK, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
		
		draw.SimpleText("Добро пожаловать на shaft.im!", "SpinButton4", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Сейчас вы находитесь в наблюдателях.", "SpinButton4", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4", (w)/2, 35+20+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	end	
	 
	FrameAFK.OnClose = function(self)
		local FrameAFK2 = vgui.Create( "DFrame" )
		FrameAFK2:SetSize( 350, 150 )
		FrameAFK2:SetPos((ScrW() / 2) - (FrameAFK2:GetWide() / 2), (ScrH() / 2) - (FrameAFK2:GetTall() / 2))
		FrameAFK2:SetTitle( "" )
		FrameAFK2:SetVisible( true ) 
		FrameAFK2:SetDraggable( false )
		FrameAFK2:SetDeleteOnClose(true)
		FrameAFK2:MakePopup()
		FrameAFK2.Paint = function( s, w, h )
			scoreboard.blur( FrameAFK2, 10, 20, 255 )
			draw.RoundedBox( 0, 0, 0, w, h,Color( 35, 35, 35,200) )
			
			draw.SimpleText("Вы уверены, что хотите выйти?", "SpinButton4", (w)/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			draw.SimpleText("После того как вы закроете это окно", "SpinButton4", (w)/2, 35+20+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			draw.SimpleText("Вы покинете сервер!", "SpinButton4", (w)/2, 35+20+20+5, Color(255,150,150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
			//draw.SimpleText("Для того чтобы зайти в игру", "SpinButton4def2", (w)/2, 35+20, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
		end	
		 
		FrameAFK2.OnClose = function(self)
			RunConsoleCommand("disconnect")
		end
		AcceptTrade = vgui.Create("DButton" , FrameAFK2)
		AcceptTrade:SetPos(0 , 100)
		AcceptTrade:SetSize(350, 50)
		AcceptTrade:SetText("")
		AcceptTrade.tt = 0
		AcceptTrade.Paint = function(s , w , h)

			draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))
			local col = Color( 85 , 255 , 37, 255)
			if s.tt == 255 then
				col = Color(255,255,255)
			end
			
			draw.SimpleText("ПРИСОЕДИНИТЕ МЕНЯ К ИГРЕ!", "SpinButton4def", (w)/2, (h-4)/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end		
		AcceptTrade.OnCursorEntered = function(s)
				s.tt = 255
		end
		AcceptTrade.OnCursorExited = function(s)
				s.tt = 0
		end 
		AcceptTrade.DoClick = function(s)
			RunConsoleCommand("mu_jointeam", 2)
			FrameAFK2:Remove()
		end 
	end
	local AcceptTrade = vgui.Create("DButton" , FrameAFK)
	AcceptTrade:SetPos(0 , 100)
	AcceptTrade:SetSize(350, 50)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 85 , 125 , 37, s.tt))

		draw.SimpleText("НАЖМИТЕ НА МЕНЯ", "SpinButton4def", (w)/2, (h-4)/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 230
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("mu_jointeam", 2)
		FrameAFK:Remove()
	end 
	
	local AcceptTrade = vgui.Create("DButton" , FrameAFK)
	AcceptTrade:SetPos(0 , 150)
	AcceptTrade:SetSize(350, 30)
	AcceptTrade:SetText("")
	AcceptTrade.tt = 0
	AcceptTrade.Paint = function(s , w , h)

		draw.RoundedBox(0,0,0,w,h,Color( 50 , 50 , 185, s.tt))

		local col = Color( 150, 150, 255, 255)
		if s.tt == 255 then
			col = Color(255,255,255)
		end
		
		draw.SimpleText("Крайне рекомендуем ознакомиться с правилами сервера.", "default", (w)/2, ((h-4)/2)-6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Это можно сделать, написав в чат !motd или нажав на меня.", "default", (w)/2, ((h)/2)+6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end		
	AcceptTrade.OnCursorEntered = function(s)
			s.tt = 255
	end
	AcceptTrade.OnCursorExited = function(s)
			s.tt = 0
	end 
	AcceptTrade.DoClick = function(s)
		RunConsoleCommand("say", "!motd")
	end 
end)

hook.Add("PlayerBindPress",'BindsPyLeft', function(ply, bind, pressed)
	if !IsValid(ply) then return end
	if LocalPlayer():Alive() && LocalPlayer():Team() == TEAM_HUNT and CurTime() <= (GAMEMODE.ScreenDark or 0) then
		if string.find(bind, "+attack") then
			return true
		end
		if string.find(bind, "+attack2") then
			return true
		end
		if string.find(bind, "+moveright") then
			return true
		end
		if string.find(bind, "+forward") then
			return true
		end
		if string.find(bind, "+back") then
			return true
		end
		if string.find(bind, "+moveleft") then
			return true
		end
	end
end)

concommand.Add("ph_toggle_thirdperson", function(ply)
	if GetConVarNumber("ph_thirdperson_enabled") == 0 then
		ply:ConCommand("ph_thirdperson_enabled 1")
	else
		ply:ConCommand("ph_thirdperson_enabled 0")
	end
	GAMEMODE.LastThirdPers = GetConVarNumber("ph_thirdperson_enabled") == 0
end)

hook.Add("CreateMove",'ByCheckClientsideKeyBinds', function(cmd)

	local ply = LocalPlayer()
	
	if input.WasKeyPressed(KEY_F4) then
		ply:ConCommand("unbox")
	end
	if input.WasKeyPressed(KEY_F1) then
		ply:ConCommand("ph_toggle_thirdperson")
	end	
	/*
	if input.WasKeyPressed(KEY_F1) and cmd:KeyDown( IN_SPEED ) and not ply.Opened then
		ply.Opened = true
		return
	end
	if input.WasKeyReleased(KEY_F1) and ply.Opened then
		ply.Opened = false
		return
	end
	*/
	/*
	if input.WasKeyReleased(KEY_F1) and !ply:Alive() and !ply.Opened and lastTimeF1+0.5 < CurTime() then
		local m = CycleMute()
		lastTimeF1 = CurTime()
		RunConsoleCommand("MuteWhenIDead", m)
	end
	*/

end)

hook.Add('AddTabsScoreboard', 'panelAdd', function(panel)	
	self = panel
local buttonchange = vgui.Create( "DButton", self.DermaPanelTextSidebar)
			buttonchange:SetPos( 0, self.DermaPanelTextSidebar:GetTall()-40-40 )
			buttonchange:SetSize(self.DermaPanelTextSidebar:GetWide(),38 + 2)
			buttonchange:SetText("")
			buttonchange.selected = false
			
			buttonchange.DoClick = function(s2)
				LocalPlayer():ConCommand("ph_changeteam")
			end
			
 
			buttonchange.Paint = function( s2, w, h )
				draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd or Color(0,0,0) )
				draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 or Color(0,0,0) )
				draw.SimpleText(s2.trert, "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

			end

			buttonchange.OnCursorEntered = function(s2) s2.s = true end
			buttonchange.OnCursorExited = function(s2) s2.s = false end
			buttonchange.Think = function(s2)
				if LocalPlayer():Team() == 1 then
					s2.trert = "К хантерам"
				else
					s2.trert = "К пропам"
				end
			if s2.s then
				s2.asd = Color(0,0,0,150)
				s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
			else
				s2.asd = Color(0,0,0,0)
				s2.asd2 = Color(0,0,0,0)
			end
			end
			
local buttonchange = vgui.Create( "DButton", self.DermaPanelTextSidebar)
			buttonchange:SetPos( 0, self.DermaPanelTextSidebar:GetTall()-40 )
			buttonchange:SetSize(self.DermaPanelTextSidebar:GetWide(),38 + 2)
			buttonchange:SetText("")
			buttonchange.selected = false
			
			buttonchange.DoClick = function(s2)
				LocalPlayer():ConCommand("ph_jointeam")
			end
			
 
			buttonchange.Paint = function( s2, w, h )
				draw.RoundedBox( 0, 0, 0, w-5, h-1, s2.asd or Color(0,0,0) )
				draw.RoundedBox( 0, w-5, 0, 5, h-1, s2.asd2 or Color(0,0,0) )
				draw.SimpleText(s2.trert, "Defaultfont", 20, h/2, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)	

			end

			buttonchange.OnCursorEntered = function(s2) s2.s = true end
			buttonchange.OnCursorExited = function(s2) s2.s = false end
			buttonchange.Think = function(s2)
				if LocalPlayer():Team() != 3 then
					s2.trert = "В наблюдатели"
				else
					s2.trert = "В игроки"
				end
			if s2.s then
				s2.asd = Color(0,0,0,150)
				s2.asd2 = Color(colorLocalPlayer.r,colorLocalPlayer.g,colorLocalPlayer.b,150)
			else
				s2.asd = Color(0,0,0,0)
				s2.asd2 = Color(0,0,0,0)
			end
			end
end)


hook.Add("AddInfoScoreboard", "LoadInfo", function(self)
	self:AddUser('string',TEAM_PROP)
	for _, ply in pairs(team.GetPlayers(TEAM_PROP))do
		if !ply:Alive() then continue end
		self:AddUser('ply',ply)
	end
	self:AddUser('string',TEAM_HUNT)
	for _, ply in pairs(team.GetPlayers(TEAM_HUNT))do
		if !ply:Alive() then continue end
		self:AddUser('ply',ply)
	end
	self:AddUser('string',TEAM_SPEC)
	for _, ply in pairs(player.GetAll())do
		if ply:Alive() then continue end
		self:AddUser('ply',ply)
	end
end)

local stat = {}

netstream.Hook('PH::SyncTaunts', function(taunts)
  -- PrintTable(taunts)
  -- TauntCategories = cats
  -- TauntPaths = paths
  Taunts = taunts
  TauntsID = {}

  for nameTaunt, catTaunt in pairs(taunts) do
    -- print(catTaunt)
    for _, taunts in pairs(catTaunt) do
      for _, taunt in pairs(taunts) do
        -- PrintTable(taunt)
        TauntsID[taunt.id] = taunt
      end
    end
  end
  
  if IsValid(menuTaunts) then
		menuTaunts:Remove() 
	end
end)

  -- netstream.Heavy(ply, 'PH::SyncTaunts', TauntCategories, TauntPaths)
net.Receive("TheInternetTaunt", function()
	local ply = net.ReadEntity()
  local str = net.ReadString()
	if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
    sound.PlayURL ( str, "3d", function( station, id, err )
      -- print(id, err)
			if ( IsValid( station ) ) then
				print(str)
				if IsValid(stat[ply]) then
					stat[ply]:Pause()
				end
				station:SetPos( ply:GetPos() )
				station:Set3DFadeDistance( 750, 2000 )
				station:Play()
				stat[ply] = station
			end
		end )
	end
end)


hook.Add("Think", "InternetThink", function()
	for ply,station in pairs(stat) do
		if IsValid(ply) and IsValid(station) then
		  

		  local eyepos = ply:EyePos()
		  local EyePosLocal = LocalPlayer() == ply and eyepos or LocalPlayer():EyePos()
		  local pos = station:GetPos()
		  local in3D = LocalPlayer() == ply and ply:ShouldDrawLocalPlayer() or true
			-- print(in3D, 'in3D')
			if in3D then
				-- print(!station:Get3DEnabled())
				if !station:Get3DEnabled() then
					station:Set3DEnabled( true )
				end
				if EyePosLocal:DistToSqr( eyepos ) < 100 then
					station:Set3DEnabled( false )
				end
			else
				if station:Get3DEnabled() then
					station:Set3DEnabled( false )  
				end
			end

		  
			station:SetPos(eyepos)
			-- print(EyePosLocal:DistToSqr( eyepos ) > 2000*2000)
			if EyePosLocal:DistToSqr( eyepos ) > 2000*2000 then
				if station:GetVolume() ~= 0 then
					station:SetVolume(0)
				end
			else
				if station:GetVolume() ~= 1 then
					station:SetVolume(1)
				end
			end
				
		else
				stat[ply] = nil
				station:Pause()
		end
	end
end)