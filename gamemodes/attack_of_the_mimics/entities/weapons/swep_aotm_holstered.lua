AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Holstered"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Hands free."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/hand" )
end

SWEP.Slot 					= 0
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel 				= Model( "models/weapons/c_arms_animations.mdl" )
SWEP.WorldModel				= Model( "models/weapons/c_arms_animations.mdl" )
SWEP.HoldType				= "normal"
SWEP.UseHands				= true
SWEP.DrawCrosshair			= true

SWEP.DeploySpeed 			= 1.0

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

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
end



function SWEP:Deploy()

end



function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end



