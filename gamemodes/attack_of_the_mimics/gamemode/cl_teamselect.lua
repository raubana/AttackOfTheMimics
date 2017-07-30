local my_frame = my_frame or nil


local function RemoveFrame()
	if ispanel(my_frame) then
		my_frame:Remove()
		gui.EnableScreenClicker( false )
		my_frame = nil
	end
end


local function CreateTeamSelectMenu()
	local frame = vgui.Create( "DFrame" )
	my_frame = frame
	
	frame:SetTitle( "Select Team" )
	frame:SetVisible( true )
	frame:SetDraggable( true )
	frame:ShowCloseButton( true )
	frame:Center()
	frame.OnClose = RemoveFrame
	
	local t1_button = vgui.Create( "DButton", frame )
	t1_button:SetPos( 10, 30 )
	t1_button:SetSize( 250, 20 )
	t1_button:SetText( "I want to play!" )
	t1_button.DoClick = function()
		net.Start("AOTM_SetWantsToPlay")
		net.WriteBool(true)
		net.SendToServer()
		RemoveFrame()
	end
	
	local t2_button = vgui.Create( "DButton", frame )
	t2_button:SetPos( 10, 60 )
	t2_button:SetSize( 250, 20 )
	t2_button:SetText( "I want to watch." )
	t2_button.DoClick = function()
		net.Start("AOTM_SetWantsToPlay")
		net.WriteBool(false)
		net.SendToServer()
		RemoveFrame()
	end
	
	local lbl = vgui.Create( "DLabel", frame )
	lbl:SetPos( 10, 90 )
	lbl:SetSize( 250, 20 )
	lbl:SetText( "Note: this will not take effect until the next round." )
	
	frame:SetSize( 270, 120 )
	frame:Center()
	
	gui.EnableScreenClicker( true )
end


hook.Add("PlayerBindPress", "AOTM_PlayerBindPress_ClTeamSelect", function(ply, bind, pressed)
	if bind == "+menu" then
		if not ispanel(my_frame) then
			CreateTeamSelectMenu()
		end
	end
end)

print("cl_teamselect ran")