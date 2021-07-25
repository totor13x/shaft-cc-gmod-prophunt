util.AddNetworkString("TheInternetTaunt")

hook.Add("GetFallDamage", "DisableFallDamage", function(ply)
	return false
	//if ply:Team() == TEAM_PROP then return false end
end)

hook.Add("PostCleanupMap", "FixProps", function(ply)
	for i,v in pairs(ents.FindByClass('prop_physics_*')) do
		v:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
end)


function GM:PlayerCanPickupWeapon( ply, ent )
	if ply:Team() == TEAM_PROP then return false end
	return true
end

concommand.Add("ph_taunt", function (ply, com, args)
	if !IsValid(ply) then
		return
	end
	if args[1] == nil then return end
	if !ply:Alive() then return end
	if ply:Team() != TEAM_PROP then return end
	local ta 	
	if (args[1] == 'rand') then
		ta, key = table.Random(Taunts)
		-- ta = ta[math.random(#ta)]
		ta = key
  elseif (args[1] == 'rand_long') then
    if table.Count(TauntLongest) > 0 then
	  	ta, key = table.Random(TauntLongest)
    else
		  ta, key = table.Random(Taunts)
    end
    ta = key
	else
		ta = args[1]
	end 
	-- print(ta)
	if (ply.TauntingLast or 0) > CurTime() then
		return
	end

	local snd = ta--t.sound[math.random(#t.sound)]
	
	if !Taunts[snd] then             
		return
	end
	
	local duration = Taunts[snd].length
	local cdn = Taunts[snd].cdn  
	
	ply:SetNWInt("LastTaunt", CurTime())
	ply:SetNWString("LastWav", snd)
  net.Start("TheInternetTaunt")  
		net.WriteEntity(ply)
    net.WriteString(cdn)
	net.Broadcast() 
	-- if GAMEMODE:GetRound( 1 ) then
		-- if limitPoints(ply, Taunts[snd].Rew) then   
			-- RewardPlayer( ply, Taunts[snd].Rew, "за проигрывание таунта" )
		-- end
	-- end
	ply.TauntingLast = CurTime() + (duration != 0 and duration or 1) + 0.1
	
end)
 
TTS.HTTP('/api/server/prophunt/taunts', {}, function(data) 
  TauntForClientside = {}     
  Taunts = {} 
  TauntLongest = {} 
 
  for _, taunt in pairs(data) do
    for category, snds in pairs(taunt.data) do
      for _, snd in pairs(snds) do 
        local id = taunt.slug .. '-' .. category .. '-' .. snd.id

        Taunts[id] = {
          cdn = taunt.cdn .. snd.s3,
          length = snd.length,
          name = snd.name,
          reward = 10 * math.Round( snd.length )
        }

        if snd.length > 6 then
          TauntLongest[id] = Taunts[id]
        end

        TauntForClientside[taunt.name] = TauntForClientside[taunt.name] or {}
        TauntForClientside[taunt.name][category] = TauntForClientside[taunt.name][category] or {}
        
        table.insert(TauntForClientside[taunt.name][category], {
          id = id,
          length = snd.length,
          name = snd.name,
        })
      end
    end
  end

  netstream.Heavy(ply, 'PH::SyncTaunts', TauntForClientside) 
end)

hook.Add('PlayerInitialSpawn', 'TauntsSync', function(ply)
  netstream.Heavy(ply, 'PH::SyncTaunts', TauntForClientside)
end)
