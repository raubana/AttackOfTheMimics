AddCSLuaFile()
AddCSLuaFile("util.lua")
AddCSLuaFile("math.lua")
AddCSLuaFile("perlin_noise.lua")
AddCSLuaFile("smooth_transition_object.lua")
AddCSLuaFile("sh_player_ext.lua")

include("util.lua")
include("math.lua")
include("perlin_noise.lua")
include("smooth_transition_object.lua")
include("sh_player_ext.lua")

include("camera_manager/shared.lua")


GM.Name				= "Attack of the Mimics"
GM.Author			= "raubana"
GM.TeamBased		= true


TEAM_SPEC = TEAM_SPECTATOR
TEAM_MECHANIC = 1
TEAM_MIMIC = 2

STAGE_WARMUP = 0
STAGE_READY = 1
STAGE_PREROUND = 2
STAGE_ROUND = 3
STAGE_POSTROUND = 4

function GM:CreateTeams()
	team.SetUp(TEAM_SPEC,"Spectator",Color(128,128,128),true)
	team.SetUp(TEAM_MECHANIC,"Mechanic",Color(64,255,255),false)
	team.SetUp(TEAM_MIMIC,"Mimic",Color(128,64,64),false)
end


function GM:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	local new_volume = math.min(math.pow(volume*2, 2), 1)
	
	if CLIENT then
		ply:EmitSound(sound, 75, 100, new_volume, CHAN_BODY)
	elseif SERVER then 
		hook.Call( "EntityEmitSound", nil, {
			SoundName = sound,
			OriginalSoundName = sound,
			SoundTime = 0,
			DSP = 0,
			SoundLevel = 75,
			Pitch = 100,
			Flags = 0,
			Channel = CHAN_BODY,
			Volume = new_volume,
			Entity = ply,
			Pos = ply:GetPos()
		} )
	end
	
	return true
end


function GM:DBToRadius( db, volume )
	return volume * (-(0.0003*math.pow(db, 4)) + (0.0766*math.pow(db, 3)) - (4.5372*math.pow(db, 2)) + (109.05*db) - 902.64)
end


print("shared ran")