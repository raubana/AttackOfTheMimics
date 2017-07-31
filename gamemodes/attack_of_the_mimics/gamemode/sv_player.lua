function GM:SetPlayerToSpec( ply )
	if ply:Alive() then
		ply:KillSilent()
	end

	ply:StripWeapons()
	ply:Freeze(false)
	ply:Spectate(OBS_MODE_ROAMING)
	ply:AllowFlashlight(false)
	ply:Extinguish()
end


function GM:PlayerInitialSpawn( ply )
	if IsValid(ply) then
		ply:SetCanZoom( false ) //We don't want them to be able to use suit zoom.
		if ply:Alive() then
			ply:SetTeam(TEAM_SPEC)
		end
		print(ply:GetName(),"has initially spawned.")
	end
end


local DEFAULT_MIMIC_MODELS = {
	"models/props_c17/oildrum001.mdl"
}


function GM:PlayerSpawn(ply)
	local t = ply:Team()

	if t == TEAM_SPEC then
		self:SetPlayerToSpec( ply )
	else
		ply:UnSpectate()
		ply:SetEnergy(100)
		ply:SetIsTired(false)
		ply:AllowFlashlight(false)
		
		ply:SetJumpPower(200)
		
		if t == TEAM_MECHANIC then 
			ply:SetNoDraw(false)
		
			ply:SetModel("models/player/leet.mdl")
			ply:Give("swep_aotm_holstered")
			ply:Give("swep_aotm_walkietalkie")
			ply:Give("swep_aotm_taskboard")
			ply:Give("swep_aotm_keyring")
			ply:Give("swep_aotm_flashlight")
			ply:ShouldDropWeapon(true)
			
			ply:SetRunSpeed(250)
			ply:SetWalkSpeed(90)
			ply:SetCrouchedWalkSpeed(0.5)
			
			local ent = ents.Create("sent_aotm_id_badge")
			ent:PinToPlayer(ply)
			ent:Spawn()
			ent:Activate()
			
			AOTM_SERVER_IDBADGE_MANAGER:AddBadge(ply, ent)
		elseif t == TEAM_MIMIC then
			ply:SetNoDraw(true)
			
			ply:SetModel("models/Zombie/Poison.mdl")
			
			ply:Give("swep_aotm_claws")
			ply:Give("swep_aotm_mimic")
			ply:ShouldDropWeapon(false)
			
			ply:SetRunSpeed(350)
			ply:SetWalkSpeed(85)
			ply:SetCrouchedWalkSpeed(0.2)
			
			local ent = ents.Create("sent_aotm_mimicbody")
			ent:SetPos(ply:GetPos())
			ent:SetParent(ply)
			ent:Spawn()
			ent:Activate()
			
			ply:SetMimicBody(ent)
			
			ent:Mimic(DEFAULT_MIMIC_MODELS[math.random(#DEFAULT_MIMIC_MODELS)], 0, true)
		end
	end
	
	print(ply:GetName(),"has spawned.")
end


function GM:PlayerSelectSpawn( ply )
	local spawn_points = {}
	
	if ply:Team() == TEAM_MECHANIC then
		spawn_points = ents.FindByClass("info_aotm_mechanic_start")
	elseif ply:Team() == TEAM_MIMIC then
		spawn_points = ents.FindByClass("info_aotm_mimic_start")
	end
	
	if #spawn_points > 0 then
		util.ShuffleTable(spawn_points)
		
		for i, ent in ipairs(spawn_points) do
			if not ent.is_occupied then
				ent.is_occupied = true
				if ent:GetClass() != "info_player_start" then
					ent:TriggerOutput("PlayerSpawn", ent)
				end
				return ent
			end
		end
	else
		-- this is meant mostly for players who've just spawned in the server.
		if #spawn_points > 0 then
			return spawn_points[math.random(#spawn_points)]
		end
	end
	
	-- TODO: Find solution for when there aren't enough spawn points.
end


function GM:PlayerNoClip( ply, desiredState )
	return ply:IsAdmin() or desiredState == false
end


function GM:PlayerCanPickupWeapon( ply, wep )
	if ply:HasWeapon(wep:GetClass()) then return false end
	
	if ply:Team() == TEAM_MIMIC then
		return wep.is_for_mimics == true
	end
	
	return true
end


function GM:GetFallDamage(ply, speed)
	return 1
end


function GM:OnPlayerHitGround( ply, inWater, onFloater, speed)
	local dmg_amount = 0
	if not inWater then
		dmg_amount = math.max( 0, math.ceil( 0.23*speed - 120 ) )
	end
	
	if dmg_amount > 0 then
		local dmg = DamageInfo()
		dmg:SetDamageType(DMG_FALL)
		dmg:SetDamage(dmg_amount)
		dmg:SetInflictor(game.GetWorld())
		dmg:SetAttacker(game.GetWorld())
		ply:TakeDamageInfo(dmg)
	end
	return true
end


function GM:PlayerDisconnected( ply )
	ply:Kill()
end


function GM:PostPlayerDeath( ply )
	local badge = AOTM_SERVER_IDBADGE_MANAGER:GetBadge(ply)
	if IsValid(badge) then
		SafeRemoveEntity(badge)
		AOTM_SERVER_IDBADGE_MANAGER:RemoveBadge(ply)
	end

	local mimic_body = ply:GetMimicBody()
	if mimic_body then
		SafeRemoveEntity(mimic_body)
		ply:SetMimicBody(nil)
	end

	ply:SetTeam(TEAM_SPEC)
	self:SetPlayerToSpec( ply )
	
	GAMEMODE:CheckGameState()
end


hook.Add( "EntityTakeDamage", "AOTM_EntityTakeDamage_Player", function(target, dmg)
	if target:GetClass() == "player" and string.StartWith(dmg:GetAttacker():GetClass(), "prop_physics") then
		dmg:ScaleDamage(0.025)
	end
end )

//We don't want players killing themselves if they're a spectator.
function GM:CanPlayerSuicide(ply)
	print(ply:GetName(),"attempted to suicide.")
	return false
end

//prevent players from respawning after death.
function GM:PlayerDeathThink()
	return false 
end

//We don't want players to do the hl2 beep death sound.
function GM:PlayerDeathSound() return true end


local BAD_ACTS = {
	ACT_GMOD_GESTURE_AGREE,
	ACT_GMOD_GESTURE_BECON,
	ACT_GMOD_GESTURE_BOW,
	ACT_GMOD_GESTURE_DISAGREE,
	ACT_GMOD_TAUNT_SALUTE,
	ACT_GMOD_GESTURE_WAVE,
	ACT_GMOD_TAUNT_PERSISTENCE,
	ACT_GMOD_TAUNT_MUSCLE,
	ACT_GMOD_TAUNT_LAUGH,
	ACT_GMOD_GESTURE_POINT,
	ACT_GMOD_TAUNT_CHEER
}
//prevent players from using the "act" console command.
function GM:PlayerShouldTaunt(ply, act)
	local is_bad = table.HasValue(BAD_ACTS, act)
	if is_bad then
		ply:PrintMessage(HUD_PRINTTALK, "Nope.")
	end
	return not is_bad
end