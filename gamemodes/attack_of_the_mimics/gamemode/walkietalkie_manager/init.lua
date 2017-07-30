AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_WALKIETALKIE_MANAGER = AOTM_SERVER_WALKIETALKIE_MANAGER or {}
AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies = AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies or {}
AOTM_SERVER_WALKIETALKIE_MANAGER.transmitters = AOTM_SERVER_WALKIETALKIE_MANAGER.transmitters or {}


function AOTM_SERVER_WALKIETALKIE_MANAGER:RegisterWalkieTalkie( ent )
	table.insert(self.walkietalkies, ent)
end

function AOTM_SERVER_WALKIETALKIE_MANAGER:UnRegisterWalkieTalkie( ent )
	table.RemoveByValue(self.walkietalkies, ent)
end

function AOTM_SERVER_WALKIETALKIE_MANAGER:StartTransmitting( ent )
	ent:SetState(2)
	
	if (#self.transmitters) <= 0 then
		for i, ent2 in ipairs(self.walkietalkies) do
			local state = ent2:GetState()
			if state == 0 then
				ent2:SetState(1)
			end
		end
	end
	
	table.insert(self.transmitters, ent)
end

function AOTM_SERVER_WALKIETALKIE_MANAGER:StopTransmitting( ent )
	table.RemoveByValue(self.transmitters, ent)

	if (#self.transmitters) <= 0 then
		ent:SetState(0)
	
		for i, ent2 in ipairs(self.walkietalkies) do
			local state = ent2:GetState()
			if state == 1 then
				ent2:SetState(0)
			end
		end
	else
		ent:SetState(1)
	end
end


local next_update_feedback = 0

hook.Add( "Tick", "AOTM_Tick_WalkieTalkieManager_Init", function()
	local curtime = CurTime()
	
	if curtime > next_update_feedback then
		next_update_feedback = curtime + 0.5
		local prev_feedback_amount = GetGlobalFloat("AOTM_WalkieTalkie_Feedback")
		local feedback_amount = 0.0
		
		for i = 1, #AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies - 1 do
			local ent1 = AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies[i]
			local state1 = ent1:GetState()
			
			for j = i+1, #AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies do
				local ent2 = AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies[j]
				local state2 = ent2:GetState()
				
				if (state1 == 1 and state2 == 2) or (state1 == 2 and state2 == 1) then
					feedback_amount = math.max(feedback_amount, Lerp(ent1:GetPos():Distance(ent2:GetPos())/125.0, 1, 0))
				end
			end
		end
		
		feedback_amount = math.Round(feedback_amount, 1)
		
		if feedback_amount != prev_feedback_amount then
			SetGlobalFloat("AOTM_WalkieTalkie_Feedback", feedback_amount)
		end
	end
end )

print("walkie-talkie manager init")