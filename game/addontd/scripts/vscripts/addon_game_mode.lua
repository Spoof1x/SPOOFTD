

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
_G.round = 1

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
		_G.killscreeps[unit.teamnumber] = _G.killscreeps[unit.teamnumber] + 1
		_G.CreepCounter[unit.teamnumber] = _G.CreepCounter[unit.teamnumber] - 1
		CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "UpdateCreepCount", {
			count = _G.CreepCounter[unit.teamnumber],
		})
		if _G.CreepCounter[unit.teamnumber]  == 0 then
			_G.Teams[unit.teamnumber] = true
			CustomGameEventManager:Send_ServerToTeam(unit.teamnumber, "EndCreepCount", {})
		end
		Game:CheckTeams()

	end
	if unit.builder then
		local id = unit:GetPlayerID()
		_G.Players[id] = nil 
		_G.AliveTeams[unit:GetTeamNumber()] = false
		_G.Teams[unit:GetTeamNumber()] = false
		_G.Cplayers = _G.Cplayers - 1
		Game:CheckTeamsOnWin()
        unit:SetTimeUntilRespawn(9999)
        unit:SetBuybackCooldownTime(99999)
		
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
		local id = npc:GetPlayerID()
		npc.builder = true
		_G.Players[id] = npc
		_G.AliveTeams[npc:GetTeamNumber()] = true
		_G.Teams[npc:GetTeamNumber()] = false
		_G.killscreeps[npc:GetTeamNumber()] = 0
		_G.Cplayers = _G.Cplayers + 1
		npc:FindAbilityByName("gold_tower"):SetLevel(1)
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

        local allTeamsReady = true

		for k, team in pairs(_G.Teams) do
			if not team then 
				
				allTeamsReady = false
			end
		end

        if allTeamsReady then
			for k, team in pairs(_G.Teams) do
				_G.Teams[k] = false
			end
            WaveClass:NextWave()
        else
        end
end

function Game:CheckTeamsOnWin()
	if _G.gamemode == "Solo" then
			GameRules:SetGameWinner(DOTA_TEAM_NEUTRALS)
		elseif _G.gamemode == "Duo" then
            for team, isAlive in pairs(_G.AliveTeams) do
                if isAlive then
                    GameRules:SetGameWinner(team)
                end
            end
        elseif _G.gamemode == "Trio" then
			alives = 0
			for team, isAlive in pairs(_G.AliveTeams) do
                if isAlive then
                    alives = alives + 1
                end
            end
			if alives == 1 then
				for team, isAlive in pairs(_G.AliveTeams) do
					if isAlive then
						GameRules:SetGameWinner(team)
					end
				end
			end
		elseif _G.gamemode == "All" then
			alives = 0
			for team, isAlive in pairs(_G.AliveTeams) do
                if isAlive then
                    alives = alives + 1
                end
            end
			if alives == 1 then
				for team, isAlive in pairs(_G.AliveTeams) do
					if isAlive then
						GameRules:SetGameWinner(team)
					end
				end
			end
        end
end