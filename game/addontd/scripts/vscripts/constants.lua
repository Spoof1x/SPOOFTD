_G.lua.PlayerServerData = {}          -- инфа с сервера // Note: games, wins, mmr , etc


_G.lua.killscreeps = {}
_G.lua.CreepCounter = {} -- число крипов для каждого игрока // Using: print(_G.lua.CreepCounter[PLAYERID])  - Console: 3
_G.lua.Teams = {}		-- для таймера чтото
_G.lua.gamemode = "no"  -- режим игры  // Note: Solo, Duo, Trio, All(squad)
_G.lua.Players = {} -- массив игроков для инфы через id       // Using: _G.lua.Players[PLAYERID]:GetTeamNumber()

_G.lua.Cplayers = 0 -- Число игроков

_G.lua.TeamNumber = {  		--
	good = "2",				--
	bad = "3",				-- просто обозначения команд
	custom1 = "6",			--
	custom2 = "7",			--
}							--
_G.lua.AliveTeams = {}				-- содержит id живых игроков
_G.lua.round = {}					-- число раундов
_G.lua.towers = {}					-- число башен по айди игроков
_G.lua.incomes = {}					-- массив   {id = true/false} разрешен ли инкам
_G.lua.playercreeps = {}			-- массив крипов плеер по id
_G.lua.timerswaves = {}				-- массив для инфы между раундами
_G.lua.RealReady = {}				-- массив игроков кто нажал кнопку готов и готовится к следующему раунду
_G.lua.TimeRealReady = {}			-- массив игроков кто уже 
_G.lua.stoptimer = {}				-- я уже сам запутался честно xD


-- waves

_G.lua.spawners = {[2] = "path1", [3] = "path100",[6] = "path50", [7] = "path150",}
_G.lua.spawnersNames = {[2] = "path1", [3] = "path100",[6] = "path50", [7] = "path150",}
_G.lua.allcreeps = {
[1]  =  {name = "npc_dota_skeleton", count = 1, health = 100, cost = 5,},
[2]  =  {name = "npc_dota_neutral_kobold", count = 1, health = 100, cost = 5,},
[3]  =  {name = "npc_dota_creep_goodguys_melee", count = 1, health = 100, cost = 5,},
[4]  =  {name = "npc_dota_creep_goodguys_melee", count = 1, health = 100, cost = 5,},
[5]  =  {name = "npc_dota_centaur_outrunner", count = 15, health = 100, cost = 5,},
[6]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[7]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[8]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[9]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[10]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[11]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[12]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[13]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[14]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[15]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},
[16]  =  {name = "npc_dota_creep_goodguys_melee", count = 10, health = 100, cost = 5,},

}
_G.lua.particle ={}


