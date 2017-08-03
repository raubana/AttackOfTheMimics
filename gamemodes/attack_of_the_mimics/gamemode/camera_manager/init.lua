AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


AOTM_SERVER_CAMERA_MANAGER = AOTM_SERVER_CAMERA_MANAGER or {}
AOTM_SERVER_CAMERA_MANAGER.display_list = AOTM_SERVER_CAMERA_MANAGER.display_list or {}


function AOTM_SERVER_CAMERA_MANAGER:AddDisplay( ent )
	table.insert(self.display_list, ent)
end

function AOTM_SERVER_CAMERA_MANAGER:DeleteDisplay( ent )
	table.RemoveByValue(self.display_list, ent)
end


concommand.Add( "camera_test", function(ply, cmd, args, argStr)
	if not ply:IsAdmin() then return end
	
	local tr = ply:GetEyeTrace()
	
	local cam_ent = ents.Create("sent_aotm_cctv_camera")
	cam_ent:SetPos(tr.HitPos + tr.HitNormal * 50)
	cam_ent:Spawn()
	cam_ent:Activate()
	
	display_ent = ents.Create("sent_aotm_cctv_display")
	display_ent:SetPos(tr.HitPos + tr.HitNormal * 50 + Vector(0,50,0))
	display_ent:Spawn()
	display_ent:Activate()
	
	display_ent:SetCamera(cam_ent)
end )


hook.Add( "SetupPlayerVisibility", "AOTM_SetupPlayerVisibility_CameraManager_Init", function(ply, viewEntity)
	local curtime = CurTime()
	
	local viewEntity = viewEntity
	if not IsValid(viewEntity) then
		viewEntity = ply
	end

	for i, display_ent in ipairs(AOTM_SERVER_CAMERA_MANAGER.display_list) do
		if display_ent:GetPos():Distance(ply:GetPos()) < 750 then
			local camera = display_ent:GetCamera()
			
			if IsValid(camera) then
				AddOriginToPVS(camera:GetPos())
			end
		end
	end
end )



print("camera manager init")