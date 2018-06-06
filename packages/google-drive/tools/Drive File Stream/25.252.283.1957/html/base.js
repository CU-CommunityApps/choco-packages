/**
 * Sends the log back to c++ code and also prints it out on debug console.
 * @param {string} msg The log message.
 */
function log(msg) {
  window.console.log(msg);
  sendCefRequest_('log=' + msg);
}


/**
 * Gets called when an error is thrown.
 * @param {string} error The error message.
 * @param {string} url URL of the script where the error was thrown.
 * @param {number} line Line number where error was thrown.
 */
window.onerror = function(error, url, line) {
  log('Script error in ' + url + ' (line ' + line + '): ' + error);
};


/**
 * Sends a request to c++ code via Cef framework.
 * @param {string} msg The message.
 * @param {?Function} onSuccess The (optional) callback that is called when the
 * message is sent successfully.
 * @private
 */
 function sendCefRequest_(msg, onSuccess) {
   const callback = onSuccess || function() {};
   window.cefQuery({
     request: msg,
     persistent: false,
     onSuccess: callback,
     onFailure: (error_type, error_msg) => console.log(msg, error_msg),
  });
}


/**
 * Is called when the DOMContentLoaded JavaScript event is fired. This is called
 * when the DOM is fully loaded, before all assets, e.g., images, have been
 * loaded.
 */
function baseOnReady() {
  // Don't allow dragging of images.
  $('img').on('dragstart', false);

  sendCefRequest_('dom_ready');
}
$(document).ready(baseOnReady);


/**
 * Convert from base64 encoded UTF-8 to UTF-16 DOMString.
 * See
 * https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
 * @param {string} str base64 encoded UTF-8 string.
 * @return {string} UTF-16 DOMString.
 * @private
 */
function base64DecodeToUnicode_(str) {
  return decodeURIComponent(atob(str).split('').map(function (c) {
    return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
  }).join(''));
}


/**
 * Updates the view.
 * @param {string} updateJsonBase64 the json, in base 64, that contains fields
 *    to update the html view. Should be generated from
 *    |cello::fs::UpdateViewRequest| proto.
 */
function updateViewInternal(updateJsonBase64) {
  const update = JSON.parse(base64DecodeToUnicode_(updateJsonBase64));
  if (update.common) {
    $('html').attr('lang', update.common.language);
    if (update.common.is_rtl) {
      $('html').attr('dir', 'rtl');
    }
  }
  updateView(update);
}
