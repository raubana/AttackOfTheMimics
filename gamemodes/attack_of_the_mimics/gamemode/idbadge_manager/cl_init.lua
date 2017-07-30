include("shared.lua")

AOTM_CLIENT_IDBADGE_MANAGER = AOTM_CLIENT_IDBADGE_MANAGER or {}
AOTM_CLIENT_IDBADGE_MANAGER.rt_list = AOTM_CLIENT_IDBADGE_MANAGER.rt_list or {}
AOTM_CLIENT_IDBADGE_MANAGER.unused_rt_list = AOTM_CLIENT_IDBADGE_MANAGER.unused_rt_list or {}


AOTM_CLIENT_IDBADGE_MANAGER.WIDTH = 256
AOTM_CLIENT_IDBADGE_MANAGER.HEIGHT = 128



function AOTM_CLIENT_IDBADGE_MANAGER:CreateIDBadgeTexture( )
	local texture
	if #self.unused_rt_list > 0 then
		texture = table.remove(self.unused_rt_list)
	else
		local name = "AOTM_IDBADGE_"..tostring(#self.rt_list + #self.unused_rt_list)
		texture = GetRenderTarget(name, self.WIDTH, self.HEIGHT, false)
	end
	
	table.insert(self.rt_list, texture)
	
	return texture
end


function AOTM_CLIENT_IDBADGE_MANAGER:DeleteIDBadgeTexture( texture )
	table.RemoveByValue(self.rt_list)
	table.insert(self.unused_rt_list, texture)
end


local bgMat = Material("attack_of_the_mimics/models/costume/id_badge_unlit")

local nameFont = nameFont
if not nameFont then
	nameFont = surface.CreateFont( "AOTM_Badge_Name", {font="Arial", size=28} )
end
local idFont = idFont
if not idFont then
	idFont = surface.CreateFont( "AOTM_Badge_ID", {font="Arial", size=16} )
end

function AOTM_CLIENT_IDBADGE_MANAGER:UpdateRenderTarget( ply, texture )
	-- TODO: Figure out how to fetch a player's avatar from steam.
	
	local old_rt = render.GetRenderTarget()
	local oldW, oldH = ScrW(), ScrH()
	render.SetRenderTarget( texture )
	
	render.Clear( 128, 255, 255, 255 )
	render.SetViewPort( 0, 0, AOTM_CLIENT_IDBADGE_MANAGER.WIDTH, AOTM_CLIENT_IDBADGE_MANAGER.HEIGHT )
	
	cam.Start2D()
		surface.SetDrawColor(color_white)
		surface.SetMaterial( bgMat )
		surface.DrawTexturedRect( 0, 0, AOTM_CLIENT_IDBADGE_MANAGER.WIDTH, AOTM_CLIENT_IDBADGE_MANAGER.HEIGHT )
		-- TODO: the above doesn't work for some reason
		
		surface.SetDrawColor(color_black)
		surface.DrawRect(6,6,64,64)
		
		surface.SetTextColor(color_black)
		local txt = ply:Nick()
		surface.SetFont("AOTM_Badge_Name")
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos( (((64+6+5)+(AOTM_CLIENT_IDBADGE_MANAGER.WIDTH))/2)-(w/2), (32+6)-(h/2) )
		surface.DrawText(txt)
		
		local txt = ply:SteamID()
		surface.SetFont("AOTM_Badge_ID")
		local w, h = surface.GetTextSize(txt)
		surface.SetTextPos((AOTM_CLIENT_IDBADGE_MANAGER.WIDTH-w)/2,AOTM_CLIENT_IDBADGE_MANAGER.HEIGHT-h-20)
		surface.DrawText(txt)
	cam.End2D()
	
	render.SetViewPort( 0, 0, oldW, oldH )
	render.SetRenderTarget( old_rt )
end

print("idbadge manager cl_init")