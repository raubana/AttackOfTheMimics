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

print("render ran")