local render = render

if not render then return end


local blurMat = Material( "pp/videoscale" )
function render.CheapBlur( bluramount )
	local bluramount = 1.0*bluramount

	while bluramount > 0.25 do
		blurMat:SetFloat("$scale", bluramount)
	
		render.UpdateScreenEffectTexture()
		render.SetMaterial(blurMat)
		render.DrawScreenQuad()
		
		bluramount = bluramount / 2
	end
end



-- The following is for debugging only!
local QUAD_WIDTH = 100000
local QUAD_HEIGHT = 100000

render.DrawStencilTestColors = function( context_3d, layers )
	render.SetStencilEnable(true)
	render.OverrideDepthEnable( true, false )
	
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilPassOperation( STENCILOPERATION_KEEP )
	render.SetStencilFailOperation( STENCILOPERATION_KEEP )
	render.SetStencilZFailOperation( STENCILOPERATION_KEEP )
	
	render.SetColorMaterial()
	
	for i = 0, layers do
		render.SetStencilReferenceValue( i )
		
		local c = HSVToColor((i/(layers)) * 300.0, 1.0, Lerp(((i+1)%2)/2, 0.5, 1.0))
		c.a = 64
		
		if context_3d then
			cam.IgnoreZ(true)
		
			local localplayer = LocalPlayer()
			local cam_pos = localplayer:EyePos()
			local cam_angle = localplayer:EyeAngles()
			local cam_normal = cam_angle:Forward()
		
			render.DrawQuadEasy(
				cam_pos + cam_normal * 10, 
				-cam_normal,
				QUAD_WIDTH,
				QUAD_HEIGHT,
				c,
				cam_angle.roll
			)
			cam.IgnoreZ(false)
		else
			render.SetColorModulation(c.r/255, c.g/255, c.b/255)
			render.DrawScreenQuad()
		end
	end
	
	render.OverrideDepthEnable( false, false )
	render.SetStencilEnable(false)
end


print("render ran")