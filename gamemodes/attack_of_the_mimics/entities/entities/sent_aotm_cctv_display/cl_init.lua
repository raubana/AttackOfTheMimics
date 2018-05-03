include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/props_c17/tv_monitor01.mdl" )
	
end


local mat_data = {}
local displayMat = displayMat
if not displayMat then
	displayMat = CreateMaterial("AOTM_CCTV_MAT", "UnlitGeneric", mat_data)
end


function ENT:Draw()
	self:DrawModel()
	
	local cam_ent = self:GetCamera()
	if IsValid(cam_ent) then
		local dist = self:GetPos():Distance(EyePos())
		
		if dist < 750 then
			cam_ent:UpdateRenderTarget()
			
			local dlight = DynamicLight( self:EntIndex() + 1 )
			if ( dlight ) then
				dlight.pos = self:GetPos() + self:GetForward()*7
				dlight.r = 255
				dlight.g = 255
				dlight.b = 255
				dlight.brightness = 3
				dlight.Decay = 1000
				dlight.Size = 24
				dlight.DieTime = CurTime() + 1.0
			end
		end
	end
	
	local no_input = true
	local message
	
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Forward(),90)
	ang:RotateAroundAxis(ang:Right(),-90)
	
	local scale = 16/AOTM_CLIENT_CAMERA_MANAGER.WIDTH
	
	cam.Start3D2D(self:GetPos()-(ang:Forward()*10.0)-(ang:Right()*6.5)+(ang:Up()*5.1), ang, scale)
		
		surface.SetDrawColor(color_black)
		surface.DrawRect(
			0,
			0,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*1.0, 
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.75
		)
		
		if IsValid(cam_ent) then
			local cam_texture = cam_ent.cam_texture
			
			if cam_texture != nil then
				displayMat:SetTexture("$basetexture",cam_texture)
			
				surface.SetDrawColor(color_white)
				surface.SetMaterial(displayMat)
				surface.DrawTexturedRect(
					AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.1,
					AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.075,
					AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.825,
					AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.575
				)
				--surface.DrawRect(0,0,1,1)
				
				local cam_id = cam_ent:GetCameraID()
				
				message = cam_id.." : " .. tostring(math.floor(CurTime()))
				no_input = false
			end
		end
		
		if no_input then
			message = "NO INPUT"
			
			surface.SetDrawColor(color_black)
			surface.DrawRect(0,0,AOTM_CLIENT_CAMERA_MANAGER.WIDTH, AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.75)
		end
		
		surface.SetFont("Trebuchet18")
		surface.SetTextColor(color_black)
		surface.SetTextPos(AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.1+2,AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.075+2)
		surface.DrawText(message)
		surface.SetTextColor(color_white)
		surface.SetTextPos(AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.1,AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.075)
		surface.DrawText(message)
		
		-- screen glow
		local color = Color(255,255,255,2)
		
		surface.SetDrawColor(color)
		surface.DrawRect(
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.1,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.075,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.825,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.575
		)
		
		
		-- screen flicker
		local color = Color(0,0,0,Lerp(1-((RealTime()*15)%1.0), 0, 16))
		
		surface.SetDrawColor(color)
		surface.DrawRect(
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.1,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.075,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.825,
			AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.575
		)
		
	cam.End3D2D()
end