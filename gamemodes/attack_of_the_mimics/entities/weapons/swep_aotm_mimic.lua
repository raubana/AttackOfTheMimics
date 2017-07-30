AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Mimic"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Pick something to mimic."
SWEP.Instructions			= "Primary: Mimic"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/mimic" )
end

SWEP.Slot 					= 1
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel 				= Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel				= Model( "models/weapons/c_arms_animations.mdl" )
SWEP.HoldType				= "normal"
SWEP.UseHands				= false
SWEP.DrawCrosshair			= true
SWEP.AccurateCrosshair		= true

SWEP.DeploySpeed 			= 1.0

SWEP.Primary.Delay 			= 1.0

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false



SWEP.is_for_mimics = true



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
end



function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if not IsValid(self.Owner) then return end
	
	local owner = self.Owner
	
	if SERVER then
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
		
		if IsValid(hitEnt) and not hitEnt:IsWorld() then
			local mimic_body = owner:GetMimicBody()
			
			if hitEnt:IsPlayer() and hitEnt:Team() == TEAM_MIMIC then
				mimic_body:Mimic(hitEnt:GetMimicBody():GetModel(), hitEnt:GetMimicBody():GetSkin())
			else
				mimic_body:Mimic(hitEnt:GetModel(), hitEnt:GetSkin())
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
	
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end




