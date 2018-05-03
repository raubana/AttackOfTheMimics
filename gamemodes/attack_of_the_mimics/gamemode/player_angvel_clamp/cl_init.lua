include("shared.lua")

local SPEED = 250
local EASE_THRESHOLD = 50.0
local EASE_RATE = 0.99


local function angle_dif_abs(a, b)
	return math.min((a-b)%360, (b-a)%360)
end


local function ang_dist(angle1, angle2)
	local x = angle_dif_abs(angle1.pitch, angle2.pitch)
	local y = angle_dif_abs(angle1.yaw, angle2.yaw)
	return math.sqrt(math.pow(x,2) + math.pow(y,2))
end


local function overlerp(p,a,b)
	return a+(b-a)*p
end


local function lerpPitch(p, ang1, ang2)
	//ang1 = (ang1+180)%360-180
	//ang2 = (ang2+180)%360-180
	return overlerp(p, ang1, ang2)
end


local function lerpYaw(p, ang1, ang2)
	ang1 = (ang1+180)%360
	ang2 = (ang2+180)%360
	if ang2 > ang1 + 180 then
		ang2 = ang2 - 360
	elseif ang2 < ang1 - 180 then
		ang2 = ang2 + 360
	end
	return overlerp(p, ang1, ang2)-180
end


hook.Add( "StartCommand", "AOTM_StartCommand_PlayerAngVelClamp", function(ply, ucmd)
	local current_angle = ply:EyeAngles()

	if ply:Team() != TEAM_SPEC then
		local t = RealFrameTime()
		
		if not isangle(ply.target_view_angle) then
			ply.target_view_angle = current_angle
		end
		if not isangle(ply.prev_view_angle) then
			ply.prev_view_angle = current_angle
		end
		
		local pitch_delta = current_angle.pitch - ply.prev_view_angle.pitch
		local yaw_delta = current_angle.yaw - ply.prev_view_angle.yaw
		
		if math.abs(yaw_delta) > 180 then
			-- we assume we crossed the 180/-180 threshold.
			if current_angle.yaw < 0 then
				yaw_delta = (current_angle.yaw + 360) - ply.prev_view_angle.yaw
			else
				yaw_delta = current_angle.yaw - (ply.prev_view_angle.yaw+360)
			end
		end
		
		ply.target_view_angle = Angle(
			math.Clamp( ply.target_view_angle.pitch + pitch_delta, -89, 89 ),
			ply.target_view_angle.yaw + yaw_delta,
			0
		)
		
		local travel_dist = SPEED * t
		
		local dist = ang_dist(ply.target_view_angle, ply.prev_view_angle)
		
		local new_angle
		local p
		--print("START", dist)
		if dist-travel_dist <= EASE_THRESHOLD then
			--print("A")
			if dist > EASE_THRESHOLD then
				--print("A2")
				-- we find out at what time the transition would have changed from
				-- linear to easing.
				local time_to_trans = (dist-EASE_THRESHOLD)/SPEED
				t = t - time_to_trans
				p = (EASE_THRESHOLD-dist)/(-dist)
				ply.prev_view_angle = Angle(
					lerpPitch(p, ply.prev_view_angle.pitch, ply.target_view_angle.pitch),
					lerpYaw(p, ply.prev_view_angle.yaw, ply.target_view_angle.yaw),
					0
				)
			end
			p = 1-math.pow(1-EASE_RATE,t)
		else
			--print("B")
			if travel_dist > dist then
				--print("B1")
				p = 1.0
			else
				--print("B2")
				p = travel_dist/dist
			end
		end
		--print("END", p)
		
		
		if isnumber(p) then
			new_angle = Angle(
				lerpPitch(p, ply.prev_view_angle.pitch, ply.target_view_angle.pitch),
				lerpYaw(p, ply.prev_view_angle.yaw, ply.target_view_angle.yaw),
				0
			)
			
			ply:SetEyeAngles(new_angle)
			ply.prev_view_angle = new_angle
			
			ucmd:SetViewAngles(new_angle)
		end
	else
		ply.target_view_angle = current_angle
		ply.prev_view_angle = current_angle
	end
end )


--[[
hook.Add( "CalcViewModelView", "AOTM_CalcViewModelView_PlayerAngVelClamp", function( wep, vm, oldPos, oldAng, pos, ang )
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) then return end
	
	local pitch_delta = ang.pitch - oldAng.pitch
	local yaw_delta = ang.yaw - oldAng.yaw
	
	if math.abs(yaw_delta) > 180 then
		-- we assume we crossed the 180/-180 threshold.
		if ang.yaw < 0 then
			yaw_delta = (ang.yaw + 360) - oldAng.yaw
		else
			yaw_delta = ang.yaw - (oldAng.yaw+360)
		end
	end
	
	local new_angle = Angle(
		localplayer.target_view_angle.pitch + pitch_delta,
		localplayer.target_view_angle.yaw + yaw_delta,
		0
	)
	
	return oldPos, new_angle
end )
]]


local spriteMat = Material("attack_of_the_mimics/vgui/misc/view_angle_sprite")

hook.Add( "HUDPaint", "AOTM_HUDPaint_PlayerAngVelClamp", function()
	local localplayer = LocalPlayer()
	
	if not IsValid(localplayer) then return end
	
	if localplayer:Team() == TEAM_SPEC then return end

	local dist = ang_dist(localplayer.target_view_angle, localplayer.prev_view_angle)
	local p = math.Clamp((dist-15)/90,0,1)
	
	if p > 0 then
		local size = ScrH()/10
		local data = (localplayer:EyePos() + localplayer.target_view_angle:Forward()*10000):ToScreen()
		
		if data.visible then
			surface.SetDrawColor(Color(255,255,255,128*p))
			surface.SetMaterial(spriteMat)
			surface.DrawTexturedRect(data.x-(size/2), data.y-(size/2), size, size)
		end
	end
end )


print("player_angvel_clamp cl_init")