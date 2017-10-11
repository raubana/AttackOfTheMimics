print("running")


local DOF_LENGTH = 512
local DOF_LAYERS = math.ceil(ScrH()/200)

local MAX_FOCUS_DIST = 768

local focus_dist = 256
local next_focus_dist = 256
local next_trace = 0

local QUAD_WIDTH = 100000
local QUAD_HEIGHT = 100000

local color_mask_1 = Color(255,0,0,0)
local color_mask_2 = Color(0,0,255,0)

local blurMat = Material( "pp/videoscale" )

hook.Add( "PreDrawEffects", "AOTM_PreDrawEffects_DOF", function()
	if AOTM_CLIENT_CAMERA_MANAGER.updating_render_targets then return end
	
	local localplayer = LocalPlayer()
	
	if not IsValid(localplayer) then return end
	
	if localplayer:Team() == TEAM_SPEC then return end
	
	local cam_pos = EyePos()
	local cam_normal = EyeVector()
	local cam_angle = EyeAngles()
	
	local realtime = RealTime()
	
	if realtime >= next_trace then
		local size = Vector(1,1,1)*4
	
		local tr = util.TraceHull({
			start = cam_pos,
			endpos = cam_pos + cam_normal*MAX_FOCUS_DIST,
			filter = localplayer,
			mask = MASK_OPAQUE_AND_NPCS,
			mins = size*-1,
			maxs = size
		})
		
		if tr.Hit then
			next_focus_dist = cam_pos:Distance(tr.HitPos)
		else
			next_focus_dist = MAX_FOCUS_DIST
		end
		
		next_trace = realtime + 0.1
	end
	
	
	local realframetime = RealFrameTime()
	
	focus_dist = Lerp(math.pow(0.001, realframetime), next_focus_dist, focus_dist)
	

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
		local dist_offset = Lerp(p, 0, DOF_LENGTH)
		
		-- Stage 1
		render.SetStencilPassOperation( STENCILOPERATION_INCR )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		
		--[[
		render.DrawQuadEasy(
			cam_pos + cam_normal * (focus_dist + dist_offset), 
			-cam_normal,
			QUAD_WIDTH,
			QUAD_HEIGHT,
			color_mask_1,
			cam_angle.roll
		)
		]]
		
		render.DrawSphere(cam_pos, -(focus_dist + dist_offset), 12, 4, color_mask_1)
		
		-- Stage 2
		if focus_dist - dist_offset > 10 then
			render.SetStencilPassOperation( STENCILOPERATION_KEEP )
			render.SetStencilZFailOperation( STENCILOPERATION_INCR )
			
			--[[
			render.DrawQuadEasy(
				cam_pos + cam_normal * (focus_dist - dist_offset), 
				-cam_normal,
				QUAD_WIDTH,
				QUAD_HEIGHT,
				color_mask_2,
				cam_angle.roll
			)
			]]
			
			render.DrawSphere(cam_pos, -(focus_dist - dist_offset), 12, 4, color_mask_2)
		end
	end
	
	render.OverrideDepthEnable( false, false )
	
	cam.Start2D()
		render.SetStencilPassOperation( STENCILOPERATION_KEEP )
		render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_LESS )
		for i = 1, DOF_LAYERS do
			render.SetStencilReferenceValue( i )
			blurMat:SetFloat("$scale", math.pow(1.2,(i-1)))
	
			render.UpdateScreenEffectTexture()
			render.SetMaterial(blurMat)
			render.DrawScreenQuad()
		end
	cam.End2D()
	
	render.SetStencilEnable(false)
end )