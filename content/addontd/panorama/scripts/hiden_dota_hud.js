
var dotaHud = $.GetContextPanel().GetParent().GetParent().GetParent()



// Аганим
dotaHud.FindChildTraverse('AghsStatusScepterContainer').style.visibility = 'collapse'
dotaHud.FindChildTraverse('AghsStatusContainer').style.visibility = 'collapse'


// Таланты
dotaHud.FindChildTraverse('LevelUpTab').style.visibility = 'collapse'
dotaHud.FindChildTraverse('LevelUpGlow').style.visibility = 'collapse'
dotaHud.FindChildTraverse('LevelUpBurstFX').style.visibility = 'collapse'
dotaHud.FindChildTraverse('StatBranch').style.visibility = 'collapse'
dotaHud.FindChildTraverse('StatBranchOuter').style.visibility = 'collapse'

// Бай бек
dotaHud.FindChildTraverse('BuybackButton').style.visibility = 'collapse'
dotaHud.FindChildTraverse('Cooldown').style.visibility = 'collapse'

// Магазин
dotaHud.FindChildTraverse('ShopCourierControls').style.visibility = 'collapse'
dotaHud.FindChildTraverse('QuickBuyRows').style.visibility = 'collapse'
dotaHud.FindChildTraverse('shop').style.visibility = 'collapse'
dotaHud.FindChildTraverse('stash').style.visibility = 'collapse'
dotaHud.FindChildTraverse('shop_launcher_bg').style.visibility = 'collapse'

// Справа от инвенторя
dotaHud.FindChildTraverse('right_flare').style.visibility = 'collapse'
dotaHud.FindChildTraverse('inventory_composition_layer_container').style.visibility = 'collapse'

// Глиф
dotaHud.FindChildTraverse('GlyphScanContainer').style.visibility = 'collapse'


// dota hud

dotaHud.FindChildTraverse('topbar').style.visibility = 'collapse'


DOTA_HUD_ROOT = $.GetContextPanel().GetParent().GetParent().GetParent()
HideDOTAMinimap()


function HideDOTAMinimap() {
    let dotaMinimap = DOTA_HUD_ROOT.FindChildTraverse("minimap_container")
    if(dotaMinimap) {
        dotaMinimap.style.visibility = "collapse";
    } else {
        $.Msg("Valve break something again. Can't find panel with id='minimap_container'")
    }
}
