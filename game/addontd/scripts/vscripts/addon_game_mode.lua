

require("libraries/buildinghelper")
require("libraries/pathfix")
require("waves")
_G.killscreeps = {}
_G.CreepCounter = {}
_G.Teams = {}
_G.gamemode = "no"
_G.Players = {}
_G.Cplayers = 0
_G.TeamNumber = {
	good = "2",
	bad = "3",
	custom1 = "6",
	custom2 = "7",
}
_G.AliveTeams = {}
_G.round = {}
_G.towers = {}
_G.creeps = 0
_G.maxcreeps = 0
_G.incomes = {}
_G.playercreeps = {}
_G.timerswaves = {}



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
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
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
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
function Game:CheckTeams()
end
function Game:DeatBuildings(unit)
	location = {x = unit:GetAbsOrigin().x, y = unit:GetAbsOrigin().y}
	BuildingHelper:RemoveGridType(unit.construction_size, location, "BLOCKED")
	BuildingHelper:AddGridType(unit.construction_size, location, "BUILDABLE")
	_G.towers[unit:GetTeamNumber()] = _G.towers[unit:GetTeamNumber()] - 1
	CustomGameEventManager:Send_ServerToTeam(unit:GetTeamNumber(), "update_CountTowers", {
	count  = _G.towers,
	})
	
end
function Game:DeatRealHero(unit)
	local id = unit:GetPlayerID()
	_G.Players[id] = nil 
	_G.AliveTeams[unit:GetTeamNumber()] = nil
	_G.Teams[unit:GetTeamNumber()] = nil
	_G.Cplayers = _G.Cplayers - 1
	Game:CheckTeamsOnWin()
	unit:SetTimeUntilRespawn(9999)
	unit:SetBuybackCooldownTime(99999)
	WaveClass:KillsAllCreeps(unit:GetTeamNumber())
end
function Game:DeatCreep(unit)
	_G.killscreeps[unit.teamnumber] = _G.killscreeps[unit.teamnumber] + 1
	_G.CreepCounter[unit.teamnumber] = _G.CreepCounter[unit.teamnumber] - 1
	_G.creeps = _G.creeps - 1
	for i, unittable in pairs(_G.playercreeps[unit.teamnumber]) do
		if unit == unittable then
			table.remove(_G.playercreeps[unit.teamnumber], i)
			break  -- Выходим из цикла, так как элемент уже найден и удален
		end
	end
	
	CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "update_CreepCounts", {
		count = _G.CreepCounter[unit.teamnumber], 
		maxcount = _G.allcreeps[_G.round[unit.playerid]].count,
		team = unit.teamnumber
	})
	if _G.CreepCounter[unit.teamnumber] == 0 then
		CheckNextWave(unit)
	end
end


function CheckNextWave(unit)
	_G.Teams[unit.teamnumber] = false
	_G.round[unit.playerid] = _G.round[unit.playerid] + 1
		Timers:CreateTimer(0.01, function ()
			if _G.Teams[unit.teamnumber] == false then
				if not  _G.timerswaves[unit.playerid] then
					_G.timerswaves[unit.playerid] = {}
					_G.timerswaves[unit.playerid].secund = 30
					_G.timerswaves[unit.playerid].fullsecund = 30
				end
				CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "EndWave", {
					sec = _G.timerswaves[unit.playerid].secund,
					fullsec = _G.timerswaves[unit.playerid].fullsecund
				})
				_G.timerswaves[unit.playerid].secund = _G.timerswaves[unit.playerid].secund - 1
				if _G.timerswaves[unit.playerid].secund == 0 then
					if _G.Teams[unit.teamnumber] == false then
						WaveClass:StartWave(unit.playerid)
						_G.Teams[unit.teamnumber] = true
						_G.timerswaves[unit.playerid].secund = 30
						_G.timerswaves[unit.playerid].fullsecund = 30
					end
				end
				return 1
			end
			return 
		end)
end
function Game:SpawnRealHero(unit)
	
	local id = unit:GetPlayerID()
	unit.builderG = true
	_G.Players[id] = unit
	_G.AliveTeams[unit:GetTeamNumber()] = true
	_G.Teams[unit:GetTeamNumber()] = false
	_G.killscreeps[unit:GetTeamNumber()] = 0
	_G.Cplayers = _G.Cplayers + 1
	_G.towers[unit:GetTeamNumber()] = 0
	_G.incomes[id] = true
	_G.playercreeps[unit:GetTeamNumber()] = {}
	_G.round[id] = 1
	unit:FindAbilityByName("gold_tower"):SetLevel(1)
	unit:FindAbilityByName("repair_tower"):SetLevel(1)
end
function Game:CheckTeamsOnWin()
	print("3 "..WaveClass:countCheck(_G.AliveTeams))
	if _G.gamemode == "Solo" then
			GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
	else
		if WaveClass:countCheck(_G.AliveTeams)== 1 then
			for  teamnumber, team in pairs(_G.AliveTeams) do
				GameRules:SetGameWinner(teamnumber)
			end
		end
	end
end