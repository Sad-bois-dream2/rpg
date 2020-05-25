var itemPanel;
var DELETE_TIMER_INTERVAL = 0.1;
var DELETE_TIMER = 5 + DELETE_TIMER_INTERVAL;
var dontDelete = false;

function OnClick() {
    itemPanel.DeleteAsync(0);
}

function OnMouseOut() {
    dontDelete = false;
}

function OnMouseOver() {
    dontDelete = true;
}

function OnDeleteTimerTick() {
    if(DELETE_TIMER < 0) {
        if(!dontDelete) {
            OnClick();
        }
    } else {
        DELETE_TIMER -= DELETE_TIMER_INTERVAL;
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