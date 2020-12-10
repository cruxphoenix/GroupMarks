MPM_Config = {}
MPM_Config.CLEAR = "clear"
MPM_Config.PLAYER = "player"
MPM_Config.PARTY_PREFIX = "party"
MPM_Config.Mark_Definitions = {
	["star"]=1,
	["circle"]=2,
	["diamond"]=3,
	["triangle"]=4,
	["moon"]=5,
	["square"]=6,
	["cross"]=7,
	["skull"]=8,
	["clear"]=0
}
MPM_Config.Selector_Definitions = {
	"player",
	"party1",
	"party2",
	"party3",
	"party4",
}
MPM_Config.Dynamic_Selector_Definitions = {
	{["selector"]="player"},
	{["selector"]="party",["range_start"]=1,["range_end"]=4},
	{["selector"]="raid",["range_start"]=1,["range_end"]=39},
}
--------------------------------------------------------------------------------------------------------------------------------------------------
MPM_Config.Default_Marks = {
	["square"]={["role"]="tank1"},
	["circle"]={["role"]="healer1"},
	["star"]={["class"]="rogue1"},
}
MPM_Config.Class_Maps = {
	["dh"]="demonhunter",
	["demon hunter"]="demonhunter",
	["dk"]="deathknight",
	["death knight"]="deathknight"
}