util.AddNetworkString("chattext_msg")
util.AddNetworkString("chattext_msgnetstring")

local meta = {}
meta.__index = meta

function meta:Add(string, color)
	local t = {}
	t.text = string
	t.color = color or self.default_color or color_white
	table.insert(self.msgs, t)
	return self
end

function meta:NetConstructMsg()
	net.Start("chattext_msg")
	for k, msg in pairs(self.msgs) do
		net.WriteUInt(1,8)
		net.WriteString(msg.text)
		if !msg.color then
			msg.color = self.default_color or color_white
		end
		net.WriteVector(Vector(msg.color.r, msg.color.g, msg.color.b))
	end
	net.WriteUInt(0,8)
	return self
end

function meta:Broadcast()
	self:NetConstructMsg()
	net.Broadcast()
	return self
end

function meta:Send(players)
	self:NetConstructMsg()
	if players == nil then
		net.Broadcast()
	else
		net.Send(players)
	end
	return self
end

function ChatText(msgs)
	local t = {}
	t.msgs = msgs or {}
	setmetatable(t, meta)
	return t
end 

local meta2 = {}
meta2.__index = meta2

function meta2:Add(string, color)
	local t = {}
	t.text = string
	t.color = color or self.default_color or color_white
	table.insert(self.msgs, t)
	return self
end

function meta2:NetConstructMsg()
	net.Start("Notification")
	for k, msg in pairs(self.msgs) do
		net.WriteUInt(1,8)
		if !msg.color then
			msg.color = self.default_color or color_white
		end
		net.WriteVector(Vector(msg.color.r, msg.color.g, msg.color.b))
		net.WriteString(msg.text)
	end
	net.WriteUInt(0,8)
	return self
end

function meta2:Broadcast()  
	self:NetConstructMsg() 
	net.Broadcast()
	return self
end

function meta2:Send(players)
	self:NetConstructMsg()
	if players == nil then
		net.Broadcast()
	else
		net.Send(players)
	end
	return self
end

function NotificationText(msgs)
	local t = {}
	t.msgs = msgs or {}
	setmetatable(t, meta2)
	return t
end 
function GM:PlayerCanHearPlayersVoice( listener, talker ) 
	return true
end
hook.Add("PlayerSay", "Round.last", function(ply, text)
	if text == '!rounds' then
		local ct = ChatText()
			ct:Add("[", Color(255, 255, 255))
			ct:Add("SYSTEM", Color(11, 53, 114))
			ct:Add("] ", Color(255, 255, 255))
		  ct:Add("Осталось ".. ConfigPH['MaxRounds']-GAMEMODE.RoundCount .." раундов.", Color( 255, 255, 255 ))
		  ct:Send(ply)
	end	
	if text == "!crosshair" then
		ply:ConCommand("deathrun_open_crosshair_creator")
	end
end)
