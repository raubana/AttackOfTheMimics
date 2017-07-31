AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Flashlight"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "A horror staple."
SWEP.Instructions			= "Primary: Toggle light\nSecondary: Thrash"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/flashlight" )
end

SWEP.Slot 					= 4
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_crowbar.mdl"
SWEP.WorldModel				= "models/weapons/w_crowbar.mdl"
SWEP.HoldType				= "pistol"
SWEP.UseHands				= true
SWEP.DrawCrosshair			= false

SWEP.DeploySpeed 			= 5.0

SWEP.SwitchOnSound 			= Sound("attack_of_the_mimics/weapons/flashlight/switch_on.wav")
SWEP.SwitchOffSound 		= Sound("attack_of_the_mimics/weapons/flashlight/switch_off.wav")

SWEP.Primary.Delay 			= 0.5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Sound 		= Sound("npc/fast_zombie/claw_miss1.wav")
SWEP.Secondary.HitSound 	= Sound("ambient/voices/citizen_punches2.wav")

SWEP.Secondary.Delay 		= 1.0
SWEP.Secondary.Damage 		= 25

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
	
	if SERVER then
		
	end
	
	if CLIENT then
		
	end
end


function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsActivated")
end


function SWEP:ToggleActive()
	self:SetIsActivated(not self:GetIsActivated())
	if self:GetIsActivated() then
		self:EmitSound(self.SwitchOnSound, 75, 100, 0.25)
	else
		self:EmitSound(self.SwitchOffSound, 75, 100, 0.25)
	end
end


function SWEP:SwitchOn()
	if not self:GetIsActivated() then
		self:ToggleActive()
	end
end


function SWEP:SwitchOff()
	if self:GetIsActivated() then
		self:ToggleActive()
	end
end



function SWEP:Deploy()
	-- self:SendWeaponAnim()
end


function SWEP:ShouldDropOnDie()
	return true
end


function SWEP:Holster()
	self:SwitchOff()
	return true
end


function SWEP:OnDrop()
end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if IsFirstTimePredicted() then
		self:ToggleActive()
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
	
	local owner = self.Owner
	
	self:SendWeaponAnim(ACT_MELEE_ATTACK1)

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
	
	self:EmitSound( self.Secondary.Sound )

	-- effects
	if tr.Hit then
		self:EmitSound( self.Secondary.HitSound )
	end
	
	if SERVER and tr.Hit then
		local dmg = DamageInfo()
		dmg:SetDamage(self.Secondary.Damage)
		dmg:SetMaxDamage(self.Secondary.Damage)
		dmg:SetAttacker(owner)
		dmg:SetInflictor(self.Weapon or self)
		dmg:SetDamageForce(owner:GetAimVector() * 6000)
		dmg:SetDamagePosition(owner:GetPos())
		dmg:SetDamageType(DMG_CLUB)

		hitEnt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
	end
	
	owner:LagCompensation(false)
	
	if SERVER then
		if IsValid(owner) then
			owner:SetEnergy(owner:GetEnergy()-20)
		end
	end
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end



