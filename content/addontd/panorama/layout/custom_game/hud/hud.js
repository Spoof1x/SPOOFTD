var goldtext = $("#GoldLabel");
var goldIcon = $("#GoldIcon");
var wave = $("#CountCreep");
var RoundPanel = $("#wave")
function updateGold() {
    if (Players.GetGold(Players.GetLocalPlayer()) >= 1000) {
        goldIcon.RemoveClass("left2");
        goldIcon.RemoveClass("left");
        goldIcon.AddClass("left1"); // добавляем класс для большого отступа слева
    } 
    if (Players.GetGold(Players.GetLocalPlayer()) >= 10000) {
        goldIcon.RemoveClass("left1");
        goldIcon.RemoveClass("left");
        goldIcon.AddClass("left2"); // удаляем класс для большого отступа слева
    } 
    if (Players.GetGold(Players.GetLocalPlayer()) < 1000)
    {
        goldIcon.RemoveClass("left1");
        goldIcon.RemoveClass("left2");
        goldIcon.AddClass("left");
    }
    goldtext.text = Players.GetGold(Players.GetLocalPlayer()); // устанавливаем текст золота

    $.Schedule(0.001, updateGold); // вызываем сами себя каждую миллисекунду
}

// Запускаем обновление золота
updateGold();

let JA = 10;

function update_creep_count(event) {
    $("#WinWave").style.visibility = "collapse"
    RoundPanel.style.visibility = "visible";
    count = event.count
    round = event.round
    maxcount = event.maxcount
    name = event.name

    check = true

    if (round) {
        check = false
        $("#CountRound").text = "РАУНД " + round
    }
    if (name) {
        check = false
        $("#NameCreep").text = $.Localize("#" + name)
    }
    if (maxcount) {
        check = false
        JA = maxcount
    }
    if (count) {
        check = false
        $("#CountCreep").text = count + "/" + JA
    }

    if (check) {
        $("#WinWave").style.visibility = "visible"
        $("#CountCreep").text = 0 + "/" + JA
    }
    
}


GameEvents.Subscribe( "UpdateCreepCount", update_creep_count);

GameEvents.Subscribe( "EndCreepCount", update_creep_count);







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
    
    
	var maxPlayersPerRow = 10;
    var playerWidth = 125;
    var playerHeight = 100;

    // Разбиваем на два ряда по 5 игроков в каждом
    var row = Math.floor(playerId / maxPlayersPerRow);
    
    // Если четный ряд, сдвигаем на половину ширины контейнера
    var offset = row % 2 === 0 ? maxPlayersPerRow * playerWidth * 0.3 : 0;

    // Позиционирование героя внутри контейнера
    var positionX = (playerId % maxPlayersPerRow) * playerWidth + offset;
    var positionY = row * playerHeight;

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
    
	
}