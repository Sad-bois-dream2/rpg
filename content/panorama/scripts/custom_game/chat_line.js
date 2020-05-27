var UPDATE_INTERVAL = 0.1;
var chatLineExpireTime = 7 + UPDATE_INTERVAL;

function CheckChatLineTimer() {
    chatLineExpireTime -= UPDATE_INTERVAL;
    if(chatLineExpireTime < 0) {
        $.GetContextPanel().SetHasClass("NotReallyExpired", false);
        return;
    }
    $.Schedule(UPDATE_INTERVAL, function() {
        CheckChatLineTimer();
    });
}

(function() {
    CheckChatLineTimer();
})();