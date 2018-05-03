AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


local MODE_ENABLED = CreateConVar(	"aotm_mode_echolocation", 
									"1", 
									FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY+FCVAR_ARCHIVE+FCVAR_REPLICATED,
									"Only takes effect when a new round starts.")

local RADIUS_SCALE = 0.75

-- because convar replication is apparently broken, we have to instead use a
-- global variable.
hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_ModeEcholocation", function( old_stage, new_stage )
	if new_stage == STAGE_PREROUND then
		SetGlobalBool("aotm_mode_echolocation", MODE_ENABLED:GetBool(false))
	end
end )


hook.Add( "Initialize", "AOTM_Initialize_ModeEcholocation", function()
	util.AddNetworkString( "AOTM_SoundEmitted" )
end )


local function transmitSound( pos, abs_radius, ring_thickness, wave_thickness, break_scale, hue, sat )
	if not MODE_ENABLED:GetBool(false) then return end

	local radius = radius
	
	net.Start("AOTM_SoundEmitted")
	net.WriteVector(pos)
	net.WriteInt(abs_radius, ECHO_RADIUS_BITS)
	net.WriteInt(ring_thickness, ECHO_THICK_BITS)
	net.WriteInt(wave_thickness, ECHO_THICK_BITS)
	net.WriteFloat(break_scale)
	net.WriteInt(hue, ECHO_HUE_BITS)
	net.WriteInt(sat*100.0, ECHO_SAT_BITS)
	net.Broadcast()
end


hook.Add( "AOTM_MimicChatter", "AOTM_MimicChatter_ModeEcholocation", function(pos)
	transmitSound(pos, GAMEMODE:DBToRadius(85,0.25)*RADIUS_SCALE, 10, 250, 50/2, 240, 0.0)
end )


hook.Add( "AOTM_MimicScream", "AOTM_MimicScream_ModeEcholocation", function(pos)
	transmitSound(pos, GAMEMODE:DBToRadius(95,1.0)*RADIUS_SCALE, 190, 1500, 5.0, 0, 1.0)
end )


print("mode echolocation init")