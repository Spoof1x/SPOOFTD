var goldtext = $("#GoldLabel");
var goldIcon = $("#GoldIcon");
var CountCreep = $("#CountCreep");

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



function update_creep_count(event) {
    if (event.count) {
        CountCreep.style.visibility = "visible";
        CountCreep.text = event.count
    } else {
        var NewCount = parseInt(CountCreep.text) - 1
        if (NewCount <= 0 ) {
            CountCreep.style.visibility = "collapse";
        }
        CountCreep.text = NewCount
    }
    
}
function EndCreepCount(event) {
    CountCreep.style.visibility = "collapse";
    
}

GameEvents.Subscribe( "UpdateCreepCount", update_creep_count);

GameEvents.Subscribe( "EndCreepCount", EndCreepCount);







