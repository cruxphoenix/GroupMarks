MMPM = {}
MMPM.Current_Version = 202012041

SLASH_MarkParty1 = "/mmpm"

MMPM.SplitStr = function(str)
	local t = {}
	local i = 1
	for token in string.gmatch(str, "[^%s]+") do
	   t[i] = MMPM.CmdToStr(token)
	   i = i+1
	end
	return unpack(t)
end

MMPM.SlashCmd = function(txt)
	local cmd1, cmd2, cmd3, cmd4 = MMPM.SplitStr(txt)
	if(cmd1 == "reset") then
		print("Resetting MMPM back to default")
		MMPM.Reset()
	elseif(cmd1 == "set") then
		if(cmd2 == nil or cmd3 == nil or cmd4 == nil) then
			print("Usage: /mmpm set [class|role|name] [star|circle|diamond|triangle|moon|square|cross|skull]")
			return
		else
			print("Running Set Cmd")
			MMPM.AssignMark(cmd2, cmd3, cmd4)
		end
	else
		MMPM.MarkParty()
	end
end

MMPM.CmdToStr = function(str)
	if(str ~= nil) then
		local normalisedString = string.gsub(str, "%s+", "")
		return string.lower(normalisedString)
	else
		return ""
	end
end

MMPM.AssignMark = function(group, value, mark)
	if(MMPM.IsValidMark(mark)) then
		MMPM1.Marks[mark] = {[group]=value}
	end
end

MMPM.IsValidMark = function (markName)
	if(MMPM_Config.Mark_Definitions[markName]) then
		return true
	else
		return false
	end
end

MMPM.MarkSelector = function (selector)
	local uRole=MMPM.CmdToStr(UnitGroupRolesAssigned(selector))
	local uClass=MMPM.CmdToStr(UnitClass(selector))
	local uName=MMPM.CmdToStr(UnitName(selector))
	
	if(uClass == nil) then
		return
	end
	
	local foundOne = false
	for k,v in pairs(MMPM1.Marks) do
		if((v["role"] and v["role"] == uRole) or (v["class"] and v["class"] == uClass) or (v["name"] and v["name"] == uName)) then
			foundOne = true
			MMPM.SetMark(selector, k)
			break
		end
	end
	
	if(not foundOne) then
		MMPM.SetMark(selector, MMPM_Config.CLEAR)
	end
end

MMPM.SetMark = function (selector, markName)
	if(MMPM.IsValidMark(markName)) then
		SetRaidTarget(selector, MMPM.GetMarkId(markName))
	end
end

MMPM.GetMarkId = function (str) 
	if(MMPM_Config.Mark_Definitions[str]) then
		return MMPM_Config.Mark_Definitions[str]
	end
	
	return MMPM.GetMarkId(MMPM_Config.CLEAR)
end

MMPM.Reset = function ()
	MMPM1 = {}
	MMPM1.Marks = MMPM_Config.Default_Marks
	MMPM1.Version = MMPM.Current_Version
end

MMPM.CoreEventFrame = CreateFrame("Frame")
MMPM.CoreEventFrame:RegisterEvent ("ADDON_LOADED")

MMPM.CoreEventFrame:SetScript("OnEvent", function(self, event, ...)
	if (event=="ADDON_LOADED") then
		local arg1, arg2, arg3, arg4, arg5 = ...;
		if(not MMPM1 or not MMPM1["Version"] or MMPM1.Version < MMPM.Current_Version) then
			MMPM.Reset()
		end
	elseif(event=="CHALLENGE_MODE_START") then
		print("Starting Key")
		MMPM.MarkParty()
	end
end)

MMPM.MarkParty = function ()
	MMPM.MarkSelector(MMPM_Config.PLAYER)
	for i =1,4 do
		MMPM.MarkSelector(MMPM_Config.PARTY_PREFIX..i)
	end
end

SlashCmdList["MarkParty"] = MMPM.SlashCmd