local thirdperson_active = thirdperson_active or false


function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )
	local t = ply:Team()
	
	local origin = pos
	local angles = ang
	local fov = fov
	local znear = nearZ
	local zfar = farZ
	local drawviewer = false
	
	if ply:Team() == TEAM_MIMIC then
		local make_visible = false
	
		if thirdperson_active then
			origin = ply:GetPos() - (angles:Forward()*75) + (angles:Up()*25)
			make_visible = true
			fov = 140
		end
		
		local mimic_body = ply:GetMimicBody()
		
		if IsValid(mimic_body) then
			mimic_body.do_not_draw = not make_visible
		end
	end
	
	return {origin = origin,
			angles = angles,
			fov = fov,
			znear = znear,
			zfar = zfar,
			drawviewer = drawviewer}
end


hook.Add("PlayerBindPress", "AOTM_PlayerBindPress_ClThirdPerson", function(ply, bind, pressed)
	if bind == "+walk" then
		thirdperson_active = not thirdperson_active
	end
end)


print("cl_thirdperson ran")