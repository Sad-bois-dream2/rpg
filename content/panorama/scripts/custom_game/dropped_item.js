var itemPanel;
var DELETE_TIMER_INTERVAL = 0.1;
var DELETE_TIMER = 5 + DELETE_TIMER_INTERVAL;

function OnClick() {
    itemPanel.DeleteAsync(0);
}

function OnDeleteTimerTick() {
    DELETE_TIMER -= DELETE_TIMER_INTERVAL;
    if(DELETE_TIMER < 0) {
        OnClick();
    }
}

function StartDeleteTimer() {
    OnDeleteTimerTick();
    $.Schedule(DELETE_TIMER_INTERVAL, function() {
        StartDeleteTimer();
    });
}

(function() {
    itemPanel = $.GetContextPanel();
    StartDeleteTimer();
})();