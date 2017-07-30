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
	
	local cam_ent = nil -- self:GetCamera()
	if IsValid(cam_ent) then
	
		-- TODO: Find a better solution to the RenderView bug.
		
		local localplayer = LocalPlayer()
		
		if IsValid(localplayer) then
			local dist = self:GetPos():Distance(localplayer:EyePos())
			
			if dist < 750 then
				cam_ent:UpdateRenderTarget()
			end
		end
	end
	
	local no_input = true
	local message
	
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Forward(),90)
	ang:RotateAroundAxis(ang:Right(),-90)
	
	local scale = 16/AOTM_CLIENT_CAMERA_MANAGER.WIDTH
	
	cam.Start3D2D(self:GetPos()-(ang:Forward()*10)-(ang:Right()*6.5)+(ang:Up()*7.1), ang, scale)
	
	if IsValid(cam_ent) then
		local cam_texture = cam_ent.cam_texture
		
		if cam_texture != nil then
			displayMat:SetTexture("$basetexture",cam_texture)
		
			surface.SetDrawColor(color_white)
			surface.SetMaterial(displayMat)
			surface.DrawTexturedRect(0,0,AOTM_CLIENT_CAMERA_MANAGER.WIDTH, AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.75)
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
	surface.SetTextPos(2,2)
	surface.DrawText(message)
	surface.SetTextColor(color_white)
	surface.SetTextPos(0,0)
	surface.DrawText(message)
	
	-- slight screen flicker
	local color = HSVToColor(0,0,Lerp((math.sin(RealTime()*50)+1)/2, 0.49, 0.5))
	color.a = 1
	
	surface.SetDrawColor(color)
	surface.DrawRect(0,0,AOTM_CLIENT_CAMERA_MANAGER.WIDTH, AOTM_CLIENT_CAMERA_MANAGER.WIDTH*0.75)
	
	cam.End3D2D()
end