local DEBUG_SKIPLOGO = CreateConVar("aotm_debug_skiplogo", "0", FCVAR_SERVER_CAN_EXECUTE+FCVAR_NOTIFY+FCVAR_ARCHIVE)


hook.Add( "Initialize", "AOTM_Initialize_IntroLogo", function( )
	util.AddNetworkString("AOTM_RunIntroLogo")
end )


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_IntroLogo", function( old_stage, new_stage )
	print( old_stage, new_stage )
	
	if DEBUG_SKIPLOGO:GetBool() then return end

	if new_stage == STAGE_PREROUND then
		print("sent start logo")
		net.Start("AOTM_RunIntroLogo")
		net.Broadcast()
	end
end )


print("sv_intro_logo ran")