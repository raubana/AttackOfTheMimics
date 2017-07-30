include("shared.lua")

hook.Add( "PlayerStartVoice", "AOTM_PlayerStartVoice_MimicChatter", function(ply)
	if ply != LocalPlayer() then return end
	net.Start("AOTM_StartTalking")
	net.SendToServer()
end )


hook.Add( "PlayerEndVoice", "AOTM_PlayerEndVoice_MimicChatter", function(ply)
	if ply != LocalPlayer() then return end
	net.Start("AOTM_StopTalking")
	net.SendToServer()
end )


print("mimicchatter manager cl_init")