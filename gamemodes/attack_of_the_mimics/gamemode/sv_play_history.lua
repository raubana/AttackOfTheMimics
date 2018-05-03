local AUTOSAVE_DELAY = CreateConVar("aotm_play_history_autosave_delay", "600", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)
local AUTODELETE_DELAY = CreateConVar("aotm_play_history_autodelete_delay", "259200", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)

local history_filename = "aotm_play_history.txt"


function GM:LoadPlayHistory()
	local str = file.Read(history_filename)
	
	if not str then
		GAMEMODE.play_history = {} 
	else
		GAMEMODE.play_history = util.JSONToTable(str)
		if not GAMEMODE.play_history then
			GAMEMODE.play_history = {}
		end
	end
end


function GM:SavePlayHistory()
	for _, ply in ipairs(player.GetAll()) do
		if ply:Team() != SPEC then
			if ply:Team() != TEAM_MIMIC then
				GAMEMODE.play_history[ply:SteamID()].rounds_without_mimic = GAMEMODE.play_history[ply:SteamID()].rounds_without_mimic + 1
			end
			
			if ply:Team() != TEAM_MECHANIC then
				GAMEMODE.play_history[ply:SteamID()].rounds_without_mechanic = GAMEMODE.play_history[ply:SteamID()].rounds_without_mechanic + 1
			end
		else
			if ply.wants_to_play then
				GAMEMODE.play_history[ply:SteamID()].rounds_without_play = GAMEMODE.play_history[ply:SteamID()].rounds_without_play + 1
			end
		end
	end
	file.Write(history_filename, util.TableToJSON(GAMEMODE.play_history))
	print("Saved play history")
end


function GM:ScorePlayerToPlay( ply )
	local play_info = GAMEMODE.play_history[ply:SteamID()]
	if not play_info then return 1.0 end
	return play_info.rounds_without_play + 1
end


function GM:ScorePlayerToBeMechanic( ply )
	local play_info = GAMEMODE.play_history[ply:SteamID()]
	if not play_info then return 1.0 end
	return play_info.rounds_without_mechanic + 1
end


function GM:ScorePlayerToBeMimic( ply )
	local play_info = GAMEMODE.play_history[ply:SteamID()]
	if not play_info then return 1.0 end
	return play_info.rounds_without_mimic + 1
end


hook.Add( "Initialize", "AOTM_Initialize_PlayHistory", function()
	GAMEMODE:LoadPlayHistory()
end )


local next_save = -1
local saved_this_round = true
hook.Add( "Tick", "AOTM_Tick_PlayHistory", function()
	local curtime = CurTime()
	
	if next_save > 0 and curtime >= next_save then
		next_save = -1
		
		if not saved_this_round then
			saved_this_round = true
			
			local time = os.time()
			local ply_list = player.GetAll()
			
			for key, play_info in pairs(GAMEMODE.play_history) do
				if time - play_info.last_on_server > math.max(AUTODELETE_DELAY:GetFloat(), 60*60) then -- we keep their info for at least an hour before deleting it.
					GAMEMODE.play_history[key] = nil
				end
			end
			
			for i, ply in ipairs(ply_list) do
				local play_info = GAMEMODE.play_history[ply:SteamID()]
				
				if not play_info then
					play_info = {}
					play_info.last_on_server = time
					play_info.rounds_without_play = 3
					play_info.rounds_without_mechanic = 3
					play_info.rounds_without_mimic = 3
				end
				
				if ply.wants_to_play then
					local t = ply:Team()
				
					if t == TEAM_SPEC then
						play_info.rounds_without_play = play_info.rounds_without_play + 1
					else
						play_info.rounds_without_play = 0
						if t == TEAM_MECHANIC then
							play_info.rounds_without_mechanic = 0
						elseif t == TEAM_MIMIC then
							play_info.rounds_without_mimic = 0
						end
					end
				end
				
				play_info.last_on_server = time
				
				GAMEMODE.play_history[ply:SteamID()] = play_info
			end
			
			GAMEMODE:SavePlayHistory()
		end
	end
end )


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_PlayHistory", function(old_stage, new_stage)
	if new_stage == STAGE_ROUND then
		next_save = CurTime() + math.max(AUTOSAVE_DELAY:GetFloat(), 0)
		saved_this_round = false
	elseif new_stage == STAGE_POSTROUND then
		next_save = CurTime()
	elseif new_stage == STAGE_PREROUND then
		saved_this_round = true
	end
end )