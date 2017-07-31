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

include("cl_teamselect.lua")
include("cl_thirdperson.lua")

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

local prox_sense = 0.0
local real_prox_sense = 0.0


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
		prox_sense = math.Approach(prox_sense, real_prox_sense, trans_amount)
		
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
			drawStat(1,prox_sense,color_black,"PRX")
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
		
		local size = 1024
		if t == TEAM_MIMIC then
			size = 256
		end
		
		if nightvision_active then
			local dlight = DynamicLight( localplayer:EntIndex() + 1 )
			if ( dlight ) then
				dlight.pos = localplayer:GetPos()+Vector(0,0,25)
				dlight.r = 64*p
				dlight.g = 8*p
				dlight.b = 8*p
				dlight.brightness = 1.0
				dlight.Decay = 1000
				dlight.Size = 1024
				dlight.DieTime = CurTime() + 1.0
			end
		end
	end
end


function GM:HUDDrawTargetID() -- we don't want a player's ID to be visible.
end