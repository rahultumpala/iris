const entityScriptId = "globalStateEntity";

export default function loadScript(successCallback, failureCallback) {
    // fs module cannot be used for security reasons
    // so load the entity.js dynamically

    // adding the script element to the head
    var head = document.getElementsByTagName("head")[0];
    var script = document.createElement("script");
    script.id = entityScriptId;
    script.type = "text/javascript";
    script.src = "entity.js";

    // then bind the event to the callback function
    // there are several events for cross browser compatibility
    script.onreadystatechange = successCallback;
    script.onload = successCallback;
    script.onerror = failureCallback;

    // fire the loading
    head.appendChild(script);
}