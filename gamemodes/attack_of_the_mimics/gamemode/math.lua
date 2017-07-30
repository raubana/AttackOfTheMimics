local math = math

if not math then return end

function math.InvLerp( c, a, b )
	return (c-a)/(b-a)
end

print("math ran")