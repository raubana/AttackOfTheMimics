AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_TASK_MANAGER = AOTM_SERVER_TASK_MANAGER or {}
AOTM_SERVER_TASK_MANAGER.tasks = AOTM_SERVER_TASK_MANAGER.tasks or {}


hook.Add( "Initialize", "AOTM_Initialize_TaskManager", function( )
	util.AddNetworkString("AOTM_BroadcastTasks")
end )


function AOTM_SERVER_TASK_MANAGER:AddTask( ent )
	table.insert(self.tasks, ent)
	
	print("ADD TASK", ent)
end


function AOTM_SERVER_TASK_MANAGER:GenerateTaskMessage()
	local message = {}
	for i, ent in ipairs(self.tasks) do
		local task_data = {}
		task_data.description = ent.description
		task_data.completed = ent.completed
	
		table.insert(message, task_data )
	end
	
	return message
end


function AOTM_SERVER_TASK_MANAGER:BroadcastTasks()
	local message = self:GenerateTaskMessage()

	net.Start("AOTM_BroadcastTasks")
	net.WriteString(util.TableToJSON(message))
	net.Broadcast()
	
	print("BROADCAST")
end


function AOTM_SERVER_TASK_MANAGER:SendTasks( ply )
	local message = self:GenerateTaskMessage()

	net.Start("AOTM_BroadcastTasks")
	net.WriteString(util.TableToJSON(message))
	net.Send( ply )
end


hook.Add( "PlayerInitialSpawn", "AOTM_PlayerInitialSpawn_TaskManager", function( ply )
	AOTM_SERVER_TASK_MANAGER:SendTasks( ply )
end )


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_TaskManager", function( old_stage, new_stage )
	if new_stage == STAGE_ROUND then
		util.ShuffleTable(AOTM_SERVER_TASK_MANAGER.tasks)
		AOTM_SERVER_TASK_MANAGER:BroadcastTasks()
	end
	
	if old_stage == STAGE_POSTROUND then
		AOTM_SERVER_TASK_MANAGER.tasks = {}
		AOTM_SERVER_TASK_MANAGER:BroadcastTasks()
	end
end )


print("task manager init")