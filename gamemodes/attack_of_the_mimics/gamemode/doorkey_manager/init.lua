AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_DOORKEY_MANAGER = AOTM_SERVER_DOORKEY_MANAGER or {}
AOTM_SERVER_DOORKEY_MANAGER.registrars = AOTM_SERVER_DOORKEY_MANAGER.registrars or {}


function AOTM_SERVER_DOORKEY_MANAGER:AddRegistrar( ent )
	table.insert(self.registrars, ent)
end


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_DoorKeyManager", function( old_stage, new_stage )
	if new_stage == STAGE_ROUND then
		local alphanum = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		
		local possible_keys = {}
		for i = 0, 1295 do
			local i1 = i%36
			local i2 = math.floor(i/36)
		
			local key_name = string.sub(alphanum, i1+1, i1+1) .. string.sub(alphanum, i2+1, i2+1)
			
			table.insert(possible_keys, key_name)
		end
		
		util.ShuffleTable(possible_keys)
		
		for i, registrar in ipairs(AOTM_SERVER_DOORKEY_MANAGER.registrars) do
			registrar.key = possible_keys[i]
		end

		local ent_list = ents.FindByClass("swep_aotm_keyring")
		for i, ent in ipairs(ent_list) do
			ent.key_list = {}
			
			util.ShuffleTable(AOTM_SERVER_DOORKEY_MANAGER.registrars)
			for j, registrar in ipairs(AOTM_SERVER_DOORKEY_MANAGER.registrars) do
				table.insert(ent.key_list, registrar.key)
			end
		end
	end

	if old_stage == STAGE_POSTROUND then
		AOTM_SERVER_DOORKEY_MANAGER.registrars = {}
	end
end )


print("doorkey manager init")