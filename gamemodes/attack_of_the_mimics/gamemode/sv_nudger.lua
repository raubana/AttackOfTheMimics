
local ents_to_clutter = {}

hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_Clutterer", function( old_stage, new_stage )
	if new_stage == STAGE_ROUND then
		local ent_list = ents.FindByClass("prop_*")
		local legal_ents = {}
		for i, ent in ipairs(ent_list) do
			if IsValid(ent) and string.StartWith(ent:GetClass(), "prop_physics") then
				table.insert(legal_ents, ent)
			end
		end
		
		util.ShuffleTable(legal_ents)
		
		--[[
		for i = 1,math.ceil(Lerp(math.random(), 0.4, 0.6)*#legal_ents) do
			table.insert(ents_to_clutter, legal_ents[i])
		end
		]]
		
		ents_to_clutter = legal_ents
	elseif old_stage == STAGE_ROUND then
		ents_to_clutter = {}
	end
end )


hook.Add( "Tick", "AOTM_Tick_Clutterer", function( )
	if #ents_to_clutter > 0 then
		local ent = table.remove(ents_to_clutter)
		if IsValid(ent) then
			local physobj = ent:GetPhysicsObject()
			
			if IsValid(physobj) then
				physobj:AddVelocity(VectorRand()*Lerp(math.random(),25,100))
				physobj:AddAngleVelocity(VectorRand()*Lerp(math.random(),100,400))
			end
		end
	end
end )