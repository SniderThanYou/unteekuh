$(function(){
    $.xhrPool = [];

    $(document).ajaxSend(storeRequest);
    $(document).ajaxComplete(removeRequest);
    $(document).ajaxError(handleError);

    function storeRequest(e, jqXHR){
        $.xhrPool.push(jqXHR);
    }
    function removeRequest(e, jqXHR) {
        $.xhrPool = $.grep($.xhrPool, function(x){return x!==jqXHR;});
    }
    function handleError(event, jqXHR, ajaxSettings, thrownError){
        function isAborted(){
            return jqXHR.readyState === 0 || jqXHR.status === 0;
        }
        function globalErrorAlertEnabled() {
            return !ajaxSettings.disableGlobalErrorAlert;
        }
        function handleAbortedRequest(){
            console.warn('[globalAjaxHandler] Ignoring aborted request: ' + ajaxSettings.type + ' ' + ajaxSettings.url);
        }
        function handleErrorResponse(){
            function getMessage(responseText){
                var feedback;
                try {
                    var response = $.parseJSON(responseText);
                    var error = response.message || response.error;
                    feedback = error || responseText;
                } catch(e) {
                    feedback = responseText;
                }
                return feedback;
            }
            alert(getMessage(jqXHR.responseText));
        }

        if (jqXHR.handled)
            return;

        if (isAborted())
            handleAbortedRequest();
        else if (globalErrorAlertEnabled())
            handleErrorResponse();
    }
});
