
local PREROUND_DELAY = CreateConVar("aotm_preround_delay", "30", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)
local POSTROUND_DELAY = CreateConVar("aotm_postround_delay", "10", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)

local MIN_PLAYERS = CreateConVar("aotm_min_players", "2", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)
local MAX_PLAYERS = CreateConVar("aotm_max_players", "8", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)
local MIMIC2MECHANIC_RATIO = CreateConVar("aotm_mimic_to_mechanic_ratio", "0.666", FCVAR_ARCHIVE+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)

local DEBUG_SINGLEPLAYER = CreateConVar("aotm_debug_singleplayer", "0", FCVAR_CHEAT+FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY)


function GM:Initialize()
	util.AddNetworkString("AOTM_SetWantsToPlay")

	self.stage = STAGE_WARMUP
	self.stage_starttime = 0
	self.stage_duration = -1
	
	self:SetStage(STAGE_WARMUP)
end


function GM:SetStage(stage)
	if stage != self.stage then
		local old_stage = self.stage
		
		self.stage_starttime = CurTime()
		self.stage = stage
		
		if stage == STAGE_WARMUP then
			self.stage_duration = -1
		elseif stage == STAGE_READY then
			self.stage_duration = math.max(PREROUND_DELAY:GetFloat(), 1.0)
		elseif stage == STAGE_PREROUND then
			self.stage_duration = 12
			if GetConVar("aotm_debug_skiplogo"):GetBool() then
				self.stage_duration = 2
			end
		elseif stage == STAGE_ROUND then
			self.stage_duration = -1
		elseif stage == STAGE_POSTROUND then
			self.stage_duration = math.max(POSTROUND_DELAY:GetFloat(), 1.0)
		end
		
		SetGlobalInt("stage", stage)
		SetGlobalFloat("stage_starttime", self.stage_starttime)
		SetGlobalFloat("stage_duration", self.stage_duration)
		
		self:OnStageChange(old_stage, stage)
	end
end


function GM:OnStageChange( old_stage, new_stage )
	hook.Call( "AOTM_PreStageChange", nil, old_stage, new_stage )
	
	if new_stage == STAGE_PREROUND then
		game.CleanUpMap()
		
		hook.Call( "AOTM_PreNewRoundStart", nil)
	
		local ply_list = player.GetAll()
		
		for i, ply in ipairs(ply_list) do
			if ply:Team() != TEAM_SPEC then
				ply:Spawn()
			end
		end
	elseif old_stage == STAGE_POSTROUND and new_stage == STAGE_WARMUP then
		local ply_list = player.GetAll()
		for i, ply in ipairs(ply_list) do
			if ply:Team() != TEAM_SPEC then
				ply:KillSilent()
			end
		end
		
		self:CheckGameState()
	end

	hook.Call( "AOTM_PostStageChange", nil, old_stage, new_stage )
end


function GM:Tick()
	local curtime = CurTime()
	local stage_length = curtime - self.stage_starttime 
	
	if self.stage_duration > 0 and stage_length >= self.stage_duration then
		hook.Call( "AOTM_OnStageTimeUp", nil )
		
		if self.stage == STAGE_READY then
			-- we pick out the player's who want to play.
			local ply_list = player.GetAll()
			local i = #ply_list
			while i > 0 do
				if not ply_list[i].wants_to_play then
					table.remove(ply_list, i)
				end
				i = i - 1
			end
			
			local play_score_list = {}
			
			for i, ply in ipairs(ply_list) do
				table.insert(play_score_list, self:ScorePlayerToPlay(ply))
			end
			
			-- we use roulette selection to pick players to play.
			-- this will favor players who haven't played in a while.
			
			local players_to_play = {}
			local mechanic_score_list = {}
			local mimic_score_list = {}
			
			local i = math.min(#ply_list, MAX_PLAYERS:GetInt())
			while i > 0 do
				local winning_index = util.RouletteSelect(play_score_list)
				
				table.remove(play_score_list, winning_index)
				
				local ply = table.remove(ply_list, winning_index)
				
				table.insert(players_to_play, ply)
				table.insert(mechanic_score_list, self:ScorePlayerToBeMechanic(ply))
				table.insert(mimic_score_list, self:ScorePlayerToBeMimic(ply))
				
				i = i - 1
			end
			
			-- of these players that were picked to play, we need to decide
			-- which of them will be on what team. We create a random team
			-- selection order and use that to decide which team will get
			-- to pick a player, each time using roulette selection to
			-- pick from the remaining players.
			
			local p = math.Clamp(MIMIC2MECHANIC_RATIO:GetFloat(),0,1)
			
			local mimic_count = math.ceil(p*#players_to_play)
			local mechanic_count = #players_to_play - mimic_count --math.ceil((1-p)*#players_to_play)
			
			print("PICKING", #players_to_play, mimic_count, mechanic_count)
			
			local pick_order = {}
			for i = 1, mimic_count do table.insert(pick_order, TEAM_MIMIC) end
			for i = 1, mechanic_count do table.insert(pick_order, TEAM_MECHANIC) end
			
			util.ShuffleTable(pick_order)
			
			for i, team_pick in ipairs(pick_order) do
				if #players_to_play > 0 then -- just in case.
					local score_list
					if team_pick == TEAM_MIMIC then
						score_list = mimic_score_list
					else
						score_list = mechanic_score_list
					end
					
					local winning_index = util.RouletteSelect(score_list)
					
					local ply = table.remove(players_to_play, winning_index)
					table.remove(mimic_score_list, winning_index)
					table.remove(mechanic_score_list, winning_index)
					
					ply:SetTeam(team_pick)
				end
			end
			
			self:SetStage(STAGE_PREROUND)
		elseif self.stage == STAGE_PREROUND then
			self:SetStage(STAGE_ROUND)
		elseif self.stage == STAGE_POSTROUND then
			-- TODO
			self:SetStage(STAGE_WARMUP)
		end
		
	end
end




function GM:CheckGameState()
	if self.stage == STAGE_WARMUP then
		-- we need to check if enough players are ready to play.
		local ply_list = player.GetAll()
		local num_players_who_want_to_play = 0
		
		for i, ply in ipairs(ply_list) do
			if ply.wants_to_play then
				num_players_who_want_to_play = num_players_who_want_to_play + 1
			end
		end
		
		if num_players_who_want_to_play >= MIN_PLAYERS:GetInt() then
			self:SetStage(STAGE_READY)
			PrintMessage(HUD_PRINTCENTER, "Ready. Round will start in "..tostring(self.stage_duration).." seconds.")
		end
	elseif self.stage == STAGE_READY then
		-- we need to check that enough players are still ready to play.
		local ply_list = player.GetAll()
		local num_players_who_want_to_play = 0
		
		for i, ply in ipairs(ply_list) do
			if ply.wants_to_play then
				num_players_who_want_to_play = num_players_who_want_to_play + 1
			end
		end
		
		if num_players_who_want_to_play < MIN_PLAYERS:GetInt() then
			PrintMessage(HUD_PRINTCENTER, "Not enough ready players.")
			self:SetStage(STAGE_WARMUP)
		end
	elseif self.stage == STAGE_PREROUND or self.stage == STAGE_ROUND then
		-- we need to check if a team has won.
		local mechanics = team.GetPlayers(TEAM_MECHANIC)
		local mimics = team.GetPlayers(TEAM_MIMIC)
		
		local debug_singleplayer = DEBUG_SINGLEPLAYER:GetBool()
		
		if #mechanics == 0 and not debug_singleplayer then
			-- all of the mechanics have died, the mimics win.
			PrintMessage(HUD_PRINTCENTER, "Mimics win.")
			self:SetStage(STAGE_POSTROUND)
		elseif #mimics == 0 and not debug_singleplayer then
			-- all of the mimics have died, the mechanics win.
			PrintMessage(HUD_PRINTCENTER, "Mechanics win (by default).")
			self:SetStage(STAGE_POSTROUND)
		elseif #AOTM_SERVER_TASK_MANAGER.tasks > 0 then
			local completed_tasks = 0
			for i, task_ent in ipairs(AOTM_SERVER_TASK_MANAGER.tasks) do
				if task_ent.completed then
					completed_tasks = completed_tasks + 1
				end
			end
			
			if completed_tasks >= #AOTM_SERVER_TASK_MANAGER.tasks then
				-- all of the tasks have been completed, the mechanics win.
				PrintMessage(HUD_PRINTCENTER, "Mechanics win.")
				self:SetStage(STAGE_POSTROUND)
			end
		end
	end
end

