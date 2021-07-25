GM.Name		= "Prop Hunt"
GM.Author	= "Totor13x"
GM.Email 		= "totor_@outlook.com"
GM.Website 		= "https://shaft.im/"

TEAM_PROP = 1
TEAM_HUNT = 2
TEAM_SPEC = 3
Totor = Totor or {}
function GM:SetupTeams()
	team.SetUp(TEAM_PROP, 'Пропы', Color( 192, 64, 0 ), false)
	team.SetUp(TEAM_HUNT, 'Охотники', Color( 53, 116, 232 ), false)
	
	team.SetUp(TEAM_SPEC, 'Наблюдатели', Color(150, 150, 150), false)
	team.SetSpawnPoint( TEAM_PROP, {"info_player_terrorist", "info_player_rebel", "info_player_deathmatch", "info_player_allies"})
	team.SetSpawnPoint( TEAM_HUNT, {"info_player_counterterrorist", "info_player_combine", "info_player_deathmatch", "info_player_axis"})
	team.SetSpawnPoint( TEAM_SPEC, {"info_player_counterterrorist", "info_player_combine", "info_player_deathmatch", "info_player_axis"})
end

GM:SetupTeams()

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
	if( ply:Team() != TEAM_HUNT ) then return true end
end

function Totor.DisableModelExpa(ply)
	return true
end

ROUND = {}
ROUND_TIMER = ROUND_TIMER or 0
function ROUND:GetTimer() 
	return ROUND_TIMER or 0
end

WHENCOMBINESGOING = 45
UTILTIMER = 2*60+30
TIMERAUTOTAUNT = 30

MUTE_NONE = 0
MUTE_NOTALIVE = 1
MUTE_ALIVE = 2

function limitPoints(ply, count)
	ply.LimitPoints = ply.LimitPoints or 0
	count = count or 0
	ply.LimitPoints = ply.LimitPoints+count
	if 2500 <= ply.LimitPoints+count then
		return false
	end
	
	return true
end

timer.Create("RoundTimerCalculate", 0.2, 0, function()
	if GAMEMODE.RoundStage != 1 then return end
	ROUND_TIMER = ROUND_TIMER - 0.2
	if ROUND_TIMER < 0 then ROUND_TIMER = 0 end
end)

if SERVER then
	util.AddNetworkString("DeathrunSyncRoundTimer")
	function ROUND:SyncTimer()
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Broadcast()
	end
	function ROUND:SyncTimerPlayer( ply )
		net.Start("DeathrunSyncRoundTimer")
		net.WriteInt( ROUND:GetTimer(), 16 )
		net.Send( ply )
	end
	function ROUND:SetTimer( s )
		ROUND_TIMER = s
		ROUND:SyncTimer()
	end
else
	net.Receive("DeathrunSyncRoundTimer", function( len, ply )
		ROUND_TIMER = net.ReadInt( 16 )
	end)
end

-- On CLIENT
TauntForClientside = {}
TauntsID = {}
-- On SHARED
Taunts = {} 
-- On SERVER
TauntLongest = {} 

-- TauntCategories = {}
-- TauntPaths = {}
-- TauntLongest = {}


function PluralEdit(type, secs)
	local rounds_played2, tetd = ""
	if type == 'murds' then
		rounds_played2 = secs;
		local clear_explode = string.sub(rounds_played2, -1)
		clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'убийц';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'убийц';
		elseif (clear_explode == 1) then
			tetd = 'убийцы';
		elseif (clear_explode < 5) then
			tetd = 'убийц';
		else 
			tetd = 'убийц';
		end
	end
	return tetd
end

function sec2Min(secs)
local rounds_played2
local ostalost = "Осталось"

	if (secs < 60) then
	
	rounds_played2 = secs;
	local clear_explode = string.sub(rounds_played2, -1)
	clear_explode =	tonumber(clear_explode)
		if(clear_explode == 0) then
			tetd = 'секунд';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'секунд';
		elseif (clear_explode == 1) then
			ostalost = "Осталась"
			tetd = 'секунда';
		elseif (clear_explode < 5) then
			tetd = 'секунды';
		else 
			tetd = 'секунд';
		end
	elseif (secs < 3600) then
		rounds_played2 = math.Round(secs / 60);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'минут';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'минут';
		elseif (clear_explode == 1) then
			ostalost = "Осталась"
			tetd = 'минута';
		elseif (clear_explode < 5) then
			tetd = 'минуты';
		else 
			tetd = 'минут';
		end
	elseif (secs < 86400) then
		rounds_played2 = math.Round(secs / 3600);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'часов';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'часов';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'час';
		elseif (clear_explode < 5) then
			tetd = 'часа';
		else 
			tetd = 'часов';
		end
	elseif (secs < 2629743) then
		rounds_played2 = math.Round(secs / 86400);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'дней';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'дней';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'день';
		elseif (clear_explode < 5) then
			tetd = 'дня';
		else 
			tetd = 'дней';
		end
	elseif (secs < 31556926) then
		rounds_played2 = math.Round(secs / 2629743);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'месяцев';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'месяцев';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'месяц';
		elseif (clear_explode < 5) then
			tetd = 'месяца';
		else 
			tetd = 'месяцев';
		end
	else
		rounds_played2 = math.Round(secs / 31556926);
		
		local clear_explode = string.sub(rounds_played2, -1)
			  clear_explode =	tonumber(clear_explode)
		
		if(clear_explode == 0) then
			tetd = 'лет';
		elseif ((rounds_played2 == 11) or (rounds_played2 == 12) or (rounds_played2 == 13) or (rounds_played2 == 14)) then
			tetd = 'лет';
		elseif (clear_explode == 1) then
			ostalost = "Остался"
			tetd = 'год';
		elseif (clear_explode < 5) then
			tetd = 'года';
		else 
			tetd = 'лет';
		end
	end
return ostalost..' '..rounds_played2..' '..tetd
end

function InverseLerp( pos, p1, p2 )

	local range = 0
	range = p2-p1

	if range == 0 then return 1 end

	return ((pos - p1)/range)

end

function colorDif(col1, col2)
	local x = col1.r - col2.r
	local y = col1.g - col2.g
	local z = col1.b - col2.b
	x = x > 0 and x or -x
	y = y > 0 and y or -y
	z = z > 0 and z or -z
	return x + y + z
end

local lp, ft, ct, cap = LocalPlayer, FrameTime, CurTime
local mc, mr, bn, ba, bo, gf = math.Clamp, math.Round, bit.bnot, bit.band, bit.bor, {}
function GM:Move( ply, data )
	if ply:Team() == TEAM_PROP then return end
	-- fixes jump and duck stop
	local og = ply:IsFlagSet( FL_ONGROUND )
	if og and not gf[ ply ] then
		gf[ ply ] = 0
	elseif og and gf[ ply ] then
		gf[ ply ] = gf[ ply ] + 1
		if gf[ ply ] > 4 then
			ply:SetDuckSpeed( 0.4 )
			ply:SetUnDuckSpeed( 0.2 )
		end
	end

	if og or not ply:Alive() then return end
	
	gf[ ply ] = 0
	ply:SetDuckSpeed(0)
	ply:SetUnDuckSpeed(0)

	if not IsValid( ply ) then return end
	if lp and ply ~= lp() then return end
	
	if ply:IsOnGround() or not ply:Alive() then return end
	
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed()
	
	if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
	if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
	
	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()
	if wishspeed > data:GetMaxSpeed() then
		wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
		wishspeed = data:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = mc( wishspd, 0, 30 )

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot( wishdir )

	local addspeed = wishspd - current
	if addspeed <= 0 then return end

	local accelspeed = 1000 * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end
	
	local vel = data:GetVelocity()
	vel = vel + (wishdir * accelspeed)

	ply.SpeedCap = 99999
	
	if ply.SpeedCap and vel:Length2D() > ply.SpeedCap and SERVER then
		local diff = vel:Length2D() - ply.SpeedCap
		vel:Sub( Vector( vel.x > 0 and diff or -diff, vel.y > 0 and diff or -diff, 0 ) )
	end
	data:SetVelocity( vel )
	return false
end

local function AutoHop( ply, data )

	if lp and ply ~= lp() then return end
	//if not ply:IsSuperAdmin() then return end
	//if ply:SteamID() != 'STEAM_0:1:68421988' then return end
	
	//if !(EVENTS:GetID() == 0) then return end
	//if !ply.allowbhop then return end	
	if ply:Team() != TEAM_HUNT then return end
	local ButtonData = data:GetButtons()
	if ba( ButtonData, IN_JUMP ) > 0 then
		if ply:WaterLevel() < 2 and ply:GetMoveType() ~= MOVETYPE_LADDER and not ply:IsOnGround() then
			data:SetButtons( ba( ButtonData, bn( IN_JUMP ) ) ) 
		end
	end
 //end  
end
hook.Add( "SetupMove", "AutoHop", AutoHop ) 



-- function ulx.movegroup( calling_ply, target_ply, team2 )
-- 	local teamid
-- 	if team2 == 'Проп' then
-- 		teamid = TEAM_PROP
-- 	elseif team2 == 'Охотник' then
-- 		teamid = TEAM_HUNT
-- 	elseif team2 == 'Наблюдатель' then
-- 		teamid = TEAM_SPEC
-- 	end
	
-- 	local curTeam = target_ply:Team()
-- 	local newTeam = teamid or 0
-- 	if newTeam >= 1 && newTeam <= 3 && newTeam != curTeam then
-- 		target_ply:SetTeam(newTeam)
-- 		target_ply:Spawn()
		
-- 		local femtext1
-- 		local femtext2 = ""

-- 		if newTeam == TEAM_PROP then
-- 			femtext2 = "пропы"
-- 		elseif newTeam == TEAM_HUNT then
-- 			femtext2 = "охотники"
-- 		else
-- 			femtext2 = "наблюдатели"
-- 		end
-- 	ulx.fancyLogAdmin(calling_ply, "#A movegroup #T#s ", target_ply, femtext2)
-- 	end
	
-- end
-- local movegroup = ulx.command( "PROPHUNT", "ulx movegroup", ulx.movegroup )
-- movegroup:addParam{ type=ULib.cmds.PlayerArg }
-- movegroup:addParam{ type=ULib.cmds.StringArg, hint="Перевод в", completes={'Проп','Охотник','Наблюдатель'}, ULib.cmds.restrictToCompletes } -- only allows 
-- movegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
-- movegroup:help( "Перевести в команду" )


-- function ulx.moveafk( calling_ply, target_ply)
-- 	target_ply:KillSilent()
-- 	target_ply:SetTeam(TEAM_SPEC)
-- 	//net.Start("MovedAFKPlayer")
-- 	//net.Send(target_ply)
	
-- 	ulx.fancyLogAdmin(calling_ply, "#A movegroup #T#s ", target_ply, 'наблюдатели из-за AFK')
-- end

-- local moveafk = ulx.command( "PROPHUNT", "ulx afk", ulx.moveafk, "!afk" )
-- moveafk:addParam{ type=ULib.cmds.PlayerArg }
-- moveafk:defaultAccess( ULib.ACCESS_SUPERADMIN )
-- moveafk:help( "Игрок AFK" )

-- TauntsForClientside = {}
-- TauntCategories = {}
-- TauntPaths = {}
-- TauntLongest = {}

-- function addTa(cat, nam, wav, dur, reward, cdn)
-- 	TauntCategories[cat] = TauntCategories[cat] or {}
-- 	local a = {}
-- 	a.Name = nam
-- 	a.Wav = wav
-- 	a.Duration = dur
-- 	a.Rew = reward
-- 	a.Category = cat
-- 	a.CDN = cdn
--   TauntPaths[wav] = a
  
--   TauntsForClientside[cat] = 

-- 	table.insert(TauntCategories[cat], a)
-- 	if dur > 6 then
-- 		TauntLongest[wav] = a
-- 	end
-- end

-- addTa("Звуки", "Minecraft hurt", 				"taunts_new/classic_hurt.mp3",									 0.37, 		10)
-- addTa("Голос", "Привет #1",						"vo/npc/female01/hi01.wav",										 0.38, 		10)
-- addTa("Голос", "I'm gay", 						"taunts_new/idubbbztv-im-gay-mp3cut.mp3", 						 0.99, 		30)
-- addTa("Голос", "Nani?!", 						"taunts_new/nani_mkANQUf.mp3",									 1.2, 		50)
-- addTa("Голос", "Hey listen", 					"taunts_new/hey_listen.mp3",									 1.62, 		50)
-- addTa("Голос", "Baka (cut)",					"taunts_new/baka-cut-mp3.mp3", 									 1.7, 		60)
-- addTa("Звуки", "Jutsy", 						"taunts_new/katon.mp3", 										 2.1, 		70)
-- addTa("Голос", "One eternity later", 			"taunts_new/one-eternity-later.mp3",							 2.22, 		70)
-- addTa("Звуки", "Pikachu", 						"taunts_new/pikachu_9.mp3", 									 2.38, 		80)
-- addTa("Звуки", "Axe - power", 					"taunts_new/power-logo.mp3",								 	 2.4, 		80)
-- addTa("Голос", "Yoooouuuuuh", 					"taunts_new/butthurt-desk_1.mp3",								 2.56,		80)
-- addTa("Голос", "Baka", 							"taunts_new/baka_1.mp3", 										 3.27, 		100)
-- addTa("Звуки", "Dota - Игра найдена", 			"taunts_new/dota-2-game-ready-sound-youtube1.mp3", 				 3.62, 		120)
-- addTa("Голос", "Dread - Отстаньте", 			"taunts_new/dread-.mp3",										 4.26,		170)
-- addTa("Звуки", "Аплодисменты", 					"taunts_new/aplausos_2.mp3", 									 4.81, 		200)
-- addTa("Голос", "Darth Vader - Noooooooooooo", 	"taunts_new/nooo.swf.mp3",										 5.3, 		250)
-- addTa("Голос", "Fresh avocado", 				"taunts_new/fresh-avocado-vine_qWSecR0 (1).mp3",				 6.61, 		300)
-- addTa("Голос", "lol", 							"taunts_new/lol_33.mp3",										 6.77, 		300)
-- addTa("Голос", "Notice me, senpai", 			"taunts_new/pewdiepie-notice-me-senpai-compilation-mp3cut.mp3",	 6.92, 		350)
-- addTa("Звуки", "Skyrim Level Up", 				"taunts_new/42dfb7_skyrim_level_up_sound_effect.mp3", 			 7.34, 		400) 
-- addTa("Голос", "Trololo", 						"taunts_new/trollolol.swf.mp3",									 9.98, 		600)
-- addTa("Звуки", "Megalovania", 					"taunts_new/untitled_aTGmG2D.mp3",								12.17, 		800)
-- addTa("Голос", "Lalala", 						"taunts_new/lalalalala.swf.mp3",								12.41, 		800)

-- //addTa("Голос", "Tuturu", "taunts/tuturu1.wav",1.25, 1)
-- //addTa("Голос", "Solo - зажигалочка", "taunts_new/aleksey-quotsoloquot-berezin-zazhigalochka-cut-mp3.mp3",6.67, 6)
-- //addTa("Звуки", "Windows XP - Shutdown", "taunts_new/preview_4.mp3", 2.84, 50)
