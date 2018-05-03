AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_EAR_STATIC = AOTM_SERVER_EAR_STATIC or {}


hook.Add( "Initialize", "AOTM_Initialize_EarStatic", function( )
	util.AddNetworkString("AOTM_EarStatic_GrabAttention")
end )


-- I'll need to remove all soundscapes anyways.
hook.Add( "InitPostEntity", "AOTM_EarStatic_InitPostEntity", function()
	local ent_list = ents.FindByClass("env_soundscape")
	table.Add(ent_list, ents.FindByClass("env_soundscape_triggerable"))
	
	for i, ent in ipairs(ent_list) do
		SafeRemoveEntity(ent)
	end
end )


hook.Add( "EntityEmitSound", "AOTM_EarStatic_EntityEmitSound", function(data)
	local audible_radius = GAMEMODE:DBToRadius(data.SoundLevel, data.Volume)
	local sound_pos = data.Pos
	
	if not sound_pos and IsValid(data.Entity) then
		sound_pos = data.Entity:GetPos()
	end
	
	if sound_pos then
		local ply_list = player.GetAll()
		for i, ply in ipairs(ply_list) do
			local dist = ply:EyePos():Distance(sound_pos)
			
			if dist < audible_radius then
				-- the following variable doesn't store the actual loudness.
				local perceived_loudness
				if dist > EARSTATIC_GRABATTENTION_DROPOFF then
					perceived_loudness = math.InvLerp( dist, audible_radius, EARSTATIC_GRABATTENTION_DROPOFF )
					perceived_loudness = 1-perceived_loudness
					perceived_loudness = 1-math.pow(perceived_loudness, 3)
				elseif dist > EARSTATIC_GRABATTENTION_DEADZONE then
					perceived_loudness = math.InvLerp( dist, EARSTATIC_GRABATTENTION_DEADZONE, EARSTATIC_GRABATTENTION_DROPOFF )
				else
					perceived_loudness = 0 --math.pow(dist/EARSTATIC_GRABATTENTION_DEADZONE, 3)
				end
				
				
				if perceived_loudness > 0 then
					perceived_loudness = math.pow(math.Clamp(perceived_loudness,0,1),2)
					
					local pow = math.pow(2,EARSTATIC_GRABATTENTION_BITS-1)
					local attention_grabbed = math.Round(Lerp(perceived_loudness,-pow,pow-1))
					
					net.Start("AOTM_EarStatic_GrabAttention")
					net.WriteInt(attention_grabbed, EARSTATIC_GRABATTENTION_BITS)
					net.Send(ply)
				end
			end
		end
	end
end )


print("ear static init")