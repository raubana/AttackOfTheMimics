

local SCALE = 2.0
local PLAYER_TIRED_THRESHOLD = 0
local PLAYER_UNTIRED_THRESHOLD = 50



hook.Add( "PlayerTick", "AOTM_PlayerExhaustion_PlayerTick", function(ply, mv)
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
			local speed = ply:GetVelocity():Length()
			if speed > 25 then
				nrg = nrg - t_dif*((speed+1.0)*0.025*SCALE)
			end
			
			if mv:KeyPressed(IN_JUMP) then
				nrg = nrg - (10 + (speed/30.0))
			end
		end
		
		if nrg <= PLAYER_TIRED_THRESHOLD then
			if not ply:GetIsTired() then
				ply:SetIsTired( true )
				ply.old_run_speed = ply:GetRunSpeed()
				ply.old_jump_power = ply:GetJumpPower()
				ply:SetRunSpeed(ply:GetWalkSpeed())
				ply:SetJumpPower(ply:GetJumpPower()/2)
			end
		end
		
		if nrg < 100 then
			nrg = nrg + 3*t_dif*SCALE
			
			if ply:GetIsTired() and nrg >= PLAYER_UNTIRED_THRESHOLD then
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