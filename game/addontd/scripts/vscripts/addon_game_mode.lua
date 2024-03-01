_G.lua = {}
require("constants")
require("libraries/buildinghelper")
require("libraries/pathfix")
require("waves")
require("http")


xpTable = {
	0
}
if Game == nil then
	Game = class({})
end

function Precache( context )
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_items.vsndevts", context)
end

-- Create the game mode when we activate
function Activate()
	Game:InitGameMode()
end

function Game:InitGameMode()
	GameRules:SetStrategyTime(0.0)
    GameRules:SetShowcaseTime(0.0)
	GameRules:SetPreGameTime(0.0)
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_antimage")
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 0.1 )
	-- teams
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 1)
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 1)

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xpTable)
    GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
    --GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_wisp")
    GameRules:GetGameModeEntity():SetCameraDistanceOverride( 2300 )
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled(false)
	-- listeners
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(Game, 'OnNPCSpawned'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Game, 'OnGameRuleChange'), Game)
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Game, 'OnUnitKilled'), self)

	CustomGameEventManager:RegisterListener( "HeroIsReadyReal", HeroIsReadyReal ) 
	CustomGameEventManager:RegisterListener( "HeroIsReadyCancel", HeroIsReadyCancel )
	CustomGameEventManager:RegisterListener( "SetTableValue", SetTableValue )
	CustomGameEventManager:RegisterListener( "http_request", http_request_client )
end
function Game:OnUnitKilled(event)
	local unit = EntIndexToHScript(event.entindex_killed)
	if unit.teamnumber then
		Game:DeatCreep(unit)
	end
	if unit.builderG then
		Game:DeatRealHero(unit)
	end
	if unit.construction_size then
		Game:DeatBuildings(unit)
	end
end
function Game:OnGameRuleChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		WaveClass:Init()
	end
end
function Game:OnNPCSpawned(keys)
    local npc = EntIndexToHScript(keys.entindex)
	
    if npc:IsRealHero() then
		Game:SpawnRealHero(npc)
    end
end
function Game:OnThink()
	Server:UpdateProfiles()
	return 1
end
function Game:DeatBuildings(unit)
	location = {x = unit:GetAbsOrigin().x, y = unit:GetAbsOrigin().y}
	BuildingHelper:RemoveGridType(unit.construction_size, location, "BLOCKED")
	BuildingHelper:AddGridType(unit.construction_size, location, "BUILDABLE")
	_G.lua.towers[unit:GetPlayerOwnerID()] = _G.lua.towers[unit:GetPlayerOwnerID()] - 1
	CustomGameEventManager:Send_ServerToTeam(unit:GetTeamNumber(), "update_CountTowers", {
	count  = _G.lua.towers,
	})
	
end
function Game:DeatRealHero(unit)
	local id = unit:GetPlayerID()
	_G.lua.Players[id] = nil 
	_G.lua.AliveTeams[id] = nil
	_G.lua.Teams[id] = nil
	_G.lua.Cplayers = _G.lua.Cplayers - 1
	Game:CheckTeamsOnWin()
	unit:SetTimeUntilRespawn(9999)
	unit:SetBuybackCooldownTime(99999)
	WaveClass:KillsAllCreeps(id)
end
function Game:DeatCreep(unit)
	_G.lua.killscreeps[unit.playerid] = _G.lua.killscreeps[unit.playerid] + 1
	_G.lua.CreepCounter[unit.playerid] = _G.lua.CreepCounter[unit.playerid] - 1
	for i, unittable in pairs(_G.lua.playercreeps[unit.playerid]) do
		if unit == unittable then
			table.remove(_G.lua.playercreeps[unit.playerid], i)
			break  -- Выходим из цикла, так как элемент уже найден и удален
		end
	end
	CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "update_CreepCounts", {
		count = _G.lua.CreepCounter[unit.playerid], 
		maxcount = _G.lua.allcreeps[_G.lua.round[unit.playerid]].count,
		team = unit.teamnumber
	})
	if _G.lua.CreepCounter[unit.playerid] == 0 then
		CheckNextWave(unit)
	end
end
function CheckNextWave(unit)
	_G.lua.Teams[unit.playerid] = false
		Timers:CreateTimer(0.01, function ()
			if  _G.lua.stoptimer[unit.playerid] == false then
				_G.lua.stoptimer[unit.playerid] = true
				return
			end
			if _G.lua.Teams[unit.playerid] == false then
				if not  _G.lua.timerswaves[unit.playerid] then
					_G.lua.timerswaves[unit.playerid] = {}
					_G.lua.timerswaves[unit.playerid].secund = 30
					_G.lua.timerswaves[unit.playerid].fullsecund = 30
				end
				CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "EndWave", {
					sec = _G.lua.timerswaves[unit.playerid].secund,
					fullsec = _G.lua.timerswaves[unit.playerid].fullsecund
				})
				_G.lua.timerswaves[unit.playerid].secund  = _G.lua.timerswaves[unit.playerid].secund  - 1
				if _G.lua.timerswaves[unit.playerid].secund <= 0 then
					if _G.lua.Teams[unit.playerid] == false then
						_G.lua.Teams[unit.playerid] = true
						_G.lua.timerswaves[unit.playerid].secund = 30
						_G.lua.timerswaves[unit.playerid].fullsecund = 30
						_G.lua.round[unit.playerid] = _G.lua.round[unit.playerid] + 1
						CustomGameEventManager:Send_ServerToTeam(_G.lua.Players[unit.playerid]:GetTeamNumber(),"EndReadyTimer", {})
						_G.lua.incomes[unit.playerid] = true
						WaveClass:StartWave(unit.playerid)
						
						return
					end
				end
			end
			return 1
		end)
end
function Game:SpawnRealHero(unit)
	local id = unit:GetPlayerID()
	unit.builderG = true
	_G.lua.Players[id] = unit
	_G.lua.AliveTeams[id] = true
	_G.lua.Teams[id] = false
	_G.lua.killscreeps[id] = 0
	_G.lua.Cplayers = _G.lua.Cplayers + 1
	_G.lua.towers[id] = 0
	_G.lua.incomes[id] = true
	_G.lua.playercreeps[id] = {}
	_G.lua.round[id] = 1
	unit:FindAbilityByName("gold_tower"):SetLevel(1)
	unit:FindAbilityByName("repair_tower"):SetLevel(1)
	
	local steamid = PlayerResource:GetSteamID(id)

	http_request("http://spooftd.temp.swtest.ru/getprofile.php?&steamid=".. tostring(steamid), "get", function (data)
		_G.lua.PlayerServerData[id] = data
	end)
	Timers:CreateTimer(5, function ()
		_G.lua.PlayerServerData[id].games =  _G.lua.PlayerServerData[id].games + 1
		http_request("http://spooftd.temp.swtest.ru/getprofile.php?&steamid=".. tostring(steamid).. "&mode=edit&games=".. _G.lua.PlayerServerData[id].games, "get", function (data)
			_G.lua.PlayerServerData[id] = data
		end)
	end)
	
	
end
function Game:CheckTeamsOnWin()
	if _G.lua.gamemode == "Solo" then
			GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
	else
		if WaveClass:countCheck(_G.lua.AliveTeams) == 1 then
			for  id, team in pairs(_G.lua.AliveTeams) do
				for i = 0 ,_G.lua.Cplayers - 1 do
					if i == id then
						GameRules:SetGameWinner(_G.lua.Players[i]:GetTeamNumber())
					end
				end
			end
		end
	end
end

function SetTableValue(_,event)
	CustomNetTables:SetTableValue( event.table_name, event.key, event.value )
end

