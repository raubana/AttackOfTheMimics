AddCSLuaFile()


SWEP.Base = "weapon_base"

SWEP.PrintName 				= "Walkie Talkie"
SWEP.Category				= "AOTM"
SWEP.Purpose				= "10-4 good buddy."
SWEP.Instructions			= "Primary: Talk"
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true

if CLIENT then
	SWEP.BounceWeaponIcon	= false
	SWEP.WepSelectIcon		= surface.GetTextureID( "attack_of_the_mimics/vgui/wep_icons/walkietalkie" )
end

SWEP.Slot 					= 1
SWEP.SlotPos				= 0

SWEP.ViewModelFOV			= 62
SWEP.ViewModelFlip			= false
SWEP.ViewModel				= "models/weapons/v_slam.mdl"
SWEP.WorldModel				= "models/weapons/w_slam.mdl"
SWEP.HoldType				= "slam"
SWEP.UseHands				= true
SWEP.DrawCrosshair			= false

SWEP.DeploySpeed 			= 5.0

SWEP.Primary.Delay 			= 0.2

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
	
	if SERVER then
		self.sent = ents.Create("sent_aotm_walkietalkie")
		self.sent:SetPos(self:GetPos())
		self.sent:SetParent(self)
		self.sent:Spawn()
		self.sent:Activate()
		
		self:SetSENT(self.sent)
		
		self.sent.swep = self
	end
	
	if CLIENT then
		self.transmitting = false
		self.last_tramsit = 0
	end
end


function SWEP:SetupDataTables()
	self:NetworkVar("Entity", 0, "SENT")
end



function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_THROW_ND_DRAW)
end


function SWEP:ShouldDropOnDie()
	return true
end


function SWEP:Holster()
	if CLIENT then
		RunConsoleCommand("-voicerecord", {})
	end
	return true
end


function SWEP:OnDrop()
end


if CLIENT then
	function SWEP:Think()
		if self.transmitting then
			local curtime = CurTime()
			
			if curtime - self.last_tramsit > 0.25 then
				self.transmitting = false
				if self.Owner == LocalPlayer() then
					RunConsoleCommand("-voicerecord", {})
				end
			end
		end
	end
end



function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	
	self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	
	if SERVER then
		self.sent:Transmit()
	else
		if not self.transmitting then
			self:EmitSound("attack_of_the_mimics/weapons/walkietalkie/mode_1.wav", 65, 100, 1.0)
			self.transmitting = true
		end
		self.last_tramsit = CurTime()
		
		if self.Owner == LocalPlayer() then
			RunConsoleCommand("+voicerecord", {})
		end
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


if CLIENT then
	local matSprite = Material( "sprites/glow04_noz" )
	matSprite:SetString( "$additive", "1" )

	function SWEP:ViewModelDrawn( vm )
		local bone_id = 30
		local bone_pos = vm:GetBonePosition(bone_id)
		local bone_ang = vm:GetBoneMatrix(bone_id):GetAngles()
		
		bone_pos =  bone_pos + (bone_ang:Forward()*2) + (bone_ang:Up()*-4) + (bone_ang:Right()*5)
		
		local color = color_white
		local sent = self:GetSENT()
		
		if IsValid(sent) then
			local state = sent:GetState()
			if state == 0 then
				color = Color(0,128,0)
			elseif state == 1 then
				color = Color(255,0,0)
			else
				color = Color(255,255,0)
			end
		end
		
		cam.IgnoreZ(true)
		render.SetMaterial(matSprite)
		render.DrawSprite(bone_pos, 3, 3, color)
		cam.IgnoreZ(true)
	end
end



