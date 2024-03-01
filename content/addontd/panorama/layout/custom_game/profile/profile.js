function IconProfilePress() {
  
    $("#bg_profile").ToggleClass("OpenThis")
   
}

function update_profile(event) {
    $.Msg(event)
    $("#games_count").text = event.games
    $("#wins_count").text = event.wins
    $("#mmr_count").text = event.mmr
}


GameEvents.Subscribe( "ProfileUpdate", update_profile);


function http_request(url, method) {
    GameEvents.SendCustomGameEventToServer( "http_request", {
        url : url,
        method : method,
    });
}
