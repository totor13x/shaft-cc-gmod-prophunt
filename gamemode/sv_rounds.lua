 util.AddNetworkString("SetRound")
GM.RoundStage = 0
GM.RoundCount = 0
GM.TimerRound4 = 0

if GAMEMODE then
	GM.RoundStage = GAMEMODE.RoundStage
	GM.RoundCount = GAMEMODE.RoundCount
	GM.TimerRound4 = GAMEMODE.TimerRound4
end

-- Для управления извне движком
function GM:SetRoundCound(count)
	self.RoundCount = count
end

function GM:SetForceIvent(sub)
	self.ForceIvent = sub
end

-- Базовая функция раундов
function GM:GetRound(id)
	if id ~= nil then
		return self.RoundStage == id
	end
	return self.RoundStage or 0
end

function GM:SetRound(round)
	self.RoundStage = round
	
	if round == 4 then
		self.TimerRound4 = CurTime()
	end
	net.Start("SetRound")
		net.WriteUInt(self.RoundStage, 32)
	net.Broadcast()
end

function GM:RefreshRound(ply)	
	net.Start("SetRound")
		net.WriteUInt(self.RoundStage, 32)
	net.Send(ply)
end

--[[	
	*Параметры игры*
0 - не хватает игроков
1 - основная, когда все играют
2 - ожидание игроков
]]--
function GM:RoundThink()
	local players = player.GetAll()
	local spec = team.GetPlayers(TEAM_SPEC)
	if #players-#spec > 1 and self:GetRound(0) and self.LastConnect and self.LastConnect < CurTime() then
		self:StartRound()
	elseif self:GetRound( 1 ) then
		//self:ThinkTker()
		self:ThinkAll()
		if !self.LastDeath || self.LastDeath < CurTime() then
			self:RoundCheckForWin(players, spec)
		end
	elseif self:GetRound( 2 ) and self.CooldownTimer and self.CooldownTimer < CurTime() then
		self:StartRound()
	elseif self:GetRound( 4 ) && self.TimerRound4+60 < CurTime() and self.TimerRound4 != 0 then
		self:StartRound()
	end
end

function GM:ThinkAll()
	if UTILTIMER >= ROUND:GetTimer() then
		local players = player.GetAll()
		for i, ply in pairs(players) do
			if ply:Team() != TEAM_PROP then continue end
			ply.NwCooldownAutoTaunt = ply.NwCooldownAutoTaunt or 0
			if (ply.TauntingLast or 0) >= CurTime() then
				ply.NwCooldownAutoTaunt = CurTime()
				ply:SetNWInt("CooldownAutoTaunt", ply.NwCooldownAutoTaunt+0.2)
			end
			
			if ply.NwCooldownAutoTaunt+TIMERAUTOTAUNT < CurTime() then
				ply:ConCommand("ph_taunt rand_long")
			end
		end
	end
end

function GM:RoundCheckForWin(players, spec)
	
	if #players-#spec <= 1 then 
		self:SetRound(0)
		return 
	end
	
	if ROUND:GetTimer() == 0 then
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 10
		self:EndRound(1)
		return
	end
	
	local aliveprops = {}
	local alivehunt = {}
	
	for i,v in pairs(players) do
		if v:Alive() then
			if v:Team() == TEAM_PROP then
				table.insert(aliveprops, v)
			elseif v:Team() == TEAM_HUNT then
				table.insert(alivehunt, v)
			end
		end
	end
	
	if #alivehunt == 0 then
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 5
		self:EndRound(1)
		return
	end
	
	if #aliveprops == 0 then
		self:SetRound( 2 )
		self.CooldownTimer = CurTime() + 5
		self:EndRound(2)
		return
	end
end

function GM:EndRound(typ)

	BroadcastLua([[
	local pitch = math.random(80, 120)
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound("ambient/alarms/warningbell1.wav", 100, pitch)
	end
	]])
	
	self.RoundCount = self.RoundCount + 1
	
	if typ == 1 then		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
		ct:Add("Победа пропов.", Color( 255, 255, 255 ))
		ct:Broadcast()
	elseif typ == 2 then		
		local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
		ct:Add("Победа хантеров.", Color( 255, 255, 255 ))
		ct:Broadcast()
	end
	if self.RoundCount >= ConfigPH['MaxRounds'] then
		self:SetRound(4)
		MV:BeginMapVote()
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Достигнут лимит раундов. Запуск голосования.",Color(255,255,255))
		ms:Send()
		return
	end
	
	if ROUND.PlainMap ~= nil then
			
		self:SetRound(4)
		
		local nextmap = ROUND.PlainMap
		
		local ms = ChatMsg()
		ms:Add("[", Color(255, 255, 255))
		ms:Add("SYSTEM", Color(11, 53, 114))
		ms:Add("] ", Color(255, 255, 255))
		ms:Add("Ранее была выбрана карта "..nextmap..". Смена через 5 секунд.",Color(255,255,255))
		ms:Send()
		
		timer.Simple(5, function()
		
			local ms = ChatMsg()
			ms:Add("[", Color(255, 255, 255))
			ms:Add("SYSTEM", Color(11, 53, 114))
			ms:Add("] ", Color(255, 255, 255))
			ms:Add("Смена карты...",Color(255,255,255))
			ms:Send()

			RunConsoleCommand("changelevel", nextmap)
		end)
	end
end

function GM:StartRound()
	local players = player.GetAll()
	local spec = team.GetPlayers(TEAM_SPEC)
	if #players-#spec <= 1 then
		self:SetRound(0)
		return
	end
	game.CleanUpMap()
	timer.Remove("UniqueTriggerHanters")
	ROUND:SetTimer(7*60)
	
	print("Start New Round")
	local ct = ChatText()
				ct:Add("[", Color(255, 255, 255))
				ct:Add("SYSTEM", Color(11, 53, 114))
				ct:Add("] ", Color(255, 255, 255))
	ct:Add("Новый раунд начался.", Color( 255, 255, 255 ))
	ct:Broadcast()
	
	self:SetRound(1)
	
	local allplayers = {}
	
	for i,v in pairs(player.GetAll()) do
		if v:Team() == TEAM_SPEC then continue end
		table.insert(allplayers, v)
	end
	
	for i,v in pairs(allplayers) do
		if v:Team() == TEAM_HUNT then
			v:SetTeam(TEAM_PROP)
			v:SetNoCollideWithTeammates( false )
		else
			v:SetTeam(TEAM_HUNT)
			v:SetNoCollideWithTeammates( true )
		end
		v:StripWeapons()
		v:StripAmmo()
		v:Spawn()
		v:SetBloodColor(DONT_BLEED)
		v.LimitPoints = 0
	end
	
	timer.Create( "UniqueTriggerHanters", WHENCOMBINESGOING, 1, function()
		for i,v in pairs(allplayers) do
			if IsValid(v) then
			if v:Alive() and v:Team() == TEAM_PROP then
				v:SendLua('notification.AddLegacy( "Хантеры вышли на охоту!", NOTIFY_UNDO, 2 )')
			end
			end
		end
	end)
	
	timer.Simple(0.01,function()
	
		for i,v in pairs(allplayers) do
			if IsValid(v) then
				if v:Team() == TEAM_PROP then
					v:ConCommand("ph_thirdperson_enabled 1")
				end
			end
		end
	end)
end