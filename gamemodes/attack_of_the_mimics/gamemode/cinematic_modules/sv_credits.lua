local CREDIT_TEXT_DEFAULT = {
	{
		"raubana",
			"Producer",
			"Programmer",
			"Musician",
			"Logo Animation",
			"Walkie Talkie SFX",
			"Key Ring SFX",
			"Flashlight SFX",
	},
	
	{
		"Repository Contributors",
			"FusionLord"
	},
	
	{
		"Testers",
			"Burnt",
			"Community",
			"FusionLord",
			"]N[amoron",
			"nickthegamer5",
			"marriwano smoker society.gg",
			"Metamist",
			"Ras",
			"raubana",
			"Riddick",
			"Tai",
			"Turtleey",
			"Viz"
	},
	
	{
		"Special Thanks",
			"Burnt", -- best tester ever
			"Bobblehead", --helping me get in contact with turtleey and stuff.
			"Turtleey", -- saved my butt during the contest
			"Zephruz" -- i think he gave me advice about clientside models...?
	}
}
local credit_text = {}


hook.Add( "Initialize", "AOTM_Initialize_Credits", function( )
	util.AddNetworkString("AOTM_RunCredits")
end )


hook.Add( "AOTM_PreNewRoundStart", "AOTM_PreNewRoundStart_Credits", function( )
	credit_text = table.Add({}, CREDIT_TEXT_DEFAULT)
end )


hook.Add( "AOTM_AppendCredits", "AOTM_AppendCredits_Credits", function( new_credits )
	table.insert( credit_text, new_credits )
end )


hook.Add( "AOTM_PostStageChange", "AOTM_PostStageChange_Credits", function( old_stage, new_stage )
	if new_stage == STAGE_ROUND then
		print("sent start credits")
		net.Start("AOTM_RunCredits")
		net.WriteString(util.TableToJSON(credit_text))
		net.Broadcast()
	end
end )


print("sv_credits ran")