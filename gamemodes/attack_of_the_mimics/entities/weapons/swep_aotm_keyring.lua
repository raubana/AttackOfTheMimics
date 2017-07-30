AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Key Ring"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Jingly."
SWEP.Instructions			= "Primary: Unlock\nSecondary: Lock\nReload: Next key"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/keys" )
end

SWEP.Slot 					= 3
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel				= "models/weapons/w_bugbait.mdl"
SWEP.HoldType				= "slam"
SWEP.UseHands				= true
SWEP.DrawCrosshair			= false

SWEP.DeploySpeed 			= 5.0

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false



SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_bugbait.mdl"
SWEP.WorldModel				= "models/weapons/w_bugbait.mdl"
SWEP.HoldType				= "normal"
SWEP.UseHands				= false
SWEP.DrawCrosshair			= true

SWEP.DeploySounds = {
	Sound("attack_of_the_mimics/weapons/keyring/deploy1.wav")
}

SWEP.KeySelectSounds = {
	Sound("attack_of_the_mimics/weapons/keyring/keyselect1.wav"),
	Sound("attack_of_the_mimics/weapons/keyring/keyselect2.wav")
}

SWEP.LockFailSounds = {
	Sound("doors/latchlocked2.wav")
}

SWEP.LockSuccessSounds = {
	Sound("doors/default_locked.wav")
}

SWEP.DeploySpeed 			= 1.0

SWEP.Primary.Delay 			= 1.0

SWEP.Primary.Damage			= 25
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay 			= 1.0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
	
	if SERVER then
		self.key_list = {}
		self.key_index = 0
		
		self.last_reload = 0
	end
end


function SWEP:PlayRandomSound( tbl, volume )
	local pick = tbl[math.random(#tbl)]
	
	self.Owner:EmitSound(pick, 65, 100, volume or 1.0)
end


function SWEP:SetKeyIndex( index )
	self.key_index = index
	self:SetActiveKey(self.key_list[self.key_index])
end


function SWEP:Deploy()
	self:PlayRandomSound(self.DeploySounds, 0.35)

	if SERVER then
		-- pick a random key.
		if #self.key_list > 0 then
			self:SetKeyIndex(math.random(#self.key_list))
		end
	end
end


function SWEP:SetupDataTables()
	self:NetworkVar( "String", 0, "ActiveKey" )
end



function SWEP:Reload()
	if SERVER then
		local curtime = CurTime()
		
		if curtime - self.last_reload > 0.5 then
			self:PlayRandomSound(self.KeySelectSounds)
		
			if #self.key_list > 0 then
				local index = self.key_index + 1
				if index > #self.key_list then
					index = 1
				end
				
				self:SetKeyIndex( index )
			end
			
			self.last_reload = curtime
		end
	end
end



function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if SERVER then
		if not IsValid(self.Owner) then return end
		
		local owner = self.Owner

		owner:LagCompensation(true)

		local spos = self.Owner:GetShootPos()
		local sdest = spos + (self.Owner:GetAimVector() * 70)

		local kmins = Vector(1,1,1) * -10
		local kmaxs = Vector(1,1,1) * 10

		local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

		-- Hull might hit environment stuff that line does not hit
		if not IsValid(tr.Entity) then
			tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
		end

		local hitEnt = tr.Entity
		
		if IsValid(hitEnt) and IsValid(hitEnt.doorkey_registrar) then
			self:PlayRandomSound(self.DeploySounds)
		
			if #self.key_list > 0 and self.key_list[self.key_index] == hitEnt.doorkey_registrar.key then
				hitEnt:Fire("Unlock")
				self:PlayRandomSound(self.LockSuccessSounds)
			else
				self:PlayRandomSound(self.LockFailSounds)
			end
		end
		
		owner:LagCompensation(false)
	end
end

function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end



function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	
	if SERVER then
		if not IsValid(self.Owner) then return end
		
		local owner = self.Owner

		owner:LagCompensation(true)

		local spos = self.Owner:GetShootPos()
		local sdest = spos + (self.Owner:GetAimVector() * 70)

		local kmins = Vector(1,1,1) * -10
		local kmaxs = Vector(1,1,1) * 10

		local tr = util.TraceHull({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

		-- Hull might hit environment stuff that line does not hit
		if not IsValid(tr.Entity) then
			tr = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
		end

		local hitEnt = tr.Entity
		
		if IsValid(hitEnt) and IsValid(hitEnt.doorkey_registrar) then
			self:PlayRandomSound(self.DeploySounds)
		
			if #self.key_list > 0 and self.key_list[self.key_index] == hitEnt.doorkey_registrar.key then
				hitEnt:Fire("Lock")
				self:PlayRandomSound(self.LockSuccessSounds)
			else
				self:PlayRandomSound(self.LockFailSounds)
			end
		end
		
		owner:LagCompensation(false)
	end
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end


if CLIENT then
	function SWEP:DrawHUD()
		local active_key = self:GetActiveKey()
		
		if active_key then
			surface.SetFont("Trebuchet24")
			surface.SetTextColor(color_white)
			
			surface.SetTextPos(ScrW()/2 + 10, ScrH()/2 + 10)
			surface.DrawText(active_key)
		end
	end
end


