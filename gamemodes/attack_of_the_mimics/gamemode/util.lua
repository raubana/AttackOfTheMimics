local util = util

if not util then return end

function util.ShuffleTable( tbl )
	for i1 = 1, #tbl do
		local i2 = math.random(#tbl)
		
		if i1 != i2 then
			local temp = tbl[i1]
			tbl[i1] = tbl[i2]
			tbl[i2] = temp
		end
	end
end


function util.RouletteSelect(score_list)
	if #score_list == 1 then return 1 end

	local total = 0
	for i, val in ipairs(score_list) do
		total = total + val
	end
	
	local target = math.random() * total
	total = 0
	local i = 1
	while i <= #score_list do
		if total <= target and total+score_list[i] > target then
			return i
		end
		total = total + score_list[i]
		i = i + 1
	end
end


print("util ran")