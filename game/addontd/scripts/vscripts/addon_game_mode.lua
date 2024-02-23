

require("libraries/buildinghelper")
require("waves")


_G.Players = {}
_G.Cplayers = 0
_G.TeamNumber = {
	good = "2",
	bad = "3",
	custom1 = "6",
	custom2 = "7",
}
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
		_G.Players[id] = npc
		
		_G.Cplayers = _G.Cplayers + 1
    end
end

function Game:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end