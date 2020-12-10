MPM = {}
MPM.Current_Version = 202012071

SLASH_MarkParty1 = "/mpm"
SLASH_MarkParty2 = "/mythicplusmarker"

function splitStr(str)
	local t = {}
	local i = 1
	for token in string.gmatch(str, "[^%s]+") do
	   t[i] = cmdToStr(token)
	   i = i+1
	end
	return unpack(t)
end

MPM.SlashCmd = function(txt)
	local cmd1, cmd2, cmd3, cmd4 = splitStr(txt)
	if(cmd1 == "help") then
		print("/mpm or /mythicplusmarker")
		print("reset : Resets the addon back to initial settings")
		print("set : Set the class/role/name to a marker")
	elseif(cmd1 == "reset") then
		print("Resetting MPM back to default")
		MPM.Reset()
	elseif(cmd1 == "set") then
		if(cmd2 == nil or cmd3 == nil or cmd4 == nil) then
			print("Usage: /mpm set [class|role|name] [star|circle|diamond|triangle|moon|square|cross|skull]")
			return
		else
			print("Running Set Cmd")
			MPM.AssignMark(cmd2, cmd3, cmd4)
		end
	elseif(cmd1 == "check") then
		MPM.PrintMarks()
	elseif(cmd1 == "clear") then
		MPM.ClearAll()
	else
		MPM.MarkParty()
	end
end

function cmdToStr(str)
	if(str ~= nil) then
		return string.lower(string.gsub(str, "%s+", ""))
	else
		return ""
	end
end

MPM.AssignMark = function(group, value, mark)
	if(isValidMark(mark)) then
		if(group == "role" or group == "class" and not(string.match(value, "%d+"))) then
			value = value .. "1"
		end
		MPM_Character.Marks[mark] = {[group]=value}
	end
end

MPM.PrintMarks = function()
	for m,d in pairs(MPM_Character.Marks) do
		print(m .. ": " .. getMarkGrouping(d) .. "-" .. getMarkValue(d))
	end
end

function getMarkGrouping(def) 
	if(def.role) then
		return "role"
	elseif (def.class) then
		return "class"
	elseif (def.name) then
		return "name"
	else
		return "<None>"
	end
end

function getMarkValue(def)
	local grouping = getMarkGrouping(def)
	return def[grouping]
end

function isValidMark(markName)
	if(MPM_Config.Mark_Definitions[markName]) then
		return true
	else
		return false
	end
end

MPM.MarkSelector = function (selector, selectorTable)
	local uRole=cmdToStr(UnitGroupRolesAssigned(selector))
	local uClass=cmdToStr(UnitClass(selector))
	local uName=cmdToStr(UnitName(selector))
	
	if(uClass == nil) then
		return
	end
	
	MPM.SetMark(selector, MPM_Config.CLEAR)
	
	local c = selectorTable[selector]
	for k,v in pairs(MPM_Character.Marks) do
		if(isMatch(v, c)) then
			print("Found match for "..selector.." for mark "..k)
			MPM.SetMark(selector, k)
			break;
		end
	end
end

function isMatch(markDef, selectorDef)
	return (markDef.role and selectorDef.role_n and markDef.role == selectorDef.role_n) or
			(markDef.class and selectorDef.class_n and markDef.class == selectorDef.class_n) or
			(markDef.name and selectorDef.name and markDef.name == selectorDef.name)
end

function buildSelectorTable(allSelectors)
	local selectorTable = {}
	for i,s in pairs(allSelectors) do
		insertSelectorEntry(selectorTable, s)
	end
	
	return selectorTable
end

function insertSelectorEntry(t,selector)
	local uRole=cmdToStr(UnitGroupRolesAssigned(selector))
	local uClass=cmdToStr(UnitClass(selector))
	local uName=cmdToStr(UnitName(selector))
	
	local classCount = 0
	local roleCount = 0
	for i,v in pairs(t) do
		if(t["class"] == uClass) then
			classCount = classCount + 1
		end
		
		if(t["role"] == uRole) then
			roleCount = roleCount + 1
		end
	end
	
	t[selector] = {
		["class"]=uClass,
		["class_n"]=uClass..(classCount + 1),
		["role"]=uRole,
		["role_n"] = uRole..(roleCount + 1),
		["name"]=uName
	}
end

MPM.SetMark = function (selector, markName)
	if(isValidMark(markName)) then
		SetRaidTarget(selector, getMarkId(markName))
	end
end

function getMarkId(str) 
	if(MPM_Config.Mark_Definitions[str]) then
		return MPM_Config.Mark_Definitions[str]
	end
	
	return getMarkId(MPM_Config.CLEAR)
end

MPM.Reset = function ()
	MPM_Character = {}
	MPM_Character.Marks = MPM_Config.Default_Marks
	MPM_Character.Version = MPM.Current_Version
end

MPM.CoreEventFrame = CreateFrame("Frame")
MPM.CoreEventFrame:RegisterEvent ("ADDON_LOADED")
MPM.CoreEventFrame:RegisterEvent ("CHALLENGE_MODE_START")

MPM.CoreEventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event=="ADDON_LOADED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if(not MPM_Character or not MPM_Character["Version"] or MPM_Character.Version < MPM.Current_Version) then
			MPM.Reset()
		end
	elseif(event=="CHALLENGE_MODE_START") then
		print("Starting Key")
		MPM.MarkParty()
	end
end)

function getDynamicSelectors()
	local allSelectors = {}
	local i = 1
	for dsd_i, selectorTable in pairs(MPM_Config.Dynamic_Selector_Definitions) do
		local baseSelector = selectorTable["selector"]
		if(selectorTable["range_start"]) then
			for curIndex = selectorTable["range_start"], selectorTable["range_end"] do
				allSelectors[i] = baseSelector..curIndex
				i = i + 1
			end
		else
			allSelectors[i] = baseSelector
			i = i + 1
		end
	end
	
	return allSelectors
end

MPM.ClearAll = function()
	MPM_Character.Marks = {}
end

MPM.MarkParty = function ()
	local allSelectors = getDynamicSelectors()
	local selectorTable = buildSelectorTable(allSelectors)
	for i,s in pairs(allSelectors) do
		MPM.MarkSelector(s,selectorTable)
	end
end

SlashCmdList["MarkParty"] = MPM.SlashCmd