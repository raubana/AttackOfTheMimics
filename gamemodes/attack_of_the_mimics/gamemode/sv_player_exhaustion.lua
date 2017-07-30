

hook.Add( "PlayerTick", "AOTM_PlayerTick_PlayerExhaustion", function(ply, mv)
	local t = ply:Team()

	if t != TEAM_SPEC and ply:Alive() then
		local old_nrg = ply:GetEnergy()
		local nrg = old_nrg
		
		if not isnumber(ply.last_updated_energy) then
			ply.last_updated_energy = CurTime() - engine.TickInterval()
		end
		
		local t_dif = CurTime() - ply.last_updated_energy
		
		ply.last_updated_energy = CurTime()
		
		if ply:IsOnGround() then
			if mv:KeyPressed(IN_JUMP) then
				nrg = nrg - 10
			end
			
			local speed = ply:GetVelocity():Length()
			if speed > 200 then
				nrg = nrg - 15.0*t_dif
			end
		end
		
		if nrg <= 0 then
			nrg = 0
			if not ply:GetIsTired() then
				ply:SetIsTired( true )
				ply.old_run_speed = ply:GetRunSpeed()
				ply.old_jump_power = ply:GetJumpPower()
				ply:SetRunSpeed(ply:GetWalkSpeed())
				ply:SetJumpPower(ply:GetJumpPower()/2)
			end
		end
		
		if nrg < 100 then
			nrg = nrg + 6*t_dif
			
			if ply:GetIsTired() and nrg >= 100 then
				ply:SetIsTired( false )
				ply:SetRunSpeed(ply.old_run_speed)
				ply:SetJumpPower(ply.old_jump_power)
			end
		end
		
		nrg = math.Clamp(nrg, 0, 100)
		
		if nrg != old_nrg then
			ply:SetEnergy(nrg)
		end
	end
end )

print("sv_player_exhaustion ran")