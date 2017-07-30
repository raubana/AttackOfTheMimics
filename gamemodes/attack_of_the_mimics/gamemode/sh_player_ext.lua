
local plymeta = FindMetaTable( "Player" )
if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end


function plymeta:GetMimicBody()
	return self:GetNWEntity("MimicBody")
end


function plymeta:GetIsTired()
	return self:GetNWBool("IsTired")
end


function plymeta:GetEnergy()
	return self:GetNWFloat("Energy")
end


print( "sh_player_ext ran")