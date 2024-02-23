var goldtext = $("#GoldLabel");
var goldIcon = $("#GoldIcon");

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
