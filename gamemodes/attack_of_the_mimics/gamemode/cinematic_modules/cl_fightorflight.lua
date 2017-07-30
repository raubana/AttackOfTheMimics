
local was_in_dark = was_in_dark or false
local is_in_dark = is_in_dark or false
local fof_active = fof_active or false
local fof_end_at = fof_end_at or 0
local last_stinger = last_stinger or 0


net.Receive( "AOTM_FightOrFlight", function(len, ply)
	print("fight or flight", fof_active, is_in_dark)
	
	local curtime = CurTime()
	
	if curtime - last_stinger > 10.0 then
		AOTM_CLIENT_MUSIC_MANAGER:PlayStinger("attack_of_the_mimics/music/fof_stingers/fof_stinger_"..tostring(math.random(1,7))..".wav", 1.0)
	end
	last_stinger = curtime
	
	
	if not fof_active then
		fof_active = true
		if is_in_dark then
			AOTM_CLIENT_MUSIC_MANAGER:StartSong( "attack_of_the_mimics/music/fightorflight_quiet.mp3", 0.5, 3, true )
		else
			AOTM_CLIENT_MUSIC_MANAGER:StartSong( "attack_of_the_mimics/music/fightorflight_loud.mp3", 0.5, 3, true )
		end
	end

	fof_end_at = curtime + 30
end )


net.Receive( "AOTM_FightOrFlightReset", function(len, ply)
	print("fight or flight reset")
	
	fof_end_at = 0
end )


local next_update = 0

hook.Add( "Tick", "AOTM_Tick_FightOrFlight_ClInit", function()
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) then return end
	
	local t = localplayer:Team()
	if t == TEAM_SPEC then return end
	
	local curtime = CurTime()
	
	if fof_active and curtime > fof_end_at then
		print("turning of fof")
		fof_active = false
		AOTM_CLIENT_MUSIC_MANAGER:StopSong( "attack_of_the_mimics/music/fightorflight_loud.mp3", 10 )
		AOTM_CLIENT_MUSIC_MANAGER:StopSong( "attack_of_the_mimics/music/fightorflight_quiet.mp3", 10 )
	end
	
	if curtime >= next_update then 
		
		next_update = curtime + 1.0

		local r = 0.0
		local g = 0.0
		local b = 0.0
		
		
		local pos = localplayer:EyePos()
		
		for x = -1, 1 do
			for y = -1, 1 do
				for z = -1, 1 do
					if not (x == 0 and y == 0 and z == 0) then
						local vec = Vector(x,y,z)
						vec:Normalize()
						
						local dyn_light = render.ComputeDynamicLighting(pos, vec)
						local light = render.ComputeLighting(pos, vec)
						
						light = light - dyn_light
						
						r = math.max( r, light.x )
						g = math.max( g, light.y )
						b = math.max( b, light.z )
					end
				end
			end
		end
		
		
		-- TODO: ???
		
		
		local brightness = math.max( r, g, b )
		is_in_dark = brightness < 0.01
		was_in_dark = is_in_dark
	end
end )



print("cl_fightorflight ran")