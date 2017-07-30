AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_IDBADGE_MANAGER = AOTM_SERVER_IDBADGE_MANAGER or {}
AOTM_SERVER_IDBADGE_MANAGER.badges = AOTM_SERVER_IDBADGE_MANAGER.badges or {}


function AOTM_SERVER_IDBADGE_MANAGER:AddBadge( ply, badge )
	AOTM_SERVER_IDBADGE_MANAGER.badges[ply:SteamID64()] = badge
end

function AOTM_SERVER_IDBADGE_MANAGER:GetBadge( ply )
	return AOTM_SERVER_IDBADGE_MANAGER.badges[ply:SteamID64()]
end

function AOTM_SERVER_IDBADGE_MANAGER:RemoveBadge( ply )
	AOTM_SERVER_IDBADGE_MANAGER.badges[ply:SteamID64()] = nil
end


print("idbadge manager init")