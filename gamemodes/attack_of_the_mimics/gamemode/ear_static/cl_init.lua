include("shared.lua")

--[[
AOTM_CLIENT_EAR_STATIC = AOTM_CLIENT_EAR_STATIC or {}
AOTM_CLIENT_EAR_STATIC.sound = AOTM_CLIENT_EAR_STATIC.sound
AOTM_CLIENT_EAR_STATIC.sound_ready = AOTM_CLIENT_EAR_STATIC.sound_ready or false


if not AOTM_CLIENT_EAR_STATIC.sound then
	sound.PlayFile(
		"sound/attack_of_the_mimics/misc/ear_static_loop.wav",
		"",
		function(soundchannel, errorID, errorName)
			print(soundchannel, errorID, errorName)
			
			AOTM_CLIENT_EAR_STATIC.sound = soundchannel
			AOTM_CLIENT_EAR_STATIC.sound_ready = true
		end
	)
end
]]

print("ear static cl_init")