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
	if(MPM.IsValidMark(mark)) then
		MPM_Character.Marks[mark] = {[group]=value}
	end
end

MPM.IsValidMark = function (markName)
	if(MPM_Config.Mark_Definitions[markName]) then
		return true
	else
		return false
	end
end

MPM.MarkSelector = function (selector)
	local uRole=cmdToStr(UnitGroupRolesAssigned(selector))
	local uClass=cmdToStr(UnitClass(selector))
	local uName=cmdToStr(UnitName(selector))
	
	if(uClass == nil) then
		return
	end
	
	local foundOne = false
	for k,v in pairs(MPM_Character.Marks) do
		if((v["role"] and v["role"] == uRole) or (v["class"] and v["class"] == uClass) or (v["name"] and v["name"] == uName)) then
			foundOne = true
			MPM.SetMark(selector, k)
			break
		end
	end
	
	if(not foundOne) then
		MPM.SetMark(selector, MPM_Config.CLEAR)
	end
end

MPM.SetMark = function (selector, markName)
	if(MPM.IsValidMark(markName)) then
		SetRaidTarget(selector, MPM.GetMarkId(markName))
	end
end

MPM.GetMarkId = function (str) 
	if(MPM_Config.Mark_Definitions[str]) then
		return MPM_Config.Mark_Definitions[str]
	end
	
	return MPM.GetMarkId(MPM_Config.CLEAR)
end

MPM.Reset = function ()
	MPM_Character = {}
	MPM_Character.Marks = MPM_Config.Default_Marks
	MPM_Character.Version = MPM.Current_Version
end

MPM.CoreEventFrame = CreateFrame("Frame")
MPM.CoreEventFrame:RegisterEvent ("ADDON_LOADED")

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

MPM.MarkParty = function ()
	MPM.MarkSelector(MPM_Config.PLAYER)
	for i =1,4 do
		MPM.MarkSelector(MPM_Config.PARTY_PREFIX..i)
	end
end

SlashCmdList["MarkParty"] = MPM.SlashCmd