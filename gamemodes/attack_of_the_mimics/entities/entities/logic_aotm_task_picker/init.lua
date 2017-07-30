AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	
	self.numtasks =  self.numtasks or 3
	self.numents = self.numents or 0
end


function ENT:KeyValue(key, value)
	if key == "numtasks" then
		self.numtasks = math.Clamp( tonumber(value), 1, 16)
	elseif key == "numents" then
		self.numents = math.Clamp( tonumber(value), 0, 16)
	elseif string.StartWith(key, "OnTriggerEnt") then
		self:StoreOutput(key, value)
	end
end


function ENT:OnNewRoundStart()
	local picks = {}
	for i = 1, self.numents do
		picks[i] = 1*i
	end
	
	-- shuffle
	util.ShuffleTable(picks)
	
	for i = 1, math.min(self.numtasks, self.numents) do
		self:TriggerOutput("OnTriggerEnt"..tostring(picks[i]), self)
	end
end


hook.Add( "AOTM_PreNewRoundStart", "AOTM_AOTM_PreNewRoundStart_LogicAOTMTaskPicker", function( )
	local ent_list = ents.FindByClass("logic_aotm_task_picker")
	for i, ent in ipairs(ent_list) do
		ent:OnNewRoundStart()
	end
end )
