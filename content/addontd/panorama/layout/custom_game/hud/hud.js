






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

GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false );




function SetExpanded( ){ 

    if( $("#text").text == $.Localize("#Show_Details") ) {
        $("#TopContainer").style.visibility = "visible"
        $("#BottomContainer").style.visibility = "visible"
        $("#InfoRow").style.visibility = "visible"
        $("#text").text = $.Localize("#Hide_Details")
        
    } else {
        $("#InfoRow").style.visibility = "collapse"
        $("#BottomContainer").style.visibility = "collapse"
        $("#InfoRow").style.visibility = "collapse"
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

let towers = { "2" : 0, "3" : 0 ,"6" : 0, "7" : 0}
let round = { "2" : 1, "3" : 1,"6" : 1, "7" : 1};
let creepcount = { "2" :  10, "3" : 10, "6" : 10, "7" :  10,}
let maxcreepcount = { "2" :  10, "3" : 10, "6" : 10, "7" :  10,}
let creepname = { "2" : "npc_dota_neutral_kobold", "3" : "npc_dota_neutral_kobold" ,"6" : "npc_dota_neutral_kobold", "7" : "npc_dota_neutral_kobold"};

IsPodgotovka = false
function PlayerInfoThink(){
    $.Schedule( 0.00000001, PlayerInfoThink );
    var nUnitIndex = Players.GetLocalPlayerPortraitUnit();
    var nObservedPlayer = Entities.GetPlayerOwnerID( nUnitIndex );

    if( nObservedPlayer <  0 ){
        nObservedPlayer = Players.GetLocalPlayer();
    } 

    if (nObservedPlayer !=  Players.GetLocalPlayer()) {
        
        $("#stats").text = "Статистика вражеского героя доступна только по подписке"
        $("#st1").style.visibility = "collapse"
        $("#CurrentGoldText").text = 0
    } else {
        $("#stats").text = "Статистика"
        $("#st1").style.visibility = "visible"
        
    }
    updateIncomeText(nObservedPlayer);
    $('#CurrentGoldText').text = Players.GetGold(nObservedPlayer);
    $("#TowersText").text = towers[Players.GetTeam(nObservedPlayer)];
    if (IsPodgotovka) {
    } else {

        
        $("#CurrentWaves").text = "Раунд: " + round[Players.GetTeam(nObservedPlayer)];

        $("#WaveTimersValue").text = creepcount[Players.GetTeam(nObservedPlayer)] + "/" + maxcreepcount[Players.GetTeam(nObservedPlayer)];
        $("#WaveTimerProgress").style.width = (parseInt(creepcount[Players.GetTeam(nObservedPlayer)]) / parseInt(maxcreepcount[Players.GetTeam(nObservedPlayer)]) * 100) + "%";
        $("#CreepName").text = $.Localize("#" + creepname[Players.GetTeam(nObservedPlayer)]);
    }
       
}

function update_round(event) {
    IsPodgotovka = false
    round[event.team] = event.round;
}

function update_CreepCounts(event) {
    creepcount[event.team] = event.count;
    maxcreepcount[event.team] = event.maxcount;
}

function update_CreepName(event) {
    creepname[event.team] = event.name;
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



GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_TIMEOFDAY, false );
GameUI.SetDefaultUIEnabled( DotaDefaultUIElement_t.DOTA_DEFAULT_UI_TOP_HEROES, false );



function SpawnerThink(){
	$('#GameTimerText').text = FormatTime(Game.GetDOTATime(false, false))
	var nUnitIndex = Players.GetLocalPlayerPortraitUnit();
	var nObservedPlayer = Entities.GetPlayerOwnerID( nUnitIndex );
	if( nObservedPlayer < 0 ){
		nObservedPlayer = Players.GetLocalPlayer();
	}
 
	$.Schedule( 0.05, SpawnerThink );
}



(function() {
	SpawnerThink();
})();









function update_CountTowers(event) {
    towers = event.count
    
}

function EndWave(event) {
    IsPodgotovka = true
    $("#WaveTimersValue").text = event.sec + "/" + event.fullsec
    $("#WaveTimerProgress").style.width = event.sec/event.fullsec*100 + "%"
    $("#CreepName").text = $.Localize("#fixNewWave")

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

