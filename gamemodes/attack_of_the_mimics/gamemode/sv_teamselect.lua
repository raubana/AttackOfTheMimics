
net.Receive( "AOTM_SetWantsToPlay", function( len, ply )
	local wants_to_play = net.ReadBool()
	if ply.wants_to_play != wants_to_play then
		ply.wants_to_play = wants_to_play
		GAMEMODE:CheckGameState()
	end
end )