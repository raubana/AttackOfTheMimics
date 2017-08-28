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
	if ply:Team() == TEAM_MIMIC and ply:IsOnGround() and ply:GetIsHiding() then return true end
end


print("shared ran")