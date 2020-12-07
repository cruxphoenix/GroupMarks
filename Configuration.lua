MMPM_Config = {}
MMPM_Config.CLEAR = "clear"
MMPM_Config.PLAYER = "player"
MMPM_Config.PARTY_PREFIX = "party"
MMPM_Config.Mark_Definitions = {
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
--------------------------------------------------------------------------------------------------------------------------------------------------
MMPM_Config.Default_Marks = {
	["square"]={["role"]="tank"},
	["circle"]={["role"]="healer"},
	["star"]={["class"]="rogue"}
}