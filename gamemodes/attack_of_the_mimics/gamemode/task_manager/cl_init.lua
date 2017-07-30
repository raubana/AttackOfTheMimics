include("shared.lua")

AOTM_CLIENT_TASK_MANAGER = AOTM_CLIENT_TASK_MANAGER or {}
AOTM_CLIENT_TASK_MANAGER.tasks = AOTM_CLIENT_TASK_MANAGER.tasks or {}


net.Receive( "AOTM_BroadcastTasks", function( len, ply )
	AOTM_CLIENT_TASK_MANAGER.tasks = util.JSONToTable(net.ReadString())
	
	hook.Call( "AOTM_UpdateTasks" )
end )




print("task manager cl_init")