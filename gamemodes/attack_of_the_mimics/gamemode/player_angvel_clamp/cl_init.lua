include("shared.lua")


local SPEED = 360


local function angle_dif_abs(a, b)
	return math.min((a-b)%360, (b-a)%360)
end


local function ang_dist(angle1, angle2)
	local x = angle_dif_abs(angle1.pitch, angle2.pitch)
	local y = angle_dif_abs(angle1.yaw, angle2.yaw)
	return math.sqrt(math.pow(x,2) + math.pow(y,2))
end


local function randomOffsetAngle(distance)
	local ang = math.random()*360
	return Angle(math.cos(ang)*distance, math.sin(ang)*distance, 0)
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


hook.Add( "Think", "AOTM_Think_PlayerAngVelClamp", function()
	local localplayer = LocalPlayer()
	
	if IsValid(localplayer) then
		local current_angle = localplayer:EyeAngles()
	
		if localplayer:Team() != TEAM_SPEC then
			local t = RealFrameTime()
			
			if not isangle(localplayer.target_view_angle) then
				localplayer.target_view_angle = current_angle
			end
			if not isangle(localplayer.prev_view_angle) then
				localplayer.prev_view_angle = current_angle
			end
			
			local pitch_delta = current_angle.pitch - localplayer.prev_view_angle.pitch
			local yaw_delta = current_angle.yaw - localplayer.prev_view_angle.yaw
			
			if math.abs(yaw_delta) > 180 then
				-- we assume we crossed the 180/-180 threshold.
				if current_angle.yaw < 0 then
					yaw_delta = (current_angle.yaw + 360) - localplayer.prev_view_angle.yaw
				else
					yaw_delta = current_angle.yaw - (localplayer.prev_view_angle.yaw+360)
				end
			end
			
			localplayer.target_view_angle = Angle(
				math.Clamp( localplayer.target_view_angle.pitch + pitch_delta, -89, 89 ),
				localplayer.target_view_angle.yaw + yaw_delta,
				0
			)
			
			local speed = SPEED * t
			
			local dist = ang_dist(localplayer.target_view_angle, localplayer.prev_view_angle)
			
			local new_angle
			if dist < speed then
				new_angle = localplayer.target_view_angle
			else
				local p = speed/dist
				new_angle = Angle(
					lerpPitch(p, localplayer.prev_view_angle.pitch, localplayer.target_view_angle.pitch),
					lerpYaw(p, localplayer.prev_view_angle.yaw, localplayer.target_view_angle.yaw),
					0
				)
			end
			
			localplayer:SetEyeAngles(new_angle)
			localplayer.prev_view_angle = new_angle
		else
			localplayer.target_view_angle = current_angle
			localplayer.prev_view_angle = current_angle
		end
	end
end )


print("player_angvel_clamp cl_init")