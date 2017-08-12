AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Claws"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "Do some damage."
SWEP.Instructions			= "Primary: Attack.\nSecondary: Mimic.\nReload: Scream."
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/claws" )
end

SWEP.Slot 					= 0
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

SWEP.Primary.Sound 			= Sound("npc/fast_zombie/claw_miss1.wav")
SWEP.Primary.HitSound 		= {
	Sound("npc/fast_zombie/claw_strike1.wav"),
	Sound("npc/fast_zombie/claw_strike2.wav"),
	Sound("npc/fast_zombie/claw_strike3.wav")
}
SWEP.Primary.Damage			= 15
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Delay 		= 1.0

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false

SWEP.Scream					= {}
SWEP.Scream.Delay			= 60
SWEP.Scream.Sounds			= {
	Sound("npc/fast_zombie/fz_scream1.wav")
}

SWEP.is_for_mimics = true



function SWEP:Initialize()
	self:SetDeploySpeed(self.DeploySpeed)

	if self.SetHoldType then
		self:SetHoldType(self.HoldType)
	end
	
	if SERVER then
		self.next_scream_ready = 0
	end
end



function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "ScreamReady")
end

if SERVER then
	function SWEP:Think()
		if not self:GetScreamReady() then
			if CurTime() > self.next_scream_ready then
				self:SetScreamReady(true)
			end
		end
	end
end


function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

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
	
	self:EmitSound( self.Primary.Sound )

	-- effects
	if tr.Hit then
		self:EmitSound( self.Primary.HitSound[math.random(#self.Primary.HitSound)] )
	end

	if SERVER and tr.Hit then
		local dmg = DamageInfo()
		
		local dmg_scale = 1.0
		
		if not owner:GetIsTired() then
			dmg_scale = dmg_scale * Lerp(owner:GetEnergy()/100.0, 1.0, 2.0)
		end
		
		if hitEnt:IsPlayer() then
			local ang = hitEnt:GetAngles()
			ang.pitch = 0
			local forward = ang:Forward()
			
			dmg_scale = dmg_scale * (math.max(forward:Dot(owner:GetAimVector())*1, 0)+1)
		elseif hitEnt:GetClass() == "prop_door_rotating" then
			dmg_scale = dmg_scale * 5.0
		end
		
		dmg:SetDamage(self.Primary.Damage*dmg_scale)
		dmg:SetMaxDamage(self.Primary.Damage*dmg_scale)
		dmg:SetAttacker(owner)
		dmg:SetInflictor(self.Weapon or self)
		dmg:SetDamageForce(owner:GetAimVector() * 3000)
		dmg:SetDamagePosition(owner:GetPos())
		dmg:SetDamageType(DMG_SLASH)

		hitEnt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
	end
	
	owner:LagCompensation(false)
	
	if SERVER then
		if IsValid(owner) then
			owner:SetEnergy(owner:GetEnergy()-25)
		end
	end
end


function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end
   
   return true
end



function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then return end
	
	self:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	
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


function SWEP:CanSecondaryAttack()
	if not IsValid(self.Owner) then return end
	
	return true
end


function SWEP:Reload()
	if not self:GetScreamReady() then return end
	
	if SERVER then
		self.Owner:EmitSound( self.Scream.Sounds[math.random(#self.Scream.Sounds)], 95, Lerp(math.random(), 80, 100) )
		
		self.Owner:SetEnergy(99)
		
		self:SetScreamReady(false)
		self.next_scream_ready = CurTime() + self.Scream.Delay
	else
		self.scream_init = CurTime()
	end
end