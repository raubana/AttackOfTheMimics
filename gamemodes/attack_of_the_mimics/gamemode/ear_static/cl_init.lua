include("shared.lua")

AOTM_CLIENT_EAR_STATIC = AOTM_CLIENT_EAR_STATIC or {}
AOTM_CLIENT_EAR_STATIC.sound = AOTM_CLIENT_EAR_STATIC.sound
AOTM_CLIENT_EAR_STATIC.__next_volume = AOTM_CLIENT_EAR_STATIC.__next_volume
AOTM_CLIENT_EAR_STATIC.__next_volume_update = AOTM_CLIENT_EAR_STATIC.__next_volume_update
AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY = 1.0


net.Receive( "AOTM_EarStatic_GrabAttention", function(len, ply)
	localplayer = LocalPlayer()
	
	if IsValid(localplayer) then
		local old_volume = AOTM_CLIENT_EAR_STATIC.__next_volume
	
		local perceived_loudness = net.ReadInt(EARSTATIC_GRABATTENTION_BITS)
		local pow = math.pow(2,EARSTATIC_GRABATTENTION_BITS-1)
		perceived_loudness = (perceived_loudness+pow)/(pow*2-1)
		
		AOTM_CLIENT_EAR_STATIC.__next_volume = math.Clamp(1-perceived_loudness, 0.0, AOTM_CLIENT_EAR_STATIC.__next_volume)
		
		if old_volume > AOTM_CLIENT_EAR_STATIC.__next_volume * 2 then
			AOTM_CLIENT_EAR_STATIC.__next_volume_update = RealTime()
		end
	end
end )


hook.Add( "Think", "AOTM_CLIENT_EAR_STATIC_Think", function()
	localplayer = LocalPlayer()
	
	if IsValid(localplayer) then
		local realtime = RealTime()
		if not AOTM_CLIENT_EAR_STATIC.sound then
			AOTM_CLIENT_EAR_STATIC.sound = CreateSound(localplayer, "ambient/voices/appartments_crowd_loop1.wav")
			AOTM_CLIENT_EAR_STATIC.sound:Play()
			AOTM_CLIENT_EAR_STATIC.sound:ChangePitch(0.0, 0.01)
			AOTM_CLIENT_EAR_STATIC.sound:ChangePitch(0, 0.01)
			
			AOTM_CLIENT_EAR_STATIC.__next_volume = 0.9
			AOTM_CLIENT_EAR_STATIC.__next_volume_update = realtime+AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY
		else
			if not AOTM_CLIENT_EAR_STATIC.__next_volume_update then
				-- Happened once, not sure why.
				AOTM_CLIENT_EAR_STATIC.__next_volume_update = realtime+AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY
			end
			
			if not AOTM_CLIENT_EAR_STATIC.__next_volume then
				-- Happened once also, also not sure why.
				AOTM_CLIENT_EAR_STATIC.__next_volume = 1.0
			end
			
			if realtime >= AOTM_CLIENT_EAR_STATIC.__next_volume_update then
				AOTM_CLIENT_EAR_STATIC.sound:ChangeVolume(math.Clamp(Lerp(AOTM_CLIENT_EAR_STATIC.__next_volume, -1, 1)*0.2,0,1), AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY)
				
				local pitch = Lerp((math.sin(realtime*0.1)+1)/2, 6, 12)
				AOTM_CLIENT_EAR_STATIC.sound:ChangePitch(pitch, AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY)
				
				AOTM_CLIENT_EAR_STATIC.__next_volume_update = realtime+AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY
				AOTM_CLIENT_EAR_STATIC.__next_volume = math.min(AOTM_CLIENT_EAR_STATIC.__next_volume+(AOTM_CLIENT_EAR_STATIC.UPDATE_DELAY*0.005), 1.0)
			end
		end
	end
end )

print("ear static cl_init")