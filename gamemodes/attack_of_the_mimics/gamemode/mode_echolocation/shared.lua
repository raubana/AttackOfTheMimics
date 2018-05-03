
ECHO_HUE_BITS = 10
ECHO_SAT_BITS = 8
ECHO_THICK_BITS = 15
ECHO_RADIUS_BITS = 15


function getMiddleOfEnt(ent)
	local obbmins = ent:OBBMins()
	local obbmaxs = ent:OBBMaxs()

	return ent:GetPos() +
		Lerp(0.5, obbmins.x, obbmaxs.x) * ent:GetForward(),
		Lerp(0.5, obbmins.y, obbmaxs.y) * ent:GetRight(),
		Lerp(0.5, obbmins.z, obbmaxs.z) * ent:GetUp()
end


print("mode echolocation shared")