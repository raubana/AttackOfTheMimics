AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "AOTM Walkie Talkie SENT"
ENT.Author			= "raubana"
ENT.Information		= "For the dropped walkie talkie."
ENT.Category		= "AOTM"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.RenderGroup		= RENDERGROUP_OPAQUE



function ENT:Initialize()
	self:SetNoDraw(true)
	
	if SERVER then
		AOTM_SERVER_WALKIETALKIE_MANAGER:RegisterWalkieTalkie(self)
		
		local filter = RecipientFilter()
		filter:AddAllPlayers()
		
		self.active_sound = CreateSound(self, "attack_of_the_mimics/weapons/walkietalkie/active_loop.wav", filter)
		self.active_sound:SetSoundLevel( 65 )
		self.active_sound:ChangeVolume(0.0)
		
		self.feedback_sound = CreateSound(self, "attack_of_the_mimics/weapons/walkietalkie/feedback_loop.wav", filter)
		self.feedback_sound:SetSoundLevel( 65 )
		self.feedback_sound:ChangeVolume(0.0)
		
		self.last_state = 0
		self.last_feedback = 0
		
		self.transmitting = false
		self.last_tramsit = 0
	end
end


function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "State")
	
	-- there are three states:
	-- 0: not active.
	-- 1: recieving.
	-- 2: transmitting.
	
	
	-- Apparently this is broken.
	-- https://github.com/Facepunch/garrysmod-requests/issues/324
	
	-- Someone remind me later to impliment NW2Var.
	
	--[[
	if CLIENT then
		self:NetworkVarNotify("State", function(ent, name, old, new)
			print(ent, name, old, new)
		end )
	end
	]]
end


if SERVER then
	
	function ENT:OnRemove()
		self.active_sound:Stop()
		self.feedback_sound:Stop()
	
		if SERVER then
			if self:GetState() == 2 then
				AOTM_SERVER_WALKIETALKIE_MANAGER:StopTransmitting(self)
			end
			AOTM_SERVER_WALKIETALKIE_MANAGER:UnRegisterWalkieTalkie(self)
		end
	end
	
	
	function ENT:Transmit()
		if not self.transmitting then
			AOTM_SERVER_WALKIETALKIE_MANAGER:StartTransmitting( self )
			self.transmitting = true
		end
		self.last_tramsit = CurTime()
	end
	
	
	function ENT:Think()
		if self.transmitting then
			local curtime = CurTime()
			
			if curtime - self.last_tramsit > 0.5 then
				self.transmitting = false
				AOTM_SERVER_WALKIETALKIE_MANAGER:StopTransmitting( self )
			end
		end
		
		-- This was meant to be clientside, but there were problems...
		local feedback = GetGlobalFloat("AOTM_WalkieTalkie_Feedback")
		
		local state = self:GetState()
		if self.last_state != state then
			-- print(self, "State", self.last_state, state)
			
			if self.last_state == 2 then
				self:EmitSound("attack_of_the_mimics/weapons/walkietalkie/select_1.wav", 65, 100, 0.5)
			end
			
			if state == 1 and self.last_state == 0 then
				self:EmitSound("attack_of_the_mimics/weapons/walkietalkie/active_on_"..tostring(math.random(1,4))..".wav", 65)
			elseif state == 0 and self.last_state == 1 then
				self:EmitSound("attack_of_the_mimics/weapons/walkietalkie/active_off_"..tostring(math.random(1,7))..".wav", 65)
			end
			
			if state == 1 then
				self.active_sound:Play()
				self.active_sound:ChangeVolume(0.2)
			elseif self.last_state == 1 then
				self.active_sound:Stop()
			end
			
			if self.last_state == 1 then
				self.feedback_sound:Stop()
				self.last_feedback = 0.0
			end
			
			self.last_state = state
		end
			
		if state == 1 then
			if feedback != self.last_feedback then
				if feedback > 0 and not self.feedback_sound:IsPlaying() then
					self.feedback_sound:Play()
					self.feedback_sound:ChangeVolume(0.0)
				elseif feedback <= 0 and self.feedback_sound:IsPlaying() then
					self.feedback_sound:Stop()
					self.last_feedback = 0.0
				end
				if feedback > 0 then
					self.feedback_sound:ChangeVolume(feedback, 1.0)
				end
				self.last_feedback = feedback
			end
		end
		
		self:NextThink(CurTime() + Lerp(math.random(), 0.1, 0.2))
		return true
	end
	
end