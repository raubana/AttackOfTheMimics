SMOOTH_TRANS = SMOOTH_TRANS or {}
SMOOTH_TRANS.__index = SMOOTH_TRANS


function SMOOTH_TRANS:create(duration)
	local smooth_trans = {}
	setmetatable(smooth_trans,SMOOTH_TRANS)
	
	smooth_trans._transition_duration = duration
	smooth_trans._transition_starttime = 0
	smooth_trans._transition_percent = 0
	smooth_trans._transition_direction = false
	smooth_trans._transition_done = true
	
	return smooth_trans
end


function SMOOTH_TRANS:Update(systime)
	local systime = systime or SysTime()
	
	if not self._transition_done then
		local t_dif = self:GetRemainingDuration()
		
		self._transition_percent = t_dif/self._transition_duration
		if self._transition_direction == true then
			self._transition_done = self._transition_percent >= 1
		else
			self._transition_done = self._transition_percent <= 0
		end
	end
end


function SMOOTH_TRANS:GetRemainingDuration()
	local t_dif = SysTime() - self._transition_starttime
	if self._transition_direction == true then
		//do nothing
	else
		t_dif = self._transition_duration - t_dif
	end
	t_dif = math.min(math.max(t_dif,0),self._transition_duration)
	return t_dif
end


function SMOOTH_TRANS:SetDirection(direction)
	if direction != self._transition_direction then
		local remaining_duration = self:GetRemainingDuration()
		if direction == true then
			self._transition_starttime = SysTime() - remaining_duration
		else
			self._transition_starttime = SysTime() - (self._transition_duration - remaining_duration)
		end
		
		self._transition_direction = direction
		self._transition_done = false
	end
end


function SMOOTH_TRANS:Reset()
	self._transition_done = true
	self._transition_starttime = SysTime() - self._transition_duration
	if self._transition_direction == true then
		self._transition_percent = 1
	else
		self._transition_percent = 0
	end
end


function SMOOTH_TRANS:SetDuration(duration)
	if duration != self._transition_duration then
		// TODO: Take into account that the transition may have been active during this change
		self._transition_duration = duration
	end
end


function SMOOTH_TRANS:GetPercent()
	return self._transition_percent
end