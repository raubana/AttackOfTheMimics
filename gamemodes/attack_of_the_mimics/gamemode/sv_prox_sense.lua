hook.Add( "Initialize", "AOTM_Initialize_ProximitySense_Init", function( )
	util.AddNetworkString("AOTM_ProxSense")
end )


local next_update_prox_sense = next_update_prox_sense or 0

hook.Add( "Tick", "AOTM_Tick_ProximitySense_Init", function()
	local curtime = CurTime()
	
	if curtime >= next_update_prox_sense then
		local mechanics = team.GetPlayers(TEAM_MECHANIC)
		local mimics = team.GetPlayers(TEAM_MIMIC)
		
		for i, mimic in ipairs(mimics) do
			local sense = 0.0
			
			if IsValid(mimic) then
				for j, mechanic in ipairs(mechanics) do
					if IsValid(mechanic) then
						sense = math.max( sense, math.pow( math.max( 0.0, (10000 - mimic:GetPos():Distance(mechanic:GetPos()))/10000.0 ), 2) )
					end
				end
			end
			
			net.Start("AOTM_ProxSense")
			net.WriteFloat(sense)
			net.Send(mimic)
		end
		
		next_update_prox_sense = curtime + 2.0
	end
end )