

hook.Add( "Initialize", "AOTM_Initialize_FightOrFlight_Init", function( )
	util.AddNetworkString("AOTM_FightOrFlight")
	util.AddNetworkString("AOTM_FightOrFlightReset")
end )


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_FightOrFlight_Init", function( old_stage, new_stage )
	if new_stage == STAGE_POSTROUND then
		net.Start("AOTM_FightOrFlightReset")
		net.Broadcast()
	end
end )


hook.Add( "PlayerHurt", "AOTM_PlayerHurt_FightOrFlight_Init", function( victim, attacker, healthRemaining, damageTaken )
	if IsValid(victim) and IsValid(attacker) and victim:IsPlayer() and attacker:IsPlayer() and victim:Team() != attacker:Team() then
		if healthRemaining > 0 then
			net.Start("AOTM_FightOrFlight")
			net.Send(victim)
		else
			net.Start("AOTM_FightOrFlightReset")
			net.Send(victim)
		end
		
		net.Start("AOTM_FightOrFlight")
		net.Send(attacker)
	end
end )


print("sv_intro_logo ran")