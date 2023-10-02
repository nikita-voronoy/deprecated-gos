local ScriptInfo = 
{
	Version = 1.11,
	Patch = 9.24,
	Release = "Stable",
}

local L_Dependencies =
{
	Versions = 'L_Versions',
	Core = 'L_Core',
	Oader = 'L_Oader',
	Prediction = 'PremiumPrediction'
}

local bundleDir = "L_Bundle\\"
local bundlePath = COMMON_PATH .. bundleDir

local scriptsLoaded, failedToLoad
local scriptFile

function OnLoad()
	if not FolderExists(bundlePath) then
		failedToLoad = true
		return
	end

	--Loading versions
	LoadSubmodule(L_Dependencies.Versions)
	
	scriptFile = L_SupportedChamps[myHero.charName]
	if (scriptFile == nil) then return end
	
	LoadSubmodule(L_Dependencies.Core)
	
	function L_Core:LoadSubmodule(name) LoadSubmodule(name) end
	
	LoadMenu()
	
	--Autoinject
	if LM.autoInject:Value() then
		LoadChampionSubmodule()
	end
end

function LoadMenu()
    LM = MenuElement({type = MENU, id = "LM", name = "[L] Oader"})
	
    LM:MenuElement({id = 'autoInject', name = "Inject scripts automatically", tooltip = "If this option is disabled L Modules won't load on the game start", value = true, toggle = true})
    LM:MenuElement({name = "Inject L Bundle", tooltip = "Click this to load L Modules into GoS manually", callback = function(value) LoadChampionSubmodule() end})

    LM:MenuElement({type = SPACE})
    LM:MenuElement({type = MENU, id = "Debug", name = "Debug"})
    LM.Debug:MenuElement({name = "Print debug data", value = false, toggle = true, callback = function(value) L_Core.DebugMode = value end})

	L_Core:AddMenuInfo(ScriptInfo, LM)
end

function FolderExists(strFolderName)
	local fileHandle, strError = io.open(strFolderName.."\\*.*","r")
	if fileHandle ~= nil then
		io.close(fileHandle)
		return true
	else
		if string.match(strError,"No such file or directory") then
			return false
		else
			return true
		end
	end
end

--Loader

function LoadChampionSubmodule()
	if scriptsLoaded then print("L Submodules are already loaded") return end
	
	LoadSubmodule(scriptFile)
	if not CheckUpdates(scriptFile, L_Script:VersionCheck()) then return end
	
	L_Script:Init()
	
	scriptsLoaded = true
end

function LoadSubmodule(name)
	require(bundleDir..name)
end