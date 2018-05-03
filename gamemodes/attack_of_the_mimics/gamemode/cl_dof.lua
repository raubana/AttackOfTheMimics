print("running")

local QUALITY = 1.0

-- TODO: Find a way to modify the quality in realtime.

local function SourceUnit2Inches( x )
	return x * 0.75
end

local function Inches2SourceUnits( x )
	return x / 0.75
end

local DOF_LENGTH = 512
local DOF_LAYERS = math.ceil((ScrH()*QUALITY)/50)

local MAX_FOCAL_LENGTH = 1024*2

local focal_length = focal_length or 256
local FOCAL_LENGTH_RATE = 0.1
local next_focal_length = next_focal_length or 256
local next_trace = 0

local QUAD_WIDTH = 100000
local QUAD_HEIGHT = 100000

local color_mask_1 = Color(0,0,0,0)
local color_mask_2 = Color(0,0,0,0)

local blurMat = Material( "pp/videoscale" )
local debugMat = Material( "attack_of_the_mimics/debug/dof_test_image" )

local USE_SPHERES = false
local ENABLED = true
local DOF_DEBUG = false
local DOF_DEBUG_FORCE_FOCAL_LENGTH = Inches2SourceUnits(0*12) -- set to 0 to disable


local sprite_size = 96
local real_sprite_size = Inches2SourceUnits(2)
local dist_increase_rate = 2
local num_test_images = 12
local skip_count = 3
local assumed_fov = 60

local function drawDebugImage(pos, ang, size)
	render.SetMaterial(debugMat)
	render.DrawQuadEasy(pos, -ang:Forward(), size, size, color_white, 0)
end

local function calc_viewing_distance(fov,screen_width)
	return screen_width/(2*math.tan(math.rad(fov)/2))
end


hook.Add( "PostDrawOpaqueRenderables", "AOTM_PostDrawOpaqueRenderables_DOF", function(isDrawingDepth, isDrawingSkybox)
	if DOF_DEBUG then
		local eye_angles = EyeAngles()
		local eye_pos = EyePos()
		local scrw = ScrW()
		local scrh = ScrH()
		
		local viewing_distance = calc_viewing_distance(assumed_fov, (scrh*4)/3)
	
		render.OverrideDepthEnable(true, true)
		
		local screen_y = scrh*0.5
		for i = 1+skip_count, num_test_images do
			local p = (i-1-skip_count)/(num_test_images-1-skip_count)
			local screen_x = Lerp(p, scrw*0.25, scrw*0.75)
			
			local dist = math.pow(dist_increase_rate,i-1)
			
			local true_x = (dist*(screen_x-(scrw/2)))/viewing_distance
			local true_size = (dist*(sprite_size))/viewing_distance
			
			local true_y = (dist*((scrh*0.75)-(scrh/2)))/viewing_distance
			drawDebugImage( 
				eye_pos
				+ eye_angles:Forward()*dist
				+ eye_angles:Right()*true_x
				+ eye_angles:Up()*true_y,
				eye_angles,
				real_sprite_size
			)
			
			drawDebugImage( 
				eye_pos
				+ eye_angles:Forward()*dist
				+ eye_angles:Right()*true_x,
				eye_angles,
				true_size
			)
		end
		
		render.OverrideDepthEnable(false, true)
	end
end )



local function drawLengthUnits( label, units, posx, posy, offset_y )
	local real_length = SourceUnit2Inches(units)
	
	surface.SetTextPos( posx, posy )
	surface.DrawText(label)
	surface.SetTextPos( posx, posy+offset_y )
	surface.DrawText(tostring(math.Round(units,3)) .. " su")
	surface.SetTextPos( posx, posy+(offset_y*2) )
	surface.DrawText(tostring(math.Round(real_length,3)).." in")
	surface.SetTextPos( posx, posy+(offset_y*3) )
	surface.DrawText(tostring(math.Round(real_length/12,3)).." ft")
end


hook.Add( "HUDPaint", "AOTM_HUDPaint_DOF", function()
	if DOF_DEBUG then
		local scrw = ScrW()
		local scrh = ScrH()
		surface.SetDrawColor(color_white)
		surface.SetTextColor(color_white)
		surface.SetFont("HudHintTextLarge")
		
		local viewing_distance = calc_viewing_distance(assumed_fov, (scrh*4)/3)
		
		drawLengthUnits("FOCAL LENGTH", focal_length, 50, 50, 16)
		drawLengthUnits("TOP SIZE", real_sprite_size, 50, 150, 16)
		
		local screen_y = scrh*0.5
		for i = 1+skip_count, num_test_images do
			local p = (i-1-skip_count)/(num_test_images-1-skip_count)
			local screen_x = Lerp(p, scrw*0.25, scrw*0.75)
			
			dist = math.pow(dist_increase_rate,i-1)
			
			local true_size = (dist*(sprite_size))/viewing_distance
			
			drawLengthUnits("DIST", dist, screen_x-(sprite_size/2), screen_y+(sprite_size/2), 16)
			drawLengthUnits("SIZE", true_size, screen_x-(sprite_size/2), screen_y+(sprite_size/2)+(16*5), 16)
		end
	end
end )


-- TODO: Make this work better with the offset.
local curve_limit = 6 --6 is good. lower numbers are good for making things seem smaller than they are.
local curve_rate = 3 --3 is good
local curve_offset = 4 --4 is good

local function DoFFunction( p, focal_length )
	--return focal_length*p*2 --linear. looks like a dream. don't use.
	
	return curve_offset+focal_length*(math.pow(curve_rate, Lerp(p,-curve_limit,curve_limit)))
end


hook.Add( "PreDrawEffects", "AOTM_PreDrawEffects_DOF", function()
	if AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets or not ENABLED then return end
	
	local result = hook.Call("AOTM_SuppressDOF")
	if result == true then return end
	
	local localplayer = LocalPlayer()
	
	if not IsValid(localplayer) then return end
	
	if localplayer:Team() == TEAM_SPEC then return end
	
	local cam_pos = EyePos()
	local cam_normal = EyeVector()
	local cam_angle = EyeAngles()
	
	local realtime = RealTime()
	local realframetime = RealFrameTime()
	
	if DOF_DEBUG_FORCE_FOCAL_LENGTH == 0 then
		if realtime >= next_trace then
			local size = Vector(1,1,1)*1
		
			local tr = util.TraceHull({
				start = cam_pos,
				endpos = cam_pos + cam_normal*MAX_FOCAL_LENGTH,
				filter = localplayer,
				mins = -size,
				maxs = size
			})
			
			if tr.Hit then
				next_focal_length = cam_pos:Distance(tr.HitPos)
			else
				next_focal_length = MAX_FOCAL_LENGTH
			end
			
			next_trace = realtime + 0.1
		end
		
		if next_focal_length < focal_length then
			focal_length = Lerp(math.pow(FOCAL_LENGTH_RATE/64, realframetime), next_focal_length, focal_length)
		else
			focal_length = Lerp(math.pow(FOCAL_LENGTH_RATE, realframetime), next_focal_length, focal_length)
		end
	else
		focal_length = DOF_DEBUG_FORCE_FOCAL_LENGTH
	end
	

	render.SetStencilEnable(true)
		
	render.SetStencilTestMask(255)
	render.SetStencilWriteMask(255)
	
	render.ClearStencil()
	
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	
	render.SetStencilReferenceValue( 1 )
	
	render.SetColorMaterial()
		
	render.OverrideDepthEnable( true, false )
	
	for i = 1, DOF_LAYERS do
		local p = i/DOF_LAYERS
		
		-- Stage 1 (Makes distant stuff blurry)
		render.SetStencilPassOperation( STENCILOPERATION_INCR )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		
		local dist = DoFFunction((p+1)/2, focal_length)
		if dist < 3000 then
			if not USE_SPHERES then
				render.DrawQuadEasy(
					cam_pos + cam_normal * dist, 
					-cam_normal,
					QUAD_WIDTH,
					QUAD_HEIGHT,
					color_mask_1,
					cam_angle.roll
				)
			else
				render.DrawSphere(cam_pos, -dist, 12, 4, color_mask_1)
			end
		end
		
		-- Stage 2 (Makes close stuff blurry)
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_INCR )
		
		local dist = DoFFunction(p/2, focal_length)
		if dist > 1 then
			if not USE_SPHERES then
				render.DrawQuadEasy(
					cam_pos + cam_normal * dist, 
					-cam_normal,
					QUAD_WIDTH,
					QUAD_HEIGHT,
					color_mask_2,
					cam_angle.roll
				)
			else
				render.DrawSphere(cam_pos, -dist, 12, 4, color_mask_2)
			end
		end
	end
	
	render.OverrideDepthEnable( false, false )
	
	cam.Start2D()
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_LESS )
		
		for i = 1, DOF_LAYERS do
			render.SetStencilReferenceValue( i )
			local amount = math.pow(i/(DOF_LAYERS*QUALITY), 1.25)*8+0.5
			blurMat:SetFloat("$scale", amount)
	
			render.UpdateScreenEffectTexture()
			render.SetMaterial(blurMat)
			render.DrawScreenQuad()
		end
	cam.End2D()
	
	render.SetStencilEnable(false)
	
	-- render.DrawStencilTestColors(true, DOF_LAYERS)
end )