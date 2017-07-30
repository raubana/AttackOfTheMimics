
local credit_text = {}

local CREDIT_SECTION_DURATION = 4
local CREDIT_TITLE_DURATION = 10
local CREDIT_TRANSITION_DURATION = 1.0

local credits_section_index = credits_section_index or 1
local next_transition = next_transition or 0

local transition_start = 0
local transitioning = false


local titleFont = titleFont
if not titleFont then
	titleFont = surface.CreateFont( "AOTM_Credits_Title", {font="Arial Black", size=32} )
end
local creditsFont = creditsFont
if not creditsFont then
	creditsFont = surface.CreateFont( "AOTM_Credits", {font="Arial", size=18} )
end


local function draw_credits_at( section_index, alpha )
	if section_index <= 0 or section_index > #credit_text then return end
	if alpha <= 0 then return end
	
	local alpha = math.min(alpha, 1.0)
	
	local section = credit_text[section_index]

	local scrw = ScrW()
	local scrh = ScrH()
	
	local padding = math.min(scrw, scrh) * 0.1
	
	surface.SetTextColor( Color(255,255,255,255*alpha) )
	
	local y = padding --scrh - padding
	local i = 1 -- #section
	while i <= #section do --> 0 do
		if i > 1 then
			surface.SetFont("AOTM_Credits")
		else
			surface.SetFont("AOTM_Credits_Title")
		end
	
		local text = section[i]
		local w, h = surface.GetTextSize(text)
		
		-- y = y - h
		
		surface.SetTextPos(scrw - w - padding, y)
		surface.DrawText(text)
		
		y = y + h
		
		--i = i - 1
		i = i + 1
	end
end


net.Receive( "AOTM_RunCredits", function(len, ply)
	print("credits start")

	credits_section_index = 0
	next_transition = RealTime()
	
	credit_text = util.JSONToTable(net.ReadString())

	hook.Add( "HUDPaint", "AOTM_HUDPaint_Credits", function()
		local localplayer = LocalPlayer()
		if not IsValid(localplayer) then return end
		
		if credits_section_index > #credit_text then
			hook.Remove("HUDPaint", "AOTM_HUDPaint_Credits")
		else
			local realtime = RealTime()
			
			if not transitioning and realtime >= next_transition then
				transitioning = true
				transition_start = realtime
			end
			
			local p = 0
			
			if transitioning then
				p = (realtime - transition_start) / CREDIT_TRANSITION_DURATION
				
				if p > 1.0 then
					transitioning = false
					credits_section_index = credits_section_index + 1
					
					if credits_section_index == #credit_text and #credit_text[#credit_text] == 1 then
						next_transition = realtime + CREDIT_TITLE_DURATION
					else
						next_transition = realtime + CREDIT_SECTION_DURATION
					end
					
					p = 0.0
				end
			end
			
			if p == 0 then
				draw_credits_at(credits_section_index, 1.0)
			else
				draw_credits_at(credits_section_index, Lerp(p, 1.0, -1.0))
				draw_credits_at(credits_section_index+1,Lerp(p, -1.0, 1.0))
			end
		end
	end )
	
end )


print("cl_credits ran")