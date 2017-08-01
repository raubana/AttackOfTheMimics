include("shared.lua")

AOTM_CLIENT_MUSIC_MANAGER = AOTM_CLIENT_MUSIC_MANAGER or {}
AOTM_CLIENT_MUSIC_MANAGER.active_songs = AOTM_CLIENT_MUSIC_MANAGER.active_songs or {}

AOTM_CLIENT_MUSIC_MANAGER.VOLUME = 1.0


function AOTM_CLIENT_MUSIC_MANAGER:GetMatch( song_name )
	local i = 1
	while i <= #self.active_songs do
		if self.active_songs[i].name == song_name then return i end
		i = i + 1
	end
	return -1
end


function AOTM_CLIENT_MUSIC_MANAGER:PlayStinger( song_name, volume )
	local new_song = {}
	new_song.name = song_name
	new_song.volume = volume
	new_song.actual_volume = 1.0
	new_song.sound = nil
	new_song.start_time = -1
	new_song.length = -1
	new_song.is_stinger = true
	
	print("CREATING NEW STINGER: ", song_name)
	
	table.insert(AOTM_CLIENT_MUSIC_MANAGER.active_songs, new_song)
	
	
	sound.PlayFile(
		"sound/"..song_name,
		"",
		function(soundchannel, errorID, errorName)
			print(soundchannel, errorID, errorName)
			
			new_song.sound = soundchannel
			new_song.start_time = RealTime()
			if soundchannel then
				soundchannel:SetVolume(0.0)
				new_song.length = soundchannel:GetLength()
			else
				new_song.length = 0.0
			end
			print("STINGER PLAYING: ", song_name)
		end
	)
end


function AOTM_CLIENT_MUSIC_MANAGER:StartSong( song_name, volume, priority, loop )
	print("Asked to play", song_name)

	-- first we check if the song is already playing.
	local match_index = self:GetMatch(song_name)
	
	-- if there is a match, we stop it from fading out and return.
	if match_index > 0 then
		local match = self.active_songs[match_index]
		match.fading_out = false
		return
	end
	
	-- there was no match, so we create the new song instance.
	local new_song = {}
	new_song.name = song_name
	new_song.volume = volume
	new_song.actual_volume = 1.0
	new_song.priority = priority
	new_song.sound = nil
	new_song.looping = loop
	new_song.start_time = -1
	new_song.length = -1
	new_song.fading_out = false
	new_song.fade_out_start = 0
	new_song.fade_out_length = 0
	
	print("CREATING NEW SONG: ", song_name)
	
	table.insert(AOTM_CLIENT_MUSIC_MANAGER.active_songs, new_song)
	
	local flags = ""
	if loop then
		flags = "noblock"
	end
	
	sound.PlayFile(
		"sound/"..song_name,
		flags,
		function(soundchannel, errorID, errorName)
			print(soundchannel, errorID, errorName)
			
			new_song.sound = soundchannel
			new_song.start_time = RealTime()
			if soundchannel then
				if loop then
					soundchannel:EnableLooping(true)
				end
				new_song.length = soundchannel:GetLength()
			else
				new_song.length = 0.0
			end
			print("SONG PLAYING: ", song_name)
		end
	)
end


function AOTM_CLIENT_MUSIC_MANAGER:StopAllSongs()
	for i, song in ipairs(self.active_songs) do
		if song.sound then
			song.sound:Stop()
		end
	end
	self.active_songs = {}
	print("KILLED ALL ACTIVE SONGS")
end


function AOTM_CLIENT_MUSIC_MANAGER:StopSong( song_name, fade_out_length )
	local match_index = self:GetMatch(song_name)
	
	if match_index > 0 then
		local match = self.active_songs[match_index]
		if not match.fading_out then
			match.fading_out = true
			match.fade_out_start = RealTime()
			match.fade_out_length = fade_out_length
		end
	end
end


hook.Add( "Tick", "AOTM_Tick_MusicManager_ClInit", function()
	local realtime = RealTime()
	
	local i = #AOTM_CLIENT_MUSIC_MANAGER.active_songs
	while i > 0  do
		local song = AOTM_CLIENT_MUSIC_MANAGER.active_songs[i]

		if song.start_time > 0 then
			local play_duration = realtime - song.start_time
			if (not song.looping and play_duration > song.length) or
			(not song.is_stinger and song.fading_out and realtime > song.fade_out_start + song.fade_out_length) then
				if song.sound then
					song.sound:Stop()
				end
				table.remove(AOTM_CLIENT_MUSIC_MANAGER.active_songs, i)
				print("KILLED SONG: ", song.name)
			end
		end
		
		i = i - 1
	end
	
	local top_priority_song = nil
	local top_priority = 0
	local top_priority_volume = 1.0
	
	for i, song in ipairs(AOTM_CLIENT_MUSIC_MANAGER.active_songs) do
		if not song.is_stinger and song.priority > top_priority then
			top_priority_song = song
			top_priority = song.priority
		end
		
		song.actual_volume = 1.0
		
		if song.is_stinger then
			-- do nothing
		elseif song.fading_out then
			local p = (realtime-song.fade_out_start)/song.fade_out_length
			song.actual_volume = song.actual_volume * Lerp(p, 1.0, 0.0)
		end
	end
	
	if top_priority_song then
		top_priority_volume = top_priority_song.actual_volume
	
		for i, song in ipairs(AOTM_CLIENT_MUSIC_MANAGER.active_songs) do
			if song != top_priority_song then
				if song.sound and not song.is_stinger then
					song.actual_volume = song.actual_volume * (1-top_priority_volume)
				end
			end
		end
	end
	
	for i, song in ipairs(AOTM_CLIENT_MUSIC_MANAGER.active_songs) do
		if song.sound then
			song.sound:SetVolume(song.actual_volume*song.volume*AOTM_CLIENT_MUSIC_MANAGER.VOLUME)
		end
	end
end )


print("music manager cl_init")