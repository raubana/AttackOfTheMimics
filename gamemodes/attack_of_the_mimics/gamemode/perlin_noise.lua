
PerlinNoiseGenerator = {}
PerlinNoiseGenerator.__index = PerlinNoiseGenerator

function PerlinNoiseGenerator:create()
	local gen = {}
	setmetatable(gen,PerlinNoiseGenerator)
	gen.seed = math.random(0,1000)
	return gen
end

function PerlinNoiseGenerator:prng(x)
	//expects an integer
	//return util.SharedRandom("pnrg",0,1,x) -- this can mess up engine stuff.
	return math.mod((x+self.seed) * 6581 + 7883, math.pow(2,7)) / math.pow(2,7)
	//return math.mod((x+self.seed) * 6581 + 7883, math.pow(2,15)) / math.pow(2,15)
	//return math.mod((x+self.seed) * 349 + 7883, math.pow(2,7)) / math.pow(2,7)
end


function PerlinNoiseGenerator:SmoothedNoise(x)
	//expects a float
	return self:prng(x)/2 + self:prng(x-1)/4  +  self:prng(x+1)/4
	//return self:prng(x)
end


function PerlinNoiseGenerator:InterpolatedNoise(x)
	//expects a float
	local frac_x = math.mod(x,1)
	local int_x = x-frac_x
	local v1 = self:SmoothedNoise(int_x)
	local v2 = self:SmoothedNoise(int_x + 1)
	//return Lerp(frac_x,v1,v2)
	return Lerp((1-math.cos(frac_x*math.pi))/2,v1,v2)
end


function PerlinNoiseGenerator:GenPerlinNoise(x,speed,persistence,octaves)
	//expects a float
	local total = 0
	local den = 0
	for i = 0, octaves - 1 do
		local frequency = math.pow(2,i)
		local amplitude = math.pow(persistence,i)
		den = den + amplitude
		total = total + self:InterpolatedNoise(x*speed*frequency)*amplitude
	end
	total = total / den
	return total
end 