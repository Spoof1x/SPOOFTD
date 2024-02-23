const timer = $("#timer")
const time_panel = $("#time")
function Updatetimer(data) {
    var sec = data.sec
    time_panel.text = sec
}
function CloseTimer() {
    timer.style.visibility = "collapse"
}





GameEvents.Subscribe( "UpdateStartGameTimer", Updatetimer);
GameEvents.Subscribe( "CloseStartGameTimer", CloseTimer);










































function print(args) {
    $.Msg(args)
}