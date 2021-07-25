local meta = FindMetaTable("Player")

surface.CreateFont('TextHead', { font = 'default', size = 18 })

net.Receive("ResetHull", function()
	if IsValid(LocalPlayer()) then
		LocalPlayer():ResetHull()
	end
end)

net.Receive("OpenFrameDiss", function()
	GAMEMODE.Hps = net.ReadTable()
	RunString(net.ReadString())
end)

net.Receive("DataProps", function()
	GM.PropsHP = net.ReadTable()
end)

net.Receive("SetHull", function()
	if IsValid(LocalPlayer()) then
	local hullx = net.ReadUInt(8)
	local hully = net.ReadUInt(8)
	local hullz = net.ReadUInt(8)
	local duckz = net.ReadUInt(8)
	LocalPlayer():SetHull(Vector(-hullx, -hully, 0), Vector(hullx, hully, hullz))
	LocalPlayer():SetHullDuck(Vector(-hullx, -hully, 0), Vector(hullx, hully, duckz))
	//LocalPlayer():SetHull(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
	//LocalPlayer():SetHullDuck(Vector(hull_xy * -1, hull_xy * -1, 0), Vector(hull_xy, hull_xy, hull_z))
	end
end)

function GM:PreDrawHalos()

	local tr = LocalPlayer():GetEyeTrace()
	
	if LocalPlayer():Team() == TEAM_PROP then
		if IsValid(tr.Entity) then
			if tr.HitPos:Distance(tr.StartPos) < 300 then
				if LocalPlayer():CanProp(tr.Entity) then
          local col = Color(220, 50, 50)
          local reason = ''
					local hullxy, hullz = tr.Entity:GetPropSize()
					if LocalPlayer():CanFitHull(hullxy, hullxy, hullz) then
            col = Color(220, 220, 50)
            reason = 'Проп разрешен'
						local a = LocalPlayer():GetNWInt("lastchange")
						local per = CurTime()-a
            
            if per > 10 then
              if tr.HitPos:Distance(tr.StartPos) < 150 then
                reason = 'Ты можешь сменить проп'
                col = Color(50, 220, 50)
              else
                reason = 'Проп находится далеко от тебя'
              end
            else
              reason = 'Кулдаун на замену модели'
            end
          else
            reason = 'Проп заблокирован'
          end
          -- print(reason)
          tr.Entity.TextOver = reason
          tr.Entity.ColorOver = col
					halo.Add({tr.Entity}, col, 2, 2, 2, true, true)
				end
			end
		end
	end

end

ThirdpersonOn = CreateClientConVar("ph_thirdperson_enabled", 0, true, false)

local function DrawLocalPlayerThirdPerson()
	local ply = LocalPlayer()
	if (ThirdpersonOn:GetBool() == true and ply:Alive()) then
		return true
	end
end
hook.Add("ShouldDrawLocalPlayer", "deathrun_thirdperson_script", DrawLocalPlayerThirdPerson)
/*
local msgs = {}

msgs = {
-- //'Чтобы узнать что делает та или иная роль откройте таб -> описание ролей',
-- 'Для перехода в игроки используйте таб -> в игроки',
-- 'Донат доступен по клавише F6',
-- //'Не поверите, но у нас есть сайт. Домен - https://shaft.im/',
}

function AddAnnouncement( ann )
	table.insert( msgs, ann or "Blank Announcement" )
end

local idx = 1

local function DoAnnouncements()

	chat.AddText( Color(233,242,249), "[", AnnouncerColor, AnnouncerName,  Color(233,242,249), "] "..(msgs[idx]))
	idx = idx + 1
	if idx > #msgs then idx = 1 end
end

timer.Create("DeathrunAnnouncementTimer", 120, 0, function()
	DoAnnouncements()
end)
*/

local function CalcViewThirdPerson( ply, pos, ang, fov, nearz, farz )
		-- test for thirdperson scoped weapons
	GAMEMODE.Crosshair3d = false
	if (ThirdpersonOn:GetBool() == true) and LocalPlayer():Alive() then
		local view = {}
		GAMEMODE.Crosshair3d = true
		local newpos = Vector(0,0,0)
		local dist = 100
		local nije = 5
		
		if ply:Team() != TEAM_PROP then
			nije = 20
		end
		
		local vR = 0
		local vF = 0
		local iai = false
		/* First */
		if iai then
			dist = -100
			nije = -9
			vR = 180
			vF = 180
		end
		
		local tr = util.TraceHull({
			start = pos, 
			endpos = pos + ang:Forward()*-dist + Vector(0,0,nije) + ang:Right()+ ang:Up(),
			mins = Vector(-2,-2,-2),
			maxs = Vector(2,2,2),
			filter = player.GetAll(),
			mask = MASK_SOLID_BRUSHONLY
		})

		newpos = tr.HitPos
		view.origin = newpos

		local newang = ang
		newang:RotateAroundAxis( ply:EyeAngles():Right(), vR )
		newang:RotateAroundAxis( ply:EyeAngles():Up(), 0 )
		newang:RotateAroundAxis( ply:EyeAngles():Forward(), vF )

		view.angles = newang
		view.fov = fov

		return view
	end

end
hook.Add("CalcView", "deathrun_thirdperson_script", CalcViewThirdPerson )

//local menuTaunts

///*
local blur = Material( "pp/blurscreen" )

function blur2( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	if IsValid(panel) then
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
	end
end


	if IsValid(menuTaunts) then
		menuTaunts:Remove() 
	end
	
local function createTauntLab(cat)

	if IsValid(menuTaunts.Scroll2) then
		menuTaunts.Scroll2:Remove()
	end
	
	for i,v in pairs(menuTaunts.Gr:GetItems()) do
		v.selected = false
		if v.ID == cat then v.selected = true end
	end
	
	local Scroll2 = vgui.Create( 'DScrollPanel', menuTaunts)
    Scroll2:SetSize( menuTaunts:GetWide()-270-10-5, menuTaunts:GetTall()-10)
    Scroll2:SetPos( 5+5+270, 5 )
	Scroll2.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(35, 35, 35,150))
	end
	Scroll2.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	
	Scroll2.VBar.btnUp.Paint = function( s, w, h ) end
	Scroll2.VBar.btnDown.Paint = function( s, w, h ) end
	Scroll2.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end
	
	local Grid2 = vgui.Create( 'DGrid', Scroll2 )
	Grid2:SetPos( 0, 0 )
	Grid2:SetCols( 1 )
	Grid2:SetColWide( Scroll2:GetWide() )
	Grid2:SetRowHeight( 45 )
	Grid2.Paint = function( s, w, h )
	end
	Scroll2:AddItem(Grid2)
	
	local ty = {}
	if cat == "all" then
		ty = {}
			
		for i,v in pairs( Taunts ) do
			for i2,v2 in pairs( v ) do
        for i3,v3 in pairs( v2 ) do
				  table.insert(ty, v3)
        end
      end
    end
  else
    local tyy = Taunts[cat] and Taunts[cat] or {} 
    ty = {}
    
    for i,v in pairs( tyy ) do
      for i,v2 in pairs( v ) do
        table.insert(ty, v2)
      end
    end
	end
	
	for i,v in pairs( ty ) do
		local model = vgui.Create('DButton', Grid2)
		model:SetSize(Scroll2:GetWide(), 40)
		model:SetText("")
		model.data = v
		model.ID = i
		model.LerpedColor = Vector(0,0,0)
		model.LerpedColorA = 0
		//model.LerpedColorA = 100
		model.s = false
		model.Paint = function(s2,w,h)			
			local col = Color(35, 35, 35,0)
			local text = v.name

			local bulbul = LocalPlayer():GetNWInt("LastTaunt")
			local id = LocalPlayer():GetNWString("LastWav")
			
			if s2.s then
				col.a = 50
			end
			
			-- if TauntPaths[wav] then
			-- //local max = SoundDuration(wav)
				local max = v.length or 1
				
				local per = CurTime()-bulbul
        if per <= max then 
          s2.LerpedColor = Vector(100/255,100/255,253/255) 
          s2.LerpedColorA = 255
        end
				if s2.data.id == id then
				-- //if per <= max then
					
					if per > max then
						per = max 
						s2.LerpedColor = LerpVector(FrameTime()*7, s2.LerpedColor, Vector(0,0,0) )
						s2.LerpedColorA = Lerp(FrameTime()*9, s2.LerpedColorA, 0 )
					end
					
					local a = s2.LerpedColor:ToColor()
					a.a = s2.LerpedColorA
					draw.RoundedBox( 0, 0+((w/2)-((w/(max*2))*per)), 0, (w/(max))*per, 50, a )
				end
			-- end
			
			draw.RoundedBox(0, 0, 0, w, h, col)
			
			draw.SimpleText(text, 'TextHead', w/2, (h/2)-6, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText((v.length or 1) .." сек.", 'default', w/2, (h/2)+8, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			-- //draw.SimpleText(math.Round(SoundDuration(s2.data.Wav),2).." сек.", 'default', w/2, (h/2)+8, math.Round(SoundDuration(s2.data.Wav),2) == TauntPaths[s2.data.Wav].Duration and Color(50,210,50) or Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		model.OnCursorEntered = function(s) s.s = true end
		model.OnCursorExited = function(s) s.s = false end
		model.DoClick = function(s2)
			RunConsoleCommand('ph_taunt', v.id)
		end
		Grid2:AddItem(model)
	end
	menuTaunts.Scroll2 = Scroll2
end
local function openTauntMenu()
	if IsValid(menuTaunts) then
		//fillCats(menu.CatList, menu.TauntList)
		//fillList(menu.TauntList, menu.CurrentTaunts, menu.CurrentTauntCat)
		//menu:SetVisible(!menu:IsVisible())
		menuTaunts:Remove()
		return
	end
	menuTaunts = vgui.Create("DFrame")
	menuTaunts:SetSize( math.Clamp( 600, 0, ScrW() ), math.Clamp( 400, 0, ScrH() )) 
	menuTaunts:SetPos((ScrW() / 2) - (menuTaunts:GetWide() / 2), (ScrH() / 2) - (menuTaunts:GetTall() / 2))
	menuTaunts:SetTitle( "" )
	menuTaunts:SetVisible( true )
	menuTaunts:ShowCloseButton( false )
	menuTaunts:SetDraggable( false )
	menuTaunts.Paint = function( s, w, h )
		blur2( menuTaunts, 10, 20, 255 )
		draw.RoundedBox( 0, 0, 0, menuTaunts:GetWide(), menuTaunts:GetTall(), Color( 35, 35, 35,200) )		
		
		//draw.SimpleText("Таунты", "Defaultfont", 10, 5, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)		

	end	
/*
	menuTaunts.OnRemove = function()
		gui.EnableScreenClicker( false )
	end
	menuTaunts.Think = function()
		if IsValid(menuTaunts) then
			gui.EnableScreenClicker( true )
		end
	end
	*/

	local Scroll = vgui.Create( 'DScrollPanel', menuTaunts)
    Scroll:SetSize( 270, menuTaunts:GetTall()-10)
    Scroll:SetPos( 5, 5 )
	Scroll.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(35, 35, 35,150))
	end
	Scroll.VBar.Paint = function( s, w, h )
		draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
	end
	
	Scroll.VBar.btnUp.Paint = function( s, w, h ) end
	Scroll.VBar.btnDown.Paint = function( s, w, h ) end
	Scroll.VBar.btnGrip.Paint = function( s, w, h )
		draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
	end
	
	local Grid = vgui.Create( 'DGrid', Scroll )
	Grid:SetPos( 0, 0 )
	Grid:SetCols( 1 )
	Grid:SetColWide( 270 )
	Grid:SetRowHeight( 45 )
	Grid.Paint = function( s, w, h )
	end
	Scroll:AddItem(Grid)
	
	local model = vgui.Create('DButton', Grid)
	model:SetSize(270, 40)
	model:SetText("")
	model.ID = 'all'
	model.s = false
	model.selected = false
	model.Paint = function(s2,w,h)			
		local col = Color(35, 35, 35,0)
		if s2.s then
			col = Color(100,100,253, 150)
		end
		if s2.selected then
			col = Color(100,100,253,255)
		end
		
		draw.RoundedBox(0, 0, 0, w, h, col)
		draw.SimpleText('Все таунты', 'TextHead', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	model.OnCursorEntered = function(s) s.s = true end
	model.OnCursorExited = function(s) s.s = false end
	model.DoClick = function(s2)
		createTauntLab('all')
	end
	Grid:AddItem(model)
	 
	for i,v in pairs( Taunts ) do
		local model = vgui.Create('DButton', Grid)
		model:SetSize(270, 40)
		model:SetText("")
		model.ID = i
		model.s = false
		model.selected = false
		model.Paint = function(s2,w,h)			
			local col = Color(35, 35, 35,0)
			local text = i
			if s2.s then
				col = Color(100,100,253, 150)
			end
			if s2.selected then
				col = Color(100,100,253,255)
			end
			draw.RoundedBox(0, 0, 0, w, h, col)
			draw.SimpleText(text, 'TextHead', w/2, h/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		model.OnCursorEntered = function(s) s.s = true end
		model.OnCursorExited = function(s) s.s = false end
		model.DoClick = function(s2)
			createTauntLab(i)
		end
		Grid:AddItem(model)
	end
	menuTaunts.Gr = Grid
	createTauntLab('all')
end  

hook.Add("Think", "OpenQMenu", function()
	
		if !IsValid(menuTaunts) then
			openTauntMenu()
		else
			
			if input.IsKeyDown(KEY_Q) and IsValid(LocalPlayer()) and LocalPlayer():Team() == TEAM_PROP then
				gui.EnableScreenClicker( true )
				menuTaunts:SetVisible(true)
			else
				if menuTaunts:IsVisible() then
					gui.EnableScreenClicker( false )
					menuTaunts:SetVisible(false)
				end
			end
	end
end)