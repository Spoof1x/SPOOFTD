FormatTime = function(duration)
{   
    // Hours, minutes and seconds
    var hrs = ~~(duration / 3600);
    var mins = ~~((duration % 3600) / 60);
    var secs = ~~duration % 60;
    // Output like "1:01" or "4:03:59" or "123:03:59"
    var ret = "";
    if (hrs > 0) {
        ret += "" + hrs + ":" + (mins < 10 ? "0" : "");
    }
    ret += "" + mins + ":" + (secs < 10 ? "0" : "");
    ret += "" + secs;
    return ret;
}
function UpdateTeamsAndPlayers() {
    // Обновление игроков
    var heroesContainer = $.GetContextPanel().FindChildTraverse("HeroesSelected");
    if (!heroesContainer) {
        heroesContainer = $.CreatePanel("Panel", $.GetContextPanel(), "HeroesSelected");
        heroesContainer.AddClass("HeroesSelected");
    }
    heroesContainer.RemoveAndDeleteChildren();
    for (var teamId of Game.GetAllTeamIDs()) {
        var teamPlayers = Game.GetPlayerIDsOnTeam(teamId);
        for (var playerId of teamPlayers) {
            UpdatePlayer(playerId, heroesContainer);
        }
    }
    // Повторить обновление через определенный промежуток времени
    $.Schedule(0.01, UpdateTeamsAndPlayers);
}
UpdateTeamsAndPlayers()
function UpdatePlayer(playerId, container) {
    var playerPanelName = "player_" + playerId;
    var playerPanel = container.FindChild(playerPanelName);
    var playerGold
    if (playerPanel === null) {
        playerPanel = $.CreatePanel("Image", container, playerPanelName);
        playerPanel.BLoadLayout("file://{resources}/layout/custom_game/multiteam_hero_select_overlay_player.xml", false, false);
        playerPanel.AddClass("PlayerPanel");
        playerGold = $.CreatePanel("Label", playerPanel, "GoldPlayer")
        playerGold.style.color = "yellow";
        playerGold.style.marginLeft  = 25+ "px"
        playerGold.style.fontSize  = 40 + "px"
    } 
	var maxPlayersPerRow = 4;
    var playerWidth = 220;
    var playerHeight = 200;
    // Разбиваем на два ряда по 5 игроков в каждом
    var row = Math.floor(playerId / maxPlayersPerRow);
    // Если четный ряд, сдвигаем на половину ширины контейнера
    var offset = row % 2 === 0 ? maxPlayersPerRow * playerWidth * 0.3 : 0;
    // Позиционирование героя внутри контейнера
    var positionX = (playerId % maxPlayersPerRow) * playerWidth + offset;
    var positionY = row * playerHeight;
    if (playerId > 1 ) {
        positionX = (playerId % maxPlayersPerRow) * playerWidth + offset + 500
    }
    playerPanel.style.position = positionX + "px " + positionY + "px 0px";
	var playerInfo = Game.GetPlayerInfo( playerId );
	if ( !playerInfo )
		return;
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if ( !localPlayerInfo )
		return;
	var localPlayerTeamId = localPlayerInfo.player_team_id;
	var playerPortrait = playerPanel.FindChildInLayoutFile( "PlayerPortrait" );
    playerPortrait.SetImage( "file://{images}/heroes/" + playerInfo.player_selected_hero + ".png" );
    button = $.CreatePanel("Button", playerPortrait, "SetPlayer" )
    button.style.height = 100 + "px"
    button.style.width = 100 + "px"
    button.SetPanelEvent("onmouseover", () => {
        if (GameUI.IsAltDown() ){
        GameUI.MoveCameraToEntity(playerInfo.player_selected_hero_entity_index)
    }
    })
    button.style.height = 100 + "%";
    button.style.width = 100 + "%";
	var playerName = playerPanel.FindChildInLayoutFile( "PlayerName" );
    playerName.text = ""
    if (GameUI.IsAltDown() ){
        playerName.style.fontSize = 25 + "px"
        playerName.text = playerInfo.player_name;
    }
    if (playerGold) {
        if (playerInfo.player_gold < 10 ) {
            playerGold.style.marginLeft = playerGold.style.marginLeft  = 35+ "px"
        }
        if (playerInfo.player_gold > 99 ) {
            playerGold.style.marginLeft = playerGold.style.marginLeft  = 14+ "px"
        }
        if (playerInfo.player_gold > 999 ) {
            playerGold.style.marginLeft = playerGold.style.marginLeft  = 4+ "px"
        }
        if (playerInfo.player_gold > 9999 ) {
            playerGold.style.marginLeft = playerGold.style.marginLeft  = -5+ "px"
        }
        playerGold.text = playerInfo.player_gold
    }
    if (Players.GetTeam(Players.GetLocalPlayer()) == 2) {
        GameUI.SetCameraYaw(0)
    }
    if (Players.GetTeam(Players.GetLocalPlayer()) == 3) {
        GameUI.SetCameraYaw(90)
    }
    if (Players.GetTeam(Players.GetLocalPlayer()) == 6) {
        GameUI.SetCameraYaw(270)
    }
    if (Players.GetTeam(Players.GetLocalPlayer()) == 7) {
        GameUI.SetCameraYaw(180)
    }
}
function SetExpanded( ){ 
    if( $("#text").text == $.Localize("#Show_Details") ) {
        $("#InfoRow").style.height = 300 + "px"  
        $("#TopContainer").style.visibility = "visible"
        $("#text").text = $.Localize("#Hide_Details")
    } else {
        $("#InfoRow").style.height = 100 + "px"
        $("#TopContainer").style.visibility = "collapse"
        $("#text").text = $.Localize("#Show_Details")
    }
	Game.EmitSound("General.ButtonClick")
}
LockIncome = true
function updateIncomeText(id) {
    if (LockIncome) {
        $('#IncomeText').text =  Math.round(Players.GetGold(id) * 0.01)
    }
}
let towers = { "0" : 0, "1" : 0 ,"2" : 0, "3" : 0}
let round = { "0" : 0, "1" : 0 ,"2" : 0, "3" : 0};
let creepcount = { "0" : 0, "1" : 0 ,"2" : 0, "3" : 0}
let maxcreepcount = { "0" : 10, "1" : 10 ,"2" : 10, "3" : 10}
let creepname = { "0" : "npc_dota_neutral_kobold", "1" : "npc_dota_neutral_kobold" ,"2" : "npc_dota_neutral_kobold", "3" : "npc_dota_neutral_kobold"};

IsPodgotovka = false
function PlayerInfoThink(){
    $('#GameTimerText').text = FormatTime(Game.GetDOTATime(false, false))
    $.Schedule( 0.00000001, PlayerInfoThink );
    var nUnitIndex = Players.GetLocalPlayerPortraitUnit();
    var nObservedPlayer = Entities.GetPlayerOwnerID( nUnitIndex );
    if( nObservedPlayer <  0 ){
        nObservedPlayer = Players.GetLocalPlayer();
    } 
    if (nObservedPlayer !=  Players.GetLocalPlayer()) {
        $("#stats").text = "Статистика вражеского героя доступна только по подписке"
        $("#st1").style.visibility = "collapse"
        $("#CurrentWaves").style.visibility = "collapse"
        $("#WaveTimerProgressBackground").style.visibility = "collapse"
        $("#ButtonReady").style.visibility = "collapse"
        $("#WaveTimerIcon").style.visibility = "collapse"
        $("#CreepName").text = "Подробный просмотр доступен только по подписке"
        $("#CurrentGoldText").text = 0
        $("#ToogleButtonReady").style.visibility = "collapse"
    } else {
        $("#stats").text = "Статистика"
        $("#st1").style.visibility = "visible"
        $("#CurrentWaves").style.visibility = "visible"
        $("#WaveTimerIcon").style.visibility = "visible"
        $("#WaveTimerProgressBackground").style.visibility = "visible"
        $("#ToogleButtonReady").style.visibility = "visible"
        if (IsPodgotovka) {
            $("#ButtonReady").style.visibility = "visible" 
            $("#CreepName").text = $.Localize("#fixNewWave")
        } else {
            $("#ButtonReady").style.visibility = "collapse"
            $("#CreepName").text = $.Localize("#" + creepname[nObservedPlayer])
        }
    }
    updateIncomeText(nObservedPlayer);
    $('#CurrentGoldText').text = Players.GetGold(nObservedPlayer);
    $("#TowersText").text = towers[nObservedPlayer];
    if (IsPodgotovka) {
    } else {
        $("#CurrentWaves").text = "Раунд: " + round[nObservedPlayer];
        $("#WaveTimersValue").text = creepcount[nObservedPlayer] + "/" + maxcreepcount[nObservedPlayer];
        $("#WaveTimerProgress").style.width = (parseInt(creepcount[nObservedPlayer]) / parseInt(maxcreepcount[nObservedPlayer]) * 100) + "%";
    }
}
function update_round(event) {
    IsPodgotovka = false
    round[Players.GetLocalPlayer()] = event.round;
}
function update_CreepCounts(event) {
    creepcount[Players.GetLocalPlayer()] = event.count;
    maxcreepcount[Players.GetLocalPlayer()] = event.maxcount;
}
function update_CreepName(event) {
    creepname[Players.GetLocalPlayer()] = event.name;
}




function TipsOver(message, pos) {
	if ($("#" + pos) != undefined) {
		$.DispatchEvent("DOTAShowTextTooltip", $("#" + pos), $.Localize(`#${message}`));
	}
} 
function TipsOut() {
	$.DispatchEvent("DOTAHideTitleTextTooltip");
	$.DispatchEvent("DOTAHideTextTooltip");
}
PlayerInfoThink();


function update_CountTowers(event) {
    towers = event.count
    
}

function EndWave(event) {
    IsPodgotovka = false
    $("#WaveTimersValue").text = event.sec + "/" + event.fullsec
    $("#WaveTimerProgress").style.width = event.sec/event.fullsec*100 + "%"

    if (IsPodgotovka) {
    } else {
        $("#ButtonReady").style.visibility = "visible"
        $("#ButtonReady").style.backgroundColor = "black"
        $("#ButtonReadyText").text = "Готов!";



        IsPodgotovka = true
    }
    if ($("#ToogleButtonReady").checked) {
        HeroReady()
    }  
    UnLockIncome()
}


function LockIncome() {
    LockIncome = false
}
function UnLockIncome() {
    LockIncome = true
}
GameEvents.Subscribe( "update_round", update_round);
GameEvents.Subscribe( "update_CreepCounts", update_CreepCounts);
GameEvents.Subscribe( "update_CreepName", update_CreepName);
GameEvents.Subscribe( "update_CountTowers", update_CountTowers);
GameEvents.Subscribe( "EndWave", EndWave); 


GameEvents.Subscribe( "LockIncome", LockIncome);
GameEvents.Subscribe( "EndReadyTimer", EndReadyTimer); 
GameEvents.Subscribe( "UpdateReadyTimer", UpdateReadyTimer); 



GameEvents.Subscribe( "CloseStartGameTimer", CloseTimer);


function CloseTimer() {
    $("#VerticalFlow").style.visibility = "visible"
}

ButtonsReady = {}
function EndReadyTimer() {
    ButtonsReady[Players.GetLocalPlayer()] = null
    $("#ButtonReady").style.visibility = "collapse"
}
function HeroReady() {
    Game.EmitSound("General.ButtonClick")
    if (ButtonsReady[Players.GetLocalPlayer()] == $("#ButtonReady")) {
        ButtonsReady[Players.GetLocalPlayer()] = null
        $("#ButtonReady").style.visibility = "visible"
        $("#ButtonReady").style.backgroundColor = "black"
        $("#ButtonReadyText").text = "Готов!";
        GameEvents.SendCustomGameEventToServer( "HeroIsReadyCancel", {
            id : Players.GetLocalPlayer(),
        });
    } else {
        GameEvents.SendCustomGameEventToServer( "HeroIsReadyReal", {
            id : Players.GetLocalPlayer(),
        });
        $("#ButtonReady").style.backgroundColor = "green";
        ButtonsReady[Players.GetLocalPlayer()] = $("#ButtonReady")
        $("#ButtonReadyText").text = "Отмена! 6с";

    }
    
    
}
function UpdateReadyTimer(data) {
    $("#ButtonReadyText").text = "Готов! " + data.sec + "с";
}

