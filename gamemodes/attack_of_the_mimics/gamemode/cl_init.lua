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



include("mode_echolocation/cl_init.lua")



local start_energy = 1
local end_energy = 1

local prox_sense = 0.0
local real_prox_sense = 0.0


net.Receive( "AOTM_ProxSense", function(len, ply)
	real_prox_sense = net.ReadFloat()
end )

local nightvision_active = false
local nightvision_transition = SMOOTH_TRANS:create(0.5)

function GM:Think()
	local localplayer = LocalPlayer()
	if not IsValid(localplayer) then return end
	
	for i = 0, 2 do
		localplayer:DrawViewModel(false, i)
	end
	
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
local groundtoggle_trans = SMOOTH_TRANS:create(0.25)

local next_thirdperson_trace = 0
local thirdperson_trace_freq = 0.25
local last_thirdperson_dist = 0

local thirdperson_dist = 0

local headbob_cycle_total = 0


function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )
	local t = ply:Team()
	
	local origin = pos
	local angles = ang
	local fov = fov
	local znear = nearZ
	local zfar = farZ
	local drawviewer = false
	
	local realtime = RealTime()
	local realframetime = RealFrameTime()
	
	fov = 60
	
	local is_on_ground = ply:IsOnGround()
	groundtoggle_trans:SetDirection(is_on_ground)
	groundtoggle_trans:Update()
	local groundtoggle_p = groundtoggle_trans:GetPercent()
	
	local vel = ply:GetVelocity():Length()
	if vel > 0 and is_on_ground and groundtoggle_p > 0 then
		local increase_by = math.max(math.log((math.min(vel,600)/235000)+1, 1.1),0)*200*realframetime*groundtoggle_p
		headbob_cycle_total = (headbob_cycle_total+increase_by)%1.0
	end
	
	if t != TEAM_SPEC then
		-- subtle movement
		local pitch_offset = Lerp(prng:GenPerlinNoise(realtime + 13,0.6,1.0,1), -1, 1)
		local yaw_offset = Lerp(prng:GenPerlinNoise(realtime + 37,0.5,1.0,1), -1, 1)
		local roll_offset = 0.0
		-- roll can cause motion sickness. use carefully.
		
		if groundtoggle_p > 0 then
			-- running/walking animation
			local effect_scale = math.min(vel/600, 1)*groundtoggle_p
			if vel > 0 then
				pitch_offset = pitch_offset + math.sin((headbob_cycle_total+0.25)*math.pi*4) * effect_scale * 1
			
				local yawroll_offset = math.sin((headbob_cycle_total+0.5)*math.pi*2) * effect_scale * 2
				yaw_offset = yaw_offset + yawroll_offset*0.25
				roll_offset = roll_offset - yawroll_offset*0.1
			end
		end
		
		angles.pitch = angles.pitch + pitch_offset
		angles.yaw = angles.yaw + yaw_offset
		angles.roll = angles.roll + roll_offset
	end
	
	thirdperson_trans:SetDirection(thirdperson_active)
	thirdperson_trans:Update()
	
	if t == TEAM_MIMIC then
		local make_visible = false
		
		local p = thirdperson_trans:GetPercent()
		
		if p > 0 then
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
			
			thirdperson_dist = Lerp(1-math.pow(0.000001,realframetime), thirdperson_dist, last_thirdperson_dist)
		
			-- angles:RotateAroundAxis(angles:Right(),-45)
			local new_origin = ply:EyePos() - (angles:Forward()*thirdperson_dist)
			-- local new_fov = 50
			
			make_visible = true
			
			if p < 1 then
				origin = LerpVector(p, origin, new_origin)
				-- fov = Lerp(p, fov, new_fov)
			else
				origin = new_origin
				-- fov = new_fov
			end
			
			drawviewer = true
		end
		
		local mimic_body = ply:GetMimicBody()
		
		if IsValid(mimic_body) then
			mimic_body.do_not_draw = not make_visible
		end
	end
	
	if t != TEAM_SPEC then
		-- subtle movement
		local x_offset = Lerp(prng:GenPerlinNoise(realtime + 51,1.9,1.0,1), -0.1, 0.1)
		local y_offset = Lerp(prng:GenPerlinNoise(realtime + 51,2,1.0,1), -0.1, 0.1)
		local z_offset = Lerp(prng:GenPerlinNoise(realtime + 57,0.9,1.0,1), -0.5, 0.5)
		
		-- running/walking animation
		if groundtoggle_p > 0 then
			local effect_scale = math.min(vel/600, 1)
			
			x_offset = x_offset + math.sin(headbob_cycle_total*math.pi*2) * effect_scale * groundtoggle_p
			y_offset = y_offset + math.abs(math.sin(headbob_cycle_total*math.pi*2)) * (effect_scale) * (Lerp((effect_scale-0.2)/0.1,2,0) + Lerp(effect_scale,0,5)) * groundtoggle_p
			
			-- vertical bobbing is a weird thing.
			-- It starts out strong, gets weaker, then gets strong again.
			-- It depends on the pace.
		end
		
		-- head offset
		y_offset = y_offset + 4
		z_offset = z_offset + 2
		
		origin = origin + (angles:Forward()*z_offset)
		origin = origin + (angles:Up()*y_offset)
		origin = origin + (angles:Right()*x_offset)
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


local HUDhide = {
	CHudBattery = 1,
	CHudAmmo = 2,
	-- CHudHealth = 2
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	local val = HUDhide[ name ] 
	if val then
		return false
	end
end )


-- This is a pseudo-super-sampling effect!
--[[
local PSEUDO_SS_ENABLED = false

local name = "AOTM_CLIENT_FINAL"
local final_texture = GetRenderTarget(name, ScrW()*0.25, ScrH()*0.25, false)
local mat_data = {}
local final_mat = final_mat
if not final_mat then
	final_mat = CreateMaterial(name, "UnlitGeneric", mat_data)
end


local blurMat = Material( "pp/videoscale" )
hook.Add( "PreDrawHUD", "AOTM_PreDrawHUD_ClInit", function()
	if not PSEUDO_SS_ENABLED then return end
	
	render.CheapBlur( ScrW()*0.25*0.0025 )

	render.CopyRenderTargetToTexture(final_texture)
	
	final_mat:SetTexture("$basetexture",final_texture)
	
	render.PushFilterMag( TEXFILTER.POINT )
	
	surface.SetDrawColor(color_white)
	surface.SetMaterial(final_mat)
	surface.DrawTexturedRect(
		0,
		0,
		ScrW(),
		ScrH()
	)
	
	render.PopFilterMag( )
end )
]]


hook.Add( "PrePlayerDraw", "AOTM_CL_PrePlayerDraw", function(ply)
	if ply:Team() == TEAM_MECHANIC then
		ply:DisableMatrix("RenderMultiply")
	end
end )


-- ==========================================   2D   ======================== --



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
		
		local trans_amount = realframetime*0.02
		local nrg = localplayer:GetEnergy()/100.0
		end_energy = nrg
		local is_tired = localplayer:GetIsTired()
		
		local nrg_dif = math.abs(end_energy - start_energy)
		if start_energy < end_energy then
			start_energy = end_energy --math.min(end_energy, start_energy + trans_amount)
		else
			start_energy = math.max(end_energy, start_energy - trans_amount)
		end
		
		trans_amount = realframetime*0.25 -- 0.01
		prox_sense = math.Approach(prox_sense, real_prox_sense, trans_amount)
		
		local h, s, v, color
		
		-- ENERGY
		h = 60
		s = 1.0
		v = 0.0
		if is_tired then
			h = 0
			v = Lerp(danger_blink, 0.1, 0.75)
		elseif end_energy < 0.33 then
			v = danger_blink*0.75
		end
		
		color = HSVToColor(h,s,v)
		drawStat(0,end_energy,color,"NRG",start_energy)
		
		-- TODO: I need to make a hook for HUD elements for weapons.
		
		if t == TEAM_MIMIC then
			-- PROXIMITY SENSE
			drawStat(1,prox_sense,color_black,"PRX")
			-- SCREAM
			local scream_cooldown = (CurTime() - (localplayer:GetActiveWeapon().scream_init or 0)) / localplayer:GetActiveWeapon().Scream.Delay
			drawStat(2,scream_cooldown,color_black, "SCR")
		elseif t == TEAM_MECHANIC then
			-- TASER
			local wep = localplayer:GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "swep_aotm_taser" then
				local taser_cooldown = wep:GetCoolDown()/10.0
				local color = color_black
				if taser_cooldown < 1 then
					color = Color(128,0,0)
				end
				drawStat(1, taser_cooldown, color, "TSR")
			end
		end
	end
end