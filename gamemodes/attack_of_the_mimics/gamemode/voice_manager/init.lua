AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_MIMICCHATTER_MANAGER = AOTM_SERVER_MIMICCHATTER_MANAGER or {}
AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers = AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers or {}

local CHATTER_SOUNDS = {
	Sound("npc/headcrab_poison/ph_warning1.wav"),
	Sound("npc/headcrab_poison/ph_warning2.wav"),
	Sound("npc/headcrab_poison/ph_warning3.wav"),
	Sound("npc/antlion/idle1.wav"),
	Sound("npc/antlion/idle5.wav"),
	Sound("npc/headcrab_fast/idle1.wav"),
	Sound("npc/headcrab_fast/idle2.wav")
}



function GM:PlayerCanHearPlayersVoice(listener, talker)
	if talker:Team() == TEAM_SPEC then
		if listener:Team() == TEAM_SPEC then 
			return true, false
		else
			return false, false
		end
	end
	
	local dist = listener:GetPos():Distance(talker:GetPos())
	
	if talker:Team() == TEAM_MIMIC then
		--[[
		if listener != talker and not talker.is_chattering then
			talker.is_chattering = true
			talker.next_chatter = CurTime()+0.5
			talker:EmitSound(CHATTER_SOUNDS[math.random(#CHATTER_SOUNDS)], 75, Lerp(math.random(), 90, 110), 0.1)
			table.insert(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, talker)
		end
		]]
	
		if listener:Team() == TEAM_MIMIC and dist < 1000 then
			return true, true
		else
			return false, false
		end
	end

	local talker_active_wep = talker:GetActiveWeapon()
	if IsValid(talker_active_wep) and talker_active_wep:GetClass() == "swep_aotm_walkietalkie" and talker_active_wep.sent:GetState() == 2 then
		local can_hear_walkietalkie = false
		for i, ent in ipairs(AOTM_SERVER_WALKIETALKIE_MANAGER.walkietalkies) do
			if ent:GetState() == 1 and ent:GetPos():Distance(listener:GetPos()) < 300 then
				can_hear_walkietalkie = true
				break
			end
		end
		
		if can_hear_walkietalkie then
			-- print(talker, listener)
			return true, false
		end
	end
	
	if dist < 1000 then
		return true, true
	else
		return false, false
	end
end



hook.Add( "Tick", "AOTM_Tick_VoiceManager_Init", function()
	local curtime = CurTime()

	local i = #AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers
	
	while i > 0 do
		local talker = AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers[i]
		
		if talker.is_chattering and curtime > talker.next_chatter then
			talker.is_chattering = false
			table.remove(AOTM_SERVER_MIMICCHATTER_MANAGER.chatterers, i)
		end
		
		i = i - 1
	end

end)

print("voice manager init")