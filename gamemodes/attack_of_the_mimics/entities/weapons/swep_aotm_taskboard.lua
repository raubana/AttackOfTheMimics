AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Task Board"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Things to do today..."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/taskboard" )
end

SWEP.Slot 					= 2
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



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
end



function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end


function SWEP:ShouldDropOnDie()
	return false
end


if CLIENT then
	function SWEP:DrawHUD()
		surface.SetFont("Trebuchet24")
		surface.SetTextColor(color_white)
		
		local y = 10
	
		for i, task in ipairs(AOTM_CLIENT_TASK_MANAGER.tasks) do
			if task.description then
				local message = task.description
				if task.completed then
					message = "☑ ".. message
				else
					message = "☐ ".. message
				end
			
				local w, h = surface.GetTextSize(message)
				
				surface.SetTextPos(10,y)
				surface.DrawText(message)
				
				y = y + h
			end
		end
	end
end



function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
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



