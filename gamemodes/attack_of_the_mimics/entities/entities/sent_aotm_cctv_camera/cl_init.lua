include("shared.lua")


function ENT:Initialize()
	self:SetModel( "models/props_silo/camera.mdl" )
	-- self.cam_texture = AOTM_CLIENT_CAMERA_MANAGER:CreateCameraTexture()
	-- self.next_render = 0
end


function ENT:OnRemove()
	-- AOTM_CLIENT_CAMERA_MANAGER:DeleteCameraTexture(self.cam_texture)
end


function ENT:UpdateRenderTarget()
	--[[
	local curtime = CurTime()
	
	if curtime > self.next_render then
		self.next_render = curtime + (1/4) + Lerp(math.random(), 0.0, 0.2)
		
		local ang = self:GetAngles()
		ang:RotateAroundAxis(ang:Up(), 25)
		ang:RotateAroundAxis(ang:Right(), -30)
		
		-- AOTM_CLIENT_CAMERA_MANAGER:UpdateRenderTarget(self, self.cam_texture, self:GetPos()+(ang:Forward()*20)-(ang:Right()*30)+(ang:Up()*10), ang, self:GetFOV())
		AOTM_CLIENT_CAMERA_MANAGER:QueueData(self, self.cam_texture, self:GetPos()+(ang:Forward()*20)-(ang:Right()*30)+(ang:Up()*10), ang, self:GetFOV())
	end
	]]
end