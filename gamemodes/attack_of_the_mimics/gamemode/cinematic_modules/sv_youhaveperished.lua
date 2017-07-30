
hook.Add( "Initialize", "AOTM_Initialize_YouHavePerished", function( )
	util.AddNetworkString("AOTM_YouHavePerished")
end )


hook.Add( "PlayerDeath", "AOTM_PlayerDeath_YouHavePerished", function( ply, inflictor, attacker )
	local stage = GetGlobalInt("stage")
	if stage == STAGE_PREROUND or stage == STAGE_ROUND then
		net.Start("AOTM_YouHavePerished")
		net.Send(ply)
	end
end )


print("sv_credits ran")