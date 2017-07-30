local plymeta = FindMetaTable( "Player" )
if not plymeta then Error("FAILED TO FIND PLAYER TABLE") return end


function plymeta:SetMimicBody( ent )
	self:SetNWEntity("MimicBody", ent)
end


function plymeta:SetIsTired(bool)
	self:SetNWBool("IsTired", bool)
end


function plymeta:SetEnergy(float)
	self:SetNWFloat("Energy", float)
end



print( "sv_player_ext ran")