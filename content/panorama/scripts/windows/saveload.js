var heroInfoPanel;

function ShowHeroInfo() {
    $.Msg($.GetContextPanel());
    heroInfoPanel.style.visibility = "visible";
}

function HideHeroInfo() {
    heroInfoPanel.style.visibility = "collapse";
}

(function() {
    heroInfoPanel = $("#SaveSlotHeroPreview");
})();