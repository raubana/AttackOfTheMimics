
local DEBUG_ADD_RESOURCES = true

local legal_extensions = {
	txt = true,
	mdl = true,
	mp3 = true,
	wav = true,
	vmt = true,
	vtf = true
}


// Adds all found resources at the given location to the
// list of files to be downloaded by the client.

//NOTE: You don't need to do the exact file location for content in addons
// and in gamemodes. Instead, use the relative mounted locations.
function AddAllResourcesAt(name, path)
	if not path then path = "GAME" end
	print("- "..name..", "..path)
	local filelist = {}
	local L1,L2 = file.Find(name,path)
	for key,f in pairs(L1) do
		local new_f = string.Replace(name,"*",f)
		if legal_extensions[string.GetExtensionFromFilename(new_f)] then
			if DEBUG_ADD_RESOURCES then print("-- adding "..new_f) end
			resource.AddFile(new_f)
			table.insert(filelist,new_f)
		else
			if DEBUG_ADD_RESOURCES then print("-- skipping "..new_f) end
		end
	end
	for key,dir in pairs(L2) do
		local new_dir = string.Replace(name,"*",dir).."/*"
		AddAllResourcesAt(new_dir)
	end
	return filelist
end

AddAllResourcesAt("models/attack_of_the_mimics/*")
AddAllResourcesAt("materials/attack_of_the_mimics/*")
AddAllResourcesAt("sound/attack_of_the_mimics/*")

-- resource.AddWorkshop("1095448769") -- map CAUSES A CRASH!!
resource.AddWorkshop("1096845726") -- content