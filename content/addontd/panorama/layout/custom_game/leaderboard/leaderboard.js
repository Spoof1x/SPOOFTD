let DOTA_HUD_ROOT;

function HideDOTAMinimap() {
    let dotaMinimap = DOTA_HUD_ROOT.FindChildTraverse("minimap_container")
    if(dotaMinimap) {
        dotaMinimap.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='minimap_container'")
    }
}

function HideTopbar() {
    let topbar = DOTA_HUD_ROOT.FindChildTraverse("topbar")
    if(topbar) {
        topbar.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='topbar'")
    }
}

function HideTalentTree() {
    let talentTree = DOTA_HUD_ROOT.FindChildTraverse("StatBranch")
    if(talentTree) {
        talentTree.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='StatBranch'")
    }
}

function HideAghsStatus() {
    let agshStatus = DOTA_HUD_ROOT.FindChildTraverse("AghsStatusContainer")
    if(agshStatus) {
        agshStatus.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='AghsStatusContainer'")
    }
}

function HideTPAndNeutralSlotsContainer() {
    let inventoryNeutralAndTPSlotsContainer = DOTA_HUD_ROOT.FindChildTraverse("inventory_composition_layer_container")
    if(inventoryNeutralAndTPSlotsContainer) {
        inventoryNeutralAndTPSlotsContainer.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='inventory_composition_layer_container'")
    }
    let rightFlare = DOTA_HUD_ROOT.FindChildTraverse("right_flare")
    if(rightFlare) {
        rightFlare.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='right_flare'")
    }
}

function HideTopHUDLeftButtons() {
    let leftButtonsContainer = DOTA_HUD_ROOT.FindChildTraverse("ButtonBar")
    if(leftButtonsContainer) {
        leftButtonsContainer.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='ButtonBar'")
    }
}

function HideKillCam() {
    let killCamContainer = DOTA_HUD_ROOT.FindChildTraverse("KillCam")
    if(killCamContainer) {
        killCamContainer.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='KillCam'")
    }
}

function LoadTabContainer() {
    let container = $("#RightFirstChild")
    container.BLoadLayout("file://{resources}/layout/custom_game/tab_container.xml", false, false)
}

function LoadPlayerInfo() {
    let container = $("#RightSecondChild")
    container.BLoadLayout("file://{resources}/layout/custom_game/player_info.xml", false, false)
}

function LoadCustomTopHUDLeftButtons() {
    let container = $("#LeftFirstChild")
    container.BLoadLayout("file://{resources}/layout/custom_game/top_control_buttons.xml", false, false)
}

function LoadLeaderboard() {
    let container = $("#LeftSecondChild")
    container.BLoadLayout("file://{resources}/layout/custom_game/leaderboard.xml", false, false)
}

function LoadCustomDOTAMinimap() {
    let container = $("#LeftThirdChild")
    container.BLoadLayout("file://{resources}/layout/custom_game/minimap.xml", false, false)
}
function OpenUpgrades(){
    var a = $("#RightFirstChild")
    a.AddClass("open_upgr_anim")  
    a.visible = true
    $.Schedule(0.2, function() {
        if (a){
            a.RemoveClass("open_upgr_anim")
        }
    })
}
(function() {
    DOTA_HUD_ROOT = $.GetContextPanel().GetParent().GetParent().GetParent()
    HideDOTAMinimap()
    HideTopbar()
    HideTalentTree()
    HideAghsStatus()
    HideTopHUDLeftButtons()
    HideTPAndNeutralSlotsContainer()
    HideKillCam() 
    LoadCustomDOTAMinimap()
    LoadLeaderboard()
    LoadTabContainer()
    LoadPlayerInfo()
    LoadCustomTopHUDLeftButtons()
})();