include("shared.lua")
include("render.lua")
include("camera_manager/cl_init.lua")
-- include("eye_projection/cl_init.lua")
include("voice_manager/cl_init.lua")
include("walkietalkie_manager/cl_init.lua")
include("task_manager/cl_init.lua")
include("doorkey_manager/cl_init.lua")
include("flashlight_manager/cl_init.lua")
include("idbadge_manager/cl_init.lua")
include("mimicchatter_manager/cl_init.lua")
include("music_manager/cl_init.lua")

include("ear_static/cl_init.lua")
include("player_angvel_clamp/cl_init.lua")

include("cl_teamselect.lua")
include("cl_dof.lua")

include("cinematic_modules/cl_init.lua")



local pad = 3

local color_hud_white = Color(128,128,128)
local color_green = Color(0,255,0)
local color_red = Color(255,0,0)

local function drawStat(i, p, color, str, prev_p)
	if prev_p == nil then prev_p = p end

	local scrw = ScrW()
	local scrh = ScrH()
	
	local bottom = scrh - 20
	local top = bottom - scrh*0.15
	local right = scrw - (10 + (30+5)*i)
	local left = right - (20+5)
	
	surface.SetDrawColor(color)
	surface.DrawRect(left-pad, top-2-pad, (right-left)+(pad*2), (bottom-top)+(pad*2)+2+20)
	
	surface.SetDrawColor(color_hud_white)
	surface.DrawRect(left, top-2, right-left, 1)
	
	local new_top_1 = math.ceil(Lerp(p,bottom-1,top))
	
	surface.DrawRect(left, new_top_1, right-left, bottom-new_top_1)
	
	if prev_p != p then
		if p > prev_p then
			surface.SetDrawColor(color_green)
		else
			surface.SetDrawColor(color_red)
		end
		
		local new_top_2 = math.ceil(Lerp(prev_p,bottom-1,top))
		local dif = math.abs(new_top_1-new_top_2)
		
		new_top_2 = math.min(new_top_1, new_top_2)
		
		surface.DrawRect(left, new_top_2, right-left, dif)
	end
	
	surface.SetFont("BudgetLabel")
	surface.SetTextColor(color_hud_white)
	surface.SetTextPos(left, bottom)
	surface.DrawText(str)
end


local start_energy = 1
local end_energy = 1

--[[
local prox_sense = 0.0
local real_prox_sense = 0.0
]]

local scream_cooldown = 1


net.Receive( "AOTM_ProxSense", function(len, ply)
	real_prox_sense = net.ReadFloat()
end )


function GM:HUDPaint()
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) then return end
	
	local stage = GetGlobalInt("stage")
	local stage_duration = GetGlobalFloat("stage_duration", -1)
	local stage_starttime = GetGlobalFloat("stage_starttime", 0)
	
	if stage_duration > 0 and (stage == STAGE_READY or stage == STAGE_POSTROUND) then
		local curtime = CurTime()
		local stage_length = math.max((stage_duration+stage_starttime) - CurTime(), 0)
		
		surface.SetFont( "DermaLarge" )
		local text = tostring(math.min(math.floor(stage_length)))
		local tw,th = surface.GetTextSize(text)
		surface.SetTextColor( color_white )
		surface.SetTextPos( (ScrW()-tw)/2, ScrH()-th-2 )
		surface.DrawText( text )
	end
	
	local t = localplayer:Team()
	
	if t != TEAM_SPEC and stage == STAGE_ROUND then
		local realtime = RealTime()
	
		local caution_blink = Lerp(1-(realtime%5/5), 0.33, 1.0)
		local warning_blink = Lerp(1-(realtime%0.5/0.5), 0.25, 1.0)
		local danger_blink = Lerp(1-(realtime%0.25/0.25), 0.0, 1.0)
		
		local realframetime = RealFrameTime()
		
		local trans_amount = realframetime*0.01
		local nrg = localplayer:GetEnergy()/100.0
		end_energy = nrg
		
		local nrg_dif = math.abs(end_energy - start_energy)
		if start_energy < end_energy then
			start_energy = end_energy --math.min(end_energy, start_energy + trans_amount)
		else
			start_energy = math.max(end_energy, start_energy - trans_amount)
		end
		
		trans_amount = realframetime*0.01
		-- prox_sense = math.Approach(prox_sense, real_prox_sense, trans_amount)
		
		local h, s, v, color
		
		-- ENERGY
		h = 60
		s = 1.0
		v = 0.0
		if localplayer:GetIsTired() then
			h = 0
			v = Lerp(danger_blink, 0.1, 0.75)
		elseif end_energy < 0.33 then
			v = danger_blink*0.75
		-- elseif end_energy < 0.75 then
		--	v = caution_blink*0.5
		end
		
		color = HSVToColor(h,s,v)
		drawStat(0,end_energy,color,"NRG",start_energy)
		
		-- PROXIMITY SENSE
		if t == TEAM_MIMIC then
			-- drawStat(1,prox_sense,color_black,"PRX")
			scream_cooldown = (CurTime() - (localplayer:GetActiveWeapon().scream_init or 0)) / localplayer:GetActiveWeapon().Scream.Delay;
			drawStat(2,scream_cooldown,color_black, "SCR")
		end
	end
end


local nightvision_active = false
local nightvision_transition = SMOOTH_TRANS:create(1.0)

function GM:Think()
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) then return end
	
	local t = localplayer:Team()
	
	if t != TEAM_MECHANIC then
		local lighting = render.ComputeLighting(localplayer:GetPos()+Vector(0,0,42), vector_up)
		local brightness = math.min(lighting.x, lighting.y, lighting.z)
		
		if nightvision_active then
			if brightness > 0.075 then
				nightvision_active = false
			end
		else
			if brightness < 0.05 then
				nightvision_active = true
			end
		end
		
		nightvision_transition:SetDirection(nightvision_active)
		nightvision_transition:Update()
		
		local p = nightvision_transition:GetPercent()
		
		local brightness_m = 1.0
		local size = 512
		if t == TEAM_MIMIC then
			size = 64
			brightness_m = 5.0
		end
		
		if nightvision_active then
			local dlight = DynamicLight( localplayer:EntIndex() + 1 )
			if ( dlight ) then
				dlight.pos = localplayer:GetPos()+Vector(0,0,25)
				dlight.r = 255*p
				dlight.g = 4*p
				dlight.b = 4*p
				dlight.brightness = brightness_m
				dlight.Decay = 1000
				dlight.Size = size
				dlight.DieTime = CurTime() + 1.0
			end
		end
	end
end


local prng = PerlinNoiseGenerator:create()
local thirdperson_active = true
local thirdperson_trans = SMOOTH_TRANS:create(2.0)

local next_thirdperson_trace = 0
local thirdperson_trace_freq = 0.25
local last_thirdperson_dist = 0

local thirdperson_dist = 0

function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )
	local t = ply:Team()
	
	local origin = pos
	local angles = ang
	local fov = fov
	local znear = nearZ
	local zfar = farZ
	local drawviewer = false
	
	if ply:Team() != TEAM_SPEC then
		local time = RealTime()
	
		local pitch_offset = Lerp(prng:GenPerlinNoise(time + 13,0.5,1.0,1), -2, 2)
		local yaw_offset = Lerp(prng:GenPerlinNoise(time + 71,0.5,1.0,1), -2, 2)
		
		-- roll can cause motion sickness.
		
		angles.pitch = angles.pitch + pitch_offset
		angles.yaw = angles.yaw + yaw_offset
	end
	
	thirdperson_trans:SetDirection(thirdperson_active)
	thirdperson_trans:Update()
	
	if ply:Team() == TEAM_MIMIC then
		local make_visible = false
		
		local p = thirdperson_trans:GetPercent()
		
		if p > 0 then
			local realtime = RealTime()
			
			if p < 1 then
				p = ((-math.cos(math.pi*p))+1)/2
			end
			
			if realtime >= next_thirdperson_trace then
				local tr = util.TraceHull({
					start = ply:EyePos(),
					endpos = ply:EyePos() - (angles:Forward()*90*p),
					mins = Vector(1,1,1)*-15,
					maxs = Vector(1,1,1)*15,
					filter = {ply},
					mask = MASK_ALL
				})
				
				last_thirdperson_dist = tr.StartPos:Distance(tr.HitPos)
				
				next_thirdperson_trace = realtime + (1/60)
			end
			
			thirdperson_dist = Lerp(1-math.pow(0.000001,RealFrameTime()), thirdperson_dist, last_thirdperson_dist)
		
			-- angles:RotateAroundAxis(angles:Right(),-45)
			local new_origin = ply:EyePos() - (angles:Forward()*thirdperson_dist)
			local new_fov = 90
			
			make_visible = true
			
			if p < 1 then
				origin = LerpVector(p, origin, new_origin)
				fov = Lerp(p, fov, new_fov)
			else
				origin = new_origin
				fov = new_fov
			end
			
			drawviewer = true
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


hook.Add("PlayerBindPress", "AOTM_PlayerBindPress_ClInit", function(ply, bind, pressed)
	if bind == "+walk" then
		thirdperson_active = not thirdperson_active
	end
end)


function GM:HUDDrawTargetID() -- we don't want a player's ID to be visible.
end


function GM:PrePlayerDraw( ply )
	local is_visible = ply:Team() != TEAM_MIMIC
	ply:DrawShadow(is_visible)

	return not is_visible
end