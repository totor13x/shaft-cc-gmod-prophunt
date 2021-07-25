
surface.CreateFont( "MersHead1" , {
	font = "Default",
	size = 70,
	weight = 500,
	antialias = true,
	italic = false
})
surface.CreateFont( "MersHead2" , {
	font = "Default",
	size = 25,
	weight = 500,
	antialias = true,
	italic = false
})

surface.CreateFont("lidi_hud_Large", {
	font = "Default",
	size = 48,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_38", {
	font = "Default",
	size = 38,
	antialias = true,
	weight = 800
})

surface.CreateFont( "LiDiRadialSmall" , {
	font = "Default",
	size = math.ceil(ScrW() / 60),
	weight = 100,
	antialias = true,
	italic = false
})

surface.CreateFont("lidi_hud_Medium", {
	font = "Default",
	size = 20,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_Small", {
	font = "Default",
	size = 14,
	antialias = true,
	weight = 800
})

surface.CreateFont("deathrun_hud_Medium", {
	font = "Default",
	size = 20,
	antialias = true,
	weight = 800
})

surface.CreateFont("deathrun_hud_Small", {
	font = "Default",
	size = 14,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_Medium_clock", {
	font = "Default",
	size = 20,
	antialias = true,
	weight = 800
})

surface.CreateFont("lidi_hud_Small_clock", {
	font = "Default",
	size = 13,
	antialias = true,
})

surface.CreateFont("lidi_hud_Small_clock_2", {
	font = "Default",
	size = 11,
	antialias = true,
})

surface.CreateFont('Defaultfont', { font = 'Default', size = 18, weight = 500 })

local function createRoboto(s)
	surface.CreateFont( "RobotoHUD-" .. s , {
		font = "Default",
		size = math.Round(ScrW() / 1000 * s),
		weight = 700,
		antialias = true,
		italic = false
	})
	surface.CreateFont( "RobotoHUD-L" .. s , {
		font = "Default",
		size = math.Round(ScrW() / 1000 * s),
		weight = 500,
		antialias = true,
		italic = false
	})
end

function draw.ShadowText(n, f, x, y, c, px, py, shadowColor)
	draw.SimpleText(n, f, x + 1, y + 1, shadowColor or color_black, px, py)
	draw.SimpleText(n, f, x, y, c, px, py)
end

for i = 5, 50, 5 do
	createRoboto(i)
end
createRoboto(8)

function normalize_time(typein)
	if typein == 1 then
		return tostring(os.date("%d.%m.%Y",os.time()))
	end
	if typein == 2 then
		return tostring(os.date("%H:%M",os.time()))
	end
end 

local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudDeathNotice = true,
	CHudSecondaryAmmo = true,
	CHudZoom = true,
	CHudCrosshair = true,
}

hook.Add("HUDShouldDraw", "disable.huds", function( name )
	if ( hide[ name ] ) then return false end
end )

if IsValid(frameBlack) then
	frameBlack:Remove()
end

function GM:HUDPaint()

	local ply = LocalPlayer()
	if !ply:Alive() and IsValid(ply:GetNWEntity("SpectateEntity")) and ply:GetNWEntity("SpectateEntity"):IsPlayer() then ply = ply:GetNWEntity("SpectateEntity") end
	if LocalPlayer():Alive() && LocalPlayer():Team() == TEAM_HUNT and CurTime() <= (self.ScreenDark or 0) then
		if !IsValid(frameBlack) then
			frameBlack = vgui.Create("DFrame")
			frameBlack:SetPos(0,0)
			frameBlack:SetTitle("")
			frameBlack.a = 255
			frameBlack:ShowCloseButton(false)
			frameBlack:SetSize(ScrW(), ScrH())
			frameBlack.Paint = function(s, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35,s.a))
				
				draw.DrawText( math.Round((self.ScreenDark or 0)-CurTime(),0), "MersHead1", ScrW() / 2, ScrH() / 2 - 170 , Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.DrawText( "Пропы прячутся", "MersHead2", ScrW() / 2, ScrH() / 2 - 70, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			
			frameBlack.Think = function(s)
				if gui.IsGameUIVisible() then
					frameBlack.a = 255
				else
					frameBlack.a = 0
				end
			end
			
		end
		return
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 35, 35, 35,255))
	end

	if IsValid(frameBlack) then
		frameBlack:Remove()
	end

	local dy = ScrH() - 90
	local tcol = Color(150,20,20)
	
	surface.SetDrawColor( Color(255,255,255,150) )
	surface.DrawRect( ScrW()/2-35, 50-13.4, 70, 25 )
	draw.SimpleText(string.ToMinutesSeconds( math.Clamp( ROUND:GetTimer() , 0, 99999 ) ),"lidi_hud_Medium",ScrW()/2,48,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	
	surface.SetDrawColor( tcol )
	
	surface.DrawRect( ScrW()/2-35, 75-13.4, 70, 30 )
	draw.SimpleText(normalize_time(2),"lidi_hud_Medium_clock",ScrW()/2,69.5,Color(255,255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(normalize_time(1),"lidi_hud_Small_clock",ScrW()/2,83,Color(255,255,255,255),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	surface.SetDrawColor( Color(255,255,255,150) )
	
	
	surface.SetDrawColor( Color(255,255,255,150) )
	surface.DrawRect( 50, dy, 200, 16 )
	draw.SimpleText( ply:Nick(), "Default", 50+4,  dy + 16/2, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	//draw.SimpleText(LocalPlayer():Health(), "default", (ScrW())/2, 35+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	//draw.SimpleText(ROUND:GetTimer(), "default", (ScrW())/2, 45+5, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	
	local curhp = math.Clamp( ply:Health(), 0, 100 )
	//math.Remap( 0.5, 0, 1, 0, 255 ) 
	if ply:Team() == TEAM_PROP then
		curhp = math.Remap( ply:Health(), 0, ply:GetMaxHealth(), 0, 100 )
	end
	local curhpout = ply:Health()
	dy = dy+16
	
	surface.SetDrawColor( Color(255,255,255,150) )
	surface.DrawRect( 50, dy, 200, 50 )
	surface.SetDrawColor( tcol )
	surface.DrawRect( 50+(100-curhp), dy, curhp*2, 50 )
	
	
	if curhpout < 1 then
		draw.SimpleText( "0", "lidi_hud_Large", 150, dy+23,  tcol , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	elseif curhpout > 300 then
		draw.SimpleText( 'OVER300~', "lidi_hud_38", 150, dy+23,  Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	else
		draw.SimpleTextOutlined( curhpout, "lidi_hud_Large", 150, dy+23,  Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
	end
	
	local dx = ScrW()-50-200
	if ply:Team() == TEAM_PROP then
		local a = ply:GetNWInt("lastchange")
		
		local per = CurTime()-a
		
		if per > 10 then
			per = 10
		end
		per = math.Round(per,0)
	surface.SetDrawColor( Color(255,255,255,150) )
	surface.DrawRect( dx, dy-16, 200, 16 )
	draw.SimpleText( "Кулдаун на смену модели", "Default", dx+4,  dy-16 + 16/2, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetDrawColor( Color(255,255,255,150) )
		surface.DrawRect( dx, dy, 200, 50 )
		surface.SetDrawColor( tcol )
		surface.DrawRect( dx+(100-per*10), dy, per*10*2, 50 )
		draw.SimpleTextOutlined( per, "lidi_hud_Large", dx+100, dy+23,  Color(255,255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
		
		
		local speed = 0
			if UTILTIMER >= ROUND_TIMER then
			stra = string.Explode( ".", ply:GetNWInt("CooldownAutoTaunt")+TIMERAUTOTAUNT-CurTime() )
			str = stra[1]
			
		surface.SetDrawColor( Color(255,255,255,150) )
		
		surface.DrawRect( ScrW()/2-30, dy+20, 60, 27 )	
		str = math.Clamp(tonumber(str), 0, 30)
		draw.SimpleText(str,"lidi_hud_Medium_clock",ScrW()/2,dy+20+12-3,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("автотаунт","lidi_hud_Small_clock_2",ScrW()/2,dy+20+12+7,tcol,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
		surface.SetDrawColor(255,255,255,150)
		surface.DrawRect( ScrW()/2-30, dy+20+27, 60, 2 )

		
		
		
			local bulbul = ply:GetNWInt("LastTaunt")
			local wav = ply:GetNWString("LastWav")
			

			if TauntsID[wav] then
				local max = TauntsID[wav].length or 1
				
				local per = CurTime()-bulbul
				-- /*
				-- if per <= max then s2.LerpedColor = Vector(100/255,100/255,253/255) s2.LerpedColorA = 255 end
				-- if s2.data.Wav == wav then
				-- //if per <= max then
					
				-- 	if per > max then
				-- 		per = max 
				-- 		s2.LerpedColor = LerpVector(FrameTime()*7, s2.LerpedColor, Vector(0,0,0) )
				-- 		s2.LerpedColorA = Lerp(FrameTime()*9, s2.LerpedColorA, 0 )
				-- 	end
					
				-- 	local a = s2.LerpedColor:ToColor()
				-- 	a.a = s2.LerpedColorA
				-- 	draw.RoundedBox( 0, 0+((w/2)-((w/(max*2))*per)), 0, (w/(max))*per, 50, a )
				-- end
				-- */
		
		
			
			  if per > max then per = max end
			  local charge = per
			  charge = math.Remap( charge, 0, max, 0, 60/100*2 ) 
			  surface.SetDrawColor(tcol)
			
  			surface.DrawRect( ScrW()/2-30, dy+20+27, math.Round(100*charge/4), 2 )
			  surface.DrawRect( ScrW()/2+(30-math.Round(100*charge/4)), dy+20+27, math.Round(100*charge/4), 2 )
			end
		end
	elseif ply:Team() == TEAM_HUNT then
		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) then
		local wepdata = GetWeaponHUDData( ply )
		//PrintTable(wepdata)
		local can = true
		if wepdata.HoldType == "melee" or wepdata.HoldType == "knife"then can = false end
		if can then
		surface.SetDrawColor( Color(255,255,255,150) )
		surface.DrawRect( dx, dy-16, 200, 16 )
		draw.SimpleText( language.GetPhrase( wepdata.Name ), "Default", dx+4,  dy-16 + 16/2, tcol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		surface.SetDrawColor( tcol )
		surface.DrawRect( dx, dy, 200, 50 )
		//chat.AddText((dx + 32 + 192).." "..ScreenScale(57.5))
			local ishl = string.find(wepdata.Name,"#HL2")
			local data = tostring( ply:GetNWInt('clip1wea') ).."/"..tostring( ply:GetNWInt('ammo1wea') )
			if ishl then
				data = tostring(wepdata.Clip1).."/"..tostring(wepdata.Remaining1)
			end
			if wepdata.HoldType == "grenade" then
				data = tostring(wepdata.Remaining1)
			end
			local font = "lidi_hud_Large"
			if wepdata.Remaining2 != 0 then
				data = data.. "("..tostring(wepdata.Remaining2)..")"
				font = "lidi_hud_38"
			end
			draw.SimpleText( data, font, dx+100, dy+23,  Color(255,255,255) , TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, tcol )
				
		//	end
		end
		end
	end
	if DrawTargetID then DrawTargetID() end
	self:DrawKillFeed()
	if self.DrawCrosshair then
		
		if GAMEMODE.Crosshair3d then
			local x,y = 0,0
			local tr = LocalPlayer():GetEyeTrace()
			x = tr.HitPos:ToScreen().x
			y = tr.HitPos:ToScreen().y

			self:DrawCrosshair( x,y )
		else
			self:DrawCrosshair( ScrW()/2, ScrH()/2 )
		end
	end
end

TargetIDAlpha = 0
TargetIDName = ""
TargetIDColor = Color(255,255,255)

local lastTargetCycle = CurTime()

local TargetIDFadeTime = CreateClientConVar( "deathrun_targetid_fade_duration", 1, true, false )
function DrawTargetID()
	if !LocalPlayer():Alive() then return end 
	local dt = CurTime() - lastTargetCycle
	lastTargetCycle = CurTime()

	local fps = 1/dt
	local fmul = 100/fps

	local tr = LocalPlayer() and LocalPlayer():GetEyeTrace() or {}

	if tr.Hit then
		if tr.Entity then
      if tr.Entity:GetNWBool( "StealthCamo" ) then return end
      if LocalPlayer():Team() != TEAM_PROP then return end
        
      if tr.Entity:IsPlayer() then
        TargetIDAlpha = 255
        TargetIDName = tr.Entity:Nick()
        TargetIDColor = tr.Entity:GetNWBool('coloringplybool') and tr.Entity:GetNWVector( 'coloringplycolor'):ToColor() or team.GetColor( tr.Entity:Team() )
        TargetIDPlayer = tr.Entity

        local clamped = math.Clamp( TargetIDPlayer:Health(), 0, 100 )
        clamped = clamped .. '%'

        TargetIDName = TargetIDName .. " - " .. clamped 

        if tr.Entity:Team() == TEAM_PROP then
          if IsValid(tr.Entity:GetNWEntity("propme")) then
            halo.Add({tr.Entity:GetNWEntity("propme")}, Color(255,255,255), 2, 2, 2, true, true) 
          end
        end
      end
      if tr.Entity.TextOver then
        
        TargetIDAlpha = 255
        TargetIDName = tr.Entity.TextOver
        TargetIDColor = tr.Entity.ColorOver
        TargetIDPlayer = tr.Entity

        tr.Entity.TextOver = null
      end
		end
	end

	local x , y = ScrW()/2, ScrH()/2 + 16
  TargetIDColor.a = math.pow(TargetIDAlpha, 0.3)*255 / math.pow(255, 0.3)
  
	draw.SimpleText( TargetIDName , "S_Bold_20", x, y, TargetIDColor ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1)
	draw.SimpleText( TargetIDName , "S_Bold_20", x+1, y+1, Color(0,0,0,TargetIDColor.a*0.2) ,TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	-- our benchmark is 100fps
	-- e.g. our fade time is 3s
	-- so each frame at 100fps the alpha is alpha - 1/(3s * 100f) * 255 * fmul

	TargetIDAlpha = math.Clamp( TargetIDAlpha - ( 1/( (TargetIDFadeTime:GetFloat()) * 100) ) * 255 * fmul, 0, 255 )

	-- draw floating names if you're on the Death team
	-- draw them for Runners as well, but not thru walls
	for _, ply in ipairs(player.GetAll()) do
		if ply:GetNWBool( "StealthCamo" ) then return end
		local data = ply:EyePos():ToScreen()
		local draw2 = false

		if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and ply ~= LocalPlayer() then
			if LocalPlayer():Team() == ply:Team() and LocalPlayer():Alive() then
				draw2 = true
			end
			if (LocalPlayer():Team() ~= ply:Team()) then
				if (ply ~= LocalPlayer():GetObserverTarget()) or (LocalPlayer():GetObserverMode() ~= OBS_MODE_IN_EYE) then
					draw2 = false
				end
			end
		end
		if GAMEMODE.CanSee then
			draw2 = false
		end
		if draw2 then
			local a = 0
			local dist = LocalPlayer():EyePos():Distance( ply:EyePos() )
			if dist > 500 then
				a = 0
			elseif dist < 100 then
				a = 255
			else
				a = InverseLerp( dist, 500, 100 )*255
			end

			local tcol = ply:GetNWBool('coloringplybool') and ply:GetNWVector( 'coloringplycolor'):ToColor() or team.GetColor( ply:Team() )
			tcol.a = a

			draw.SimpleText( ply:Nick(), "lidi_hud_Medium", data.x, data.y-32, Color(255,255,255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			//deathrunShadowTextSimple( team.GetName( ply:Team() ), "lidi_hud_Small", data.x, data.y-16, tcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

end

hook.Add("PrePlayerDraw", "TransparencyPlayers", function( ply )
	if LocalPlayer():Team() == TEAM_HUNT then
		if ply:GetRenderMode() ~= RENDERMODE_TRANSALPHA then
			ply:SetRenderMode( RENDERMODE_TRANSALPHA )
		end

		local fadedistance = 75

		local eyedist = LocalPlayer():EyePos():Distance( ply:EyePos() )
		local col = ply:GetColor()

		if eyedist < fadedistance and LocalPlayer() ~= ply then
			local frac = InverseLerp( eyedist, 5, fadedistance )
			
			col.a = Lerp( frac, 20, 255 )

			if ply:Team() ~= LocalPlayer():Team() then col.a = 255 end

			ply:SetColor( col )
		elseif LocalPlayer() == ply then
			col.a = 255
			ply:SetColor( col )
		else
			col.a = 255
			ply:SetColor( col )
		end
	end
end)

function GetWeaponHUDData( ply )

	local data = {}
	local weptable = {}
	local wep = ply:GetActiveWeapon()

	if IsValid( wep ) then
		weptable = wep:GetTable()
		data.Clip = wep.Clip
		data.Ammo = wep.Ammo
		data.Name = wep:GetPrintName() or "Weapon"
		data.Clip1 = wep:Clip1() or -1
		data.Clip2 = wep:Clip2() or -1
		data.Clip1Max = 1
		data.Clip2Max = 1
		data.Remaining1 = ply:GetAmmoCount( wep:GetPrimaryAmmoType()  ) or wep:Ammo1() or 0
		data.Remaining2 = ply:GetAmmoCount( wep:GetSecondaryAmmoType()  ) or wep:Ammo2() or 0
		data.HoldType = wep:GetHoldType() or "melee"
		if weptable.Primary then
			data.Clip1Max = weptable.Primary.ClipSize or data.Clip2Max
		end
		if weptable.Secondary then
			data.Clip2Max = weptable.Secondary.ClipSize or data.Clip2Max
		end

		data.ShouldDrawHUD = true
		if data.Clip1 < 0 then data.ShouldDrawHUD = false end
	end

	return data	

end

function GM:DrawCrosshair(x,y)
	local thick = XHairThickness:GetInt()
	local gap = XHairGap:GetInt()
	local size = XHairSize:GetInt()

	surface.SetDrawColor(XHairRed:GetInt(), XHairGreen:GetInt(), XHairBlue:GetInt(), XHairAlpha:GetInt())
	surface.DrawRect(x - (thick/2), y - (size + gap/2), thick, size )
	surface.DrawRect(x - (thick/2), y + (gap/2), thick, size )
	surface.DrawRect(x + (gap/2), y - (thick/2), size, thick )
	surface.DrawRect(x - (size + gap/2), y - (thick/2), size, thick )
end

GM.KillFeed = {}

function kill_feed_add(msgs, x, y, dx, dy, ddx, ddy)
	local t = {}
	t.time = CurTime()
	t.message = msgs or {}
	t.x = x or 0
	t.y = y or 0
	t.dx = dx or 0
	t.dy = dy or 0
	t.ddx = ddx or 0 
	t.ddy = ddy or 0 
	table.insert(GAMEMODE.KillFeed, t)
end

net.Receive("Notification", function (len)
	local msgs = {}
	while true do
		local i = net.ReadUInt(8)
		if i == 0 then break end
		local col = net.ReadVector()
		local str = net.ReadString()
		local a ={}
		a['msg'] = str 
		a['col'] = Color(col.x, col.y, col.z)
		table.insert(msgs, a)
	end
	kill_feed_add(msgs, ScrW()-32,ScrH()/7, 0, -0.35, 0, -0.00025)
end)

local lastCycle = CurTime()
function GM:DrawKillFeed()

	local dt = CurTime() - lastCycle
	lastCycle = CurTime()

	local fps = (1/dt)
	local fmul = 100/fps
	
	local gap = draw.GetFontHeight("RobotoHUD-15") + 4
	local down = 0
	local k = 1
	while true do
		if k > #GAMEMODE.KillFeed then
			break
		end
		local t = GAMEMODE.KillFeed[k]
		
		local aliveFor = CurTime() - t.time
		local fadein = math.Clamp( Lerp( InverseLerp(aliveFor,0,0.5), 0, 255 ), 0, 255 )
		
		surface.SetFont("RobotoHUD-15")
		if CurTime() - t.time > 10 then
			table.remove( self.KillFeed, k )
		end
		
		local last = 10
		for i,ms in SortedPairs(t.message, true) do
			local killed = " " .. (ms['msg'] or "killed themself")
			local twk, thk = surface.GetTextSize(killed)
			twk=twk-4
			last = last + twk 
			local mss = ms['col']
			
			mss.a = fadein
			draw.ShadowText(killed, "RobotoHUD-15", ScrW() - last, t.y + down * gap, mss, 0)
		end


		t.x = t.x + t.dx * fmul
		t.y = t.y + t.dy * fmul

		t.dx = t.dx + t.ddx * fmul
		t.dy = t.dy + t.ddy * fmul

		down = down + 1
		k = k + 1
			
	end
end

function GM:PlayerStartVoice() end
function GM:PlayerEndVoice() end


timer.Simple(2,function()
	hook.Add("PlayerStartVoice","hud2",function( ply )
		if !IsValid(LocalPlayer()) or !LocalPlayer():IsPlayer() then return end
		if LocalPlayer() == ply && ply:GetNWBool('micon') then 
			if !aaatriiigg and !groupsAllowVoice[ply:GetUserGroup()] then
				return
			end
		end 
		if IsValid(ply.vp) and ispanel(ply.vp) then
			ply.vp:Remove()
		end
		ply.vp = vgui.Create("DVoicePanel2",window.panels)
		if !IsValid(ply.vp) or !ispanel(ply.vp) then return end

		ply.vp:Setup(ply)
	end)
end)

hook.Add("Tick","destroy",function()
	for _,ply in pairs(player.GetAll())do
		if !ply.vp or !ispanel(ply.vp) then continue end
		if !ply:IsSpeaking() and IsValid(ply.vp) then
			ply.vp:SetDestroy(EndVoice)
		end
	end
end)


window = {}

window.panels = vgui.Create("Panel", self)
window.panels:ParentToHUD()
window.panels:SetPos( ScrW() - 250, 100 )
window.panels:SetSize( 200 , ScrH() - 200 )

PANEL = {}

AccessorFunc( PANEL, "Padding", "Padding", FORCE_NUMBER )

AccessorFunc( PANEL, "alpha", "Alphas", FORCE_NUMBER )
AccessorFunc( PANEL, "destroytime", "DestroyTime", FORCE_NUMBER )

function PANEL:Init()
	self:SetTall(28)
	self:SetWide(200)
	self.Padding = 2
	self.alpha = 255
	self.destroytime = 0.7
	self:Dock( BOTTOM )
end 

function PANEL:Setup(ply)
	self.dend = 0
	self.trigger = 0
	self.ply = ply
		
	self.ava = vgui.Create( "AvatarImage", self )
	self.ava:SetSize( 28, 28 )
	self.ava:SetPos( 0, 0 )
	self.ava:SetPlayer( ply, 28 )
end

function PANEL:Paint(w,h)
	if !self.ply then return end
	 vv = 100
	
	if not IsValid(self.ply) then return end
	surface.SetDrawColor(team.GetColor(self.ply:Team()))
	surface.DrawRect(0,0,w,h)

	draw.SimpleText( self.ply:Nick() ,"lidi_hud_Medium",self.Padding*2+32,h/2,Color(255,255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_CENTER)

end

function PANEL:SetDestroy(func)
	if self.trigger != 1 then
		self.dend = CurTime()+self.destroytime
		self.trigger = 1
	end
end
function PANEL:UnSetDestroy()
	self:SetAlpha(self.alpha)
	self.dend = 0
end

function PANEL:Think()

	if self.dend == nil then return end
	if self.dend == 0 then 
		self:SetAlpha(self.alpha)
		self.ava:SetAlpha(self.alpha)
		return
	end
	self:SetAlpha((self.alpha/(self.destroytime*100))*(math.Round(self.dend-CurTime(),2)*100))
	
	self.ava:SetAlpha(math.min((self.alpha/(self.destroytime*100))*(math.Round(self.dend-CurTime(),2)*100)+50,255))
	
	if self.dend < CurTime() then
		self.ava:Remove()
		self:Remove() 
	end
	 
end

vgui.Register("DVoicePanel2",PANEL,"Panel")
	