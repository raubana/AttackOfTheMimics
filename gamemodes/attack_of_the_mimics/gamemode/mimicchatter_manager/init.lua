AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_MIMICCHATTER_MANAGER = AOTM_SERVER_MIMICCHATTER_MANAGER or {}
AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers = AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers or {}

local CHATTER_SOUNDS = {
	Sound("npc/headcrab_poison/ph_warning1.wav"),
	Sound("npc/headcrab_poison/ph_warning2.wav"),
	Sound("npc/headcrab_poison/ph_warning3.wav"),
}


hook.Add( "Initialize", "AOTM_Initialize_MimicChatter_Init", function()
	util.AddNetworkString("AOTM_StartTalking")
	util.AddNetworkString("AOTM_StopTalking")
end )


net.Receive( "AOTM_StartTalking", function(len, ply)
	if not table.HasValue(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, ply) then
		table.insert(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, ply)
	end
end )


net.Receive( "AOTM_StopTalking", function(len, ply)
	table.RemoveByValue(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, ply)
end )


hook.Add( "PlayerDisconnected", "AOTM_PlayerDisconnected_MimicChatter_Init", function(ply)
	table.RemoveByValue(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, ply)
end )


hook.Add( "Tick", "AOTM_Tick_MimicChatter_Init", function()
	for i, ply in ipairs(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers) do
		if IsValid(ply) and ply:Team() == TEAM_MIMIC then
			local curtime = CurTime()
			
			if not ply.next_chatter then
				ply.next_chatter = 0
			end
			
			if curtime >= ply.next_chatter then
				hook.Call( "AOTM_MimicChatter", nil, ply:GetPos() )
				
				local snd = CHATTER_SOUNDS[math.random(#CHATTER_SOUNDS)]
				print( snd )
				ply:EmitSound(snd, 85, Lerp(math.random(), 90, 110), 0.1)
				ply.next_chatter = curtime + 1.25
			end
		end
	end
end )

print("mimicchatter manager init")