include("shared.lua")


-- local MODE_ENABLED = GetConVar("aotm_mode_echolocation")
local MODE_ENABLED = false

-- because convar replication is apparently broken, we have to instead use a
-- global variable.


local sound_detail_var = CreateClientConVar("aotm_mode_echolocation_sound_detail", "3", true, false, "How detailed should the sound spheres be. 1 through 6.")
local sound_detail_table = {5,7,11,17,25,33}

local echoes = echoes or {}

local echo_lifetime_per_radius = 0.001--0.0025

local next_looped_echo = 0

local color_green = Color(0,255,0)
local color_red = Color(255,0,0)
local color_mask = Color(0,0,0,0)


local function createTravelingSounds( pos, abs_radius, ring_thickness, wave_thickness, break_scale, hue, sat)
	table.insert(echoes, {
		pos = pos,
		abs_radius = abs_radius,
		ring_thickness = ring_thickness,
		wave_thickness = wave_thickness,
		break_scale = break_scale,
		start = RealTime(),
		lifetime = abs_radius*echo_lifetime_per_radius,
		color = HSVToColor(hue, sat, 1.0)
	})
end


net.Receive( "AOTM_SoundEmitted", function( len )
	local localplayer = LocalPlayer()

	local pos = net.ReadVector()
	local abs_radius = net.ReadInt(ECHO_RADIUS_BITS)
	local ring_thickness = net.ReadInt(ECHO_THICK_BITS)
	local wave_thickness = net.ReadInt(ECHO_THICK_BITS)
	local break_scale = net.ReadFloat()
	local hue = net.ReadInt(ECHO_HUE_BITS)
	local sat = net.ReadInt(ECHO_SAT_BITS)/100.0
	
	if IsValid(localplayer) then
		createTravelingSounds(pos, abs_radius, ring_thickness, wave_thickness, break_scale, hue, sat)
	end
end)


hook.Add( "Tick", "AOTM_Tick_ModeEcholocation", function()
	MODE_ENABLED = GetGlobalBool("aotm_mode_echolocation", false)

	local localplayer = LocalPlayer()
	
	if not IsValid(localplayer) then return end
	
	local localplayer_pos = localplayer:GetPos()
	
	if localplayer:Team() != TEAM_MECHANIC then
		local curtime = CurTime()
		
		if curtime >= next_looped_echo then
			next_looped_echo = curtime + 3.0
			
			-- put looping or long sound sources here
		end
		
		local i = #echoes
		local realtime = RealTime()
		
		while i > 0 do
			if realtime > echoes[i].start + echoes[i].lifetime then
				table.remove(echoes, i)
			end
			i = i - 1
		end
	end
end)


--[[
hook.Add( "AOTM_SuppressDOF", "AOTM_SuppressDOF_ModeEcholocation", function()
	if MODE_ENABLED then
		local localplayer = LocalPlayer()
		if IsValid(localplayer) and localplayer:Team() == TEAM_MIMIC then
			--return true
		end
	end
end )
]]


local function drawStencilSphere( pos, ref, compare_func, radius, color, detail )
	render.SetStencilReferenceValue( ref )
	render.SetStencilCompareFunction( compare_func )
	render.DrawSphere(pos, radius, detail, detail, color)
end



hook.Add( "PostDrawTranslucentRenderables", "AOTM_PostDrawTranslucentRenderables_ModeEcholocation", function(bDrawingDepth, bDrawingSkybox)
	if bDrawingSkybox or (not MODE_ENABLED) then return end
	
	local localplayer = LocalPlayer()
	local localplayer_pos = localplayer:EyePos()
	local t = localplayer:Team()
	
	if t != TEAM_MECHANIC then
		if t == TEAM_MIMIC then
			-- render.CheapBlur(math.min(ScrW(), ScrH())* 0.25 * 0.025 )
			
			local color_mod = {}
			color_mod["$pp_colour_addr"] = 0.0
			color_mod["$pp_colour_addg"] = 0.0
			color_mod["$pp_colour_addb"] = 0.0
			color_mod["$pp_colour_brightness"] = 0.0
			color_mod["$pp_colour_contrast"] = 0.75
			color_mod["$pp_colour_colour"] = 0.5
			color_mod["$pp_colour_mulr"] = 0.0
			color_mod["$pp_colour_mulg"] = 0.0
			color_mod["$pp_colour_mulb"] = 0.0
			
			DrawColorModify(color_mod)
		end
	
		local detail = sound_detail_table[math.Clamp(sound_detail_var:GetInt(), 1, #sound_detail_table)]
	
		local realtime = RealTime()
		
		render.SetStencilEnable(true)
		
		render.SetStencilTestMask(3)
		render.SetStencilWriteMask(3)
		
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )
		
		for i, echo in ipairs(echoes) do
			local dist = echo.pos:Distance(localplayer_pos)
		
			local opacity = ((echo.abs_radius - (dist*0.5))/echo.abs_radius) * 0.5
			local p = (realtime - echo.start) / (echo.lifetime)
			
			local echo_radius = echo.abs_radius*p
			
			if p < 1.0 and opacity > 0 then
				local breaks = math.ceil(echo.lifetime*echo.break_scale)+1
				local break_length = (echo.lifetime/breaks)/echo.lifetime
				
				local stutter_p = (math.floor(p * breaks) / breaks) + (1/breaks)
				local offset = echo.wave_thickness / echo.abs_radius
				local offset_p = (p-offset)
				local offset_stutter_p = (math.floor(offset_p * breaks) / breaks) + (1/breaks)
				
				local color = echo.color
				
				for i = math.max(math.floor(offset_stutter_p*breaks),0), math.ceil(p*breaks) do
					local ring_p = math.Clamp(((i/breaks)-offset_p)/offset, 0, 1)
					--[[
					local triangle_p = ring_p
					if triangle_p < 0.5 then
						triangle_p = triangle_p*2
					else
						triangle_p = 1-((triangle_p-0.5)*2)
					end
					]]
					
					local max_outer_r = Lerp((i/breaks), 0, echo.abs_radius)
					local outer_r = math.min(max_outer_r, echo_radius)
					local thickness = echo.ring_thickness - (max_outer_r-outer_r)
					local inner_r = math.max(outer_r-thickness,0)
					
					--local outer_r = Lerp((i/breaks), 0, echo.abs_radius) - (echo.ring_thickness*0.5*(1-triangle_p))
					--local inner_r = math.max(outer_r-(echo.ring_thickness*triangle_p),0)
					
					color.a = 255*opacity*ring_p*(1-p) --*(thickness/echo.ring_thickness)
				
					render.ClearStencil()
					
					render.SetColorMaterial()
					
					render.SetStencilZFailOperation( STENCILOPERATION_REPLACE )
					
					drawStencilSphere(echo.pos, 2, STENCILCOMPARISONFUNCTION_ALWAYS, -outer_r, color_mask, detail ) -- big, inside-out
					
					render.SetStencilZFailOperation( STENCILOPERATION_INCR )
					
					drawStencilSphere(echo.pos, 2, STENCILCOMPARISONFUNCTION_ALWAYS, outer_r, color_mask, detail ) -- big
					
					render.SetStencilZFailOperation( STENCILOPERATION_INCR )
					
					drawStencilSphere(echo.pos, 2, STENCILCOMPARISONFUNCTION_ALWAYS, -inner_r, color_mask, detail ) -- small, inside-out
					
					render.SetStencilZFailOperation( STENCILOPERATION_DECR )
					
					drawStencilSphere(echo.pos, 2, STENCILCOMPARISONFUNCTION_ALWAYS, inner_r, color_mask, detail ) -- small
					
					render.SetColorMaterialIgnoreZ()
					
					drawStencilSphere(echo.pos, 2, STENCILCOMPARISONFUNCTION_EQUAL, -outer_r, color, detail ) -- big, inside-out
				end
			end
		end
		
		render.SetStencilEnable(false)
	end
end)


hook.Add( "RenderScreenspaceEffects", "AOTM_RenderScreenspaceEffects_ModeEcholocation", function()
	if not MODE_ENABLED then return end

	local localplayer = LocalPlayer()
	local localplayer_pos = localplayer:EyePos()
	local t = localplayer:Team()
	
	if t == TEAM_MIMIC then
		--[[
		render.CheapBlur(math.min(ScrW(), ScrH())* 0.25 * 0.005 )
		
		local color_mod = {}
		color_mod["$pp_colour_addr"] = 0.0
		color_mod["$pp_colour_addg"] = 0.0
		color_mod["$pp_colour_addb"] = 0.0
		color_mod["$pp_colour_brightness"] = 0.0
		color_mod["$pp_colour_contrast"] = 1000.0
		color_mod["$pp_colour_colour"] = 1.0
		color_mod["$pp_colour_mulr"] = 0.0
		color_mod["$pp_colour_mulg"] = 0.0
		color_mod["$pp_colour_mulb"] = 0.0
		
		DrawColorModify(color_mod)
		
		render.CheapBlur(math.min(ScrW(), ScrH())* 0.25 * 0.005 )
		]]
	end
end )


print("mode echolocation cl_init")