
function MiniMapMaximize(){
	var ToggleButton = $("#MiniMapMaximizeOrMinimize");
	ToggleButton.IsSelected = true;
	var MiniMap = $("#minimap");
	MiniMap.style.width = "800px";
	MiniMap.style.height = "800px";
}

function MiniMapMinimize(){
	var ToggleButton = $("#MiniMapMaximizeOrMinimize");
	ToggleButton.IsSelected = false;
	var MiniMap = $("#minimap");
	MiniMap.style.width = "256px";
	MiniMap.style.height = "256px";
}