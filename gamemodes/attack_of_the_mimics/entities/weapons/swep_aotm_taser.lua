AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Taser"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Shocking."
SWEP.Instructions			= "Primary: Fire.\nHas a long cool-down period."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/taser" )
end

SWEP.Slot 					= 4
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"
SWEP.HoldType				= "revolver"
SWEP.UseHands				= true
SWEP.DrawCrosshair			= true
SWEP.AccurateCrosshair		= true

SWEP.DeploySpeed 			= 5.0

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Primary.FireSound 		= Sound("weapons/pistol/pistol_fire2.wav")
SWEP.Primary.SparkSound 	= Sound("weapons/shotgun/shotgun_empty.wav")

SWEP.Primary.Damage 		= 1
SWEP.Primary.Delay 			= 1.0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Secondary.Delay 		= 0.3

SWEP.DrawAmmo				= false


SWEP.RopeLength				= 256 -- 256
SWEP.CoolDown				= 120 -- 120
SWEP.MisfireCoolDown		= 15 -- 15
SWEP.ShockDuration			= 2 -- 2
SWEP.ShockFrequency			= 16 -- 16



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
	
	if SERVER then
		self.coolingdown = false
		self.cooldown_start = 0
		self.cooldown_end = 0
		self.stop_shocking = 0
		self.target = nil
		self.target_is_world = false
		self.target_offset = nil
		self.rope1 = nil
		self.rope2 = nil
		self.next_damage = 0
	end
	
	self.next_shock = 0
	self.next_flash = 0
end


function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "CoolDown")
	self:NetworkVar("Bool", 0, "IsShocking")
	
	self:SetCoolDown(10)
end


function SWEP:Deploy()
	-- self:SendWeaponAnim()
end


function SWEP:ShouldDropOnDie()
	return true
end


function SWEP:Holster()
	return not self:GetIsShocking()
end


function SWEP:OnDrop()
	self:SnapRope()
end


function SWEP:SnapRope()
	if IsValid(self.rope1) then self.rope1:Fire("break") end
	if IsValid(self.rope2) then self.rope2:Fire("break") end
	self.rope1 = nil
	self.rope2 = nil
	self.target = nil
	self.target_is_world = false
	self:SetIsShocking(false)
end


function  SWEP:doLightCode()
	local t = RealTime()
	
	if t >= self.next_flash then
		self.next_flash = t + (1/4)
		
		-- Note: Due to the possibility of photo sensitivity and epileptic
		-- episodes, the flash frequency should never go above 4 Hz.
	
		local BRIGHT = 1
		local dlight = DynamicLight( self:EntIndex() + 1 )
		if ( dlight ) then
			dlight.pos = self:GetPos()
			dlight.r = 220*BRIGHT
			dlight.g = 255*BRIGHT
			dlight.b = 255*BRIGHT
			dlight.brightness = 1
			dlight.Decay = 10000
			dlight.Size = 1024
			dlight.DieTime = CurTime() + 1.0
		end
	end
end


function SWEP:Think()
	if SERVER then
		if self.coolingdown then
			local t = CurTime()
			local remaining = math.min(math.floor(math.InvLerp(t, self.cooldown_start, self.cooldown_end)*10),10)
			
			if remaining != self:GetCoolDown() then
				self:SetCoolDown(remaining)
				if remaining == 10 then
					self.coolingdown = false
				end
			end
		end
		
		if self:GetIsShocking() then
			local t = CurTime()
			if t >= self.stop_shocking then
				self:SnapRope()
			elseif self.target_is_world then
				if self:GetPos():Distance(self.target_offset) > self.RopeLength then
					self:SnapRope()
				end
			elseif not IsValid(self.target) then
				self:SnapRope()
			else
				local new_offset = 1.0 * self.target_offset
				new_offset:Rotate(self.target:GetAngles())
				
				if self:GetPos():Distance(self.target:GetPos()+new_offset) > self.RopeLength then
					self:SnapRope()
				end
			end
		end
	end
	
	if self:GetIsShocking() then
		local t = CurTime()
		if t >= self.next_shock then
			self.next_shock = t + (1/self.ShockFrequency)
			self:EmitSound( self.Primary.SparkSound, 90, 255, 0.2, CHAN_ITEM )
			
			if SERVER then
				if IsValid(self.target) then
					if self.target:IsPlayer() then
						self.target:SetEnergy(self.target:GetEnergy() - 5)
						
						if t >= self.next_damage then
							self.next_damage = t + 0.5
							self.target:TakeDamage(self.Primary.Damage, self.Owner, self)
						else
							self.target:ViewPunch(Angle( Lerp(math.random(),1,3), Lerp(math.random(),-1,1)*2, Lerp(math.random(),-1,1)*3 ))
						end
					end
				end
			end
			
			if CLIENT and LocalPlayer() == self.Owner then
				self:doLightCode()
			end
		end
	end
end


function SWEP:DrawWorldModel()
	self:DrawModel()

	if LocalPlayer() != self.Owner and self:GetIsShocking() then
		local t = CurTime()
		if t >= self.next_shock then
			self.next_shock = t + (1/self.ShockFrequency)
			
			if CLIENT then
				self:doLightCode()
			end
		end
	end
end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	local owner = self.Owner
	
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self:SendWeaponAnim( ACT_VM_HITCENTER )
	
	self:SnapRope()

	owner:LagCompensation(true)
	
	self:EmitSound( self.Primary.FireSound, 90, 150, 1, CHAN_WEAPON )
	self.next_shock = CurTime() + 0.25
	
	local spos = self.Owner:GetShootPos()
	local sdest = spos + (self.Owner:GetAimVector() * self.RopeLength)
	local sdist = sdest:Distance(spos)
	
	local tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SOLID})

	if SERVER then
		self.cooldown_start = CurTime()
		
		if tr.Hit then
			local offset
			
			self.target_is_world = tr.HitWorld
		
			if tr.HitWorld then
				self.target_offset = tr.HitPos
				offset = tr.HitPos
			else
				self.target = tr.Entity
				self.target_offset = tr.HitPos - tr.Entity:GetPos()
				self.target_offset:Rotate(-tr.Entity:GetAngles())
				offset = 1.0 * self.target_offset
			end
			
			self.rope1 = constraint.CreateKeyframeRope(
				self:GetPos(),
				1,
				"cable/cable_lit",
				nil,
				self,
				Vector(),
				0,
				tr.Entity,
				offset+Vector(Lerp(math.random(),-1,1),Lerp(math.random(),-1,1),Lerp(math.random(),-1,1)),
				tr.PhysicsBone,
				{
					Width = 0.2,
					Breakable = 1,
					Slack = self.RopeLength-sdist,
					Type = 1,
					Length = self.RopeLength*0.99,
					Collide = 1,
				}
			)
			
			self.rope2 = constraint.CreateKeyframeRope(
				self:GetPos(),
				1,
				"cable/cable_lit",
				nil,
				self,
				Vector(),
				0,
				tr.Entity,
				offset+Vector(Lerp(math.random(),-1,1),Lerp(math.random(),-1,1),Lerp(math.random(),-1,1)),
				tr.PhysicsBone,
				{
					Width = 0.2,
					Breakable = 1,
					Slack = self.RopeLength-sdist,
					Type = 1,
					Length = self.RopeLength*1.01,
					Collide = 1,
				}
			)
			
			local vec = ((sdest - spos)/sdist)*1000
			local str_vec = tostring(math.Round(vec.x,0)).." "..tostring(math.Round(vec.y,0)).." "..tostring(math.Round(vec.z,0))
			
			self.rope1:Fire("setforce", str_vec, engine.TickInterval())
			self.rope2:Fire("setforce", str_vec, engine.TickInterval())
			
			self.cooldown_end = CurTime() + self.CoolDown
			self:SetIsShocking(true)
			self.stop_shocking = CurTime() + self.ShockDuration
		else
			self.cooldown_end = CurTime() + self.MisfireCoolDown
		end
		
		self:SetCoolDown(0)
		self.coolingdown = true
	end
	
	owner:LagCompensation(false)
end


function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end
   
   return self:GetCoolDown() == 10
end



function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
end


function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end



