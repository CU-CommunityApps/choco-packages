/**
 * Updates the view.
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto.
 */
function updateView(update) {
  if (update.about) {
    $('#title').text(update.about.title);
    $('#version').text(update.about.version);
    $('#copyright').text(update.about.copyright);
    $('#open-source-software').text(update.about.open_source_software);
    $('#terms-of-service').text(update.about.terms_of_service);
  }
  if (update.common) {
    $('#logo').attr('alt', update.common.google_drive_fs_logo_alt_text);
  }
}

/**
 * Opens the open source software list URL in the user's browser.
 * @private
 */
function openSourceSoftware_() {
  sendCefRequest_('open_open_source_software');
}

/**
 * Opens the "Terms of Service" URL in the user's browser.
 * @private
 */
function openTermsOfService_() {
  sendCefRequest_('open_terms_of_service');
}

/**
 * Called when the DOMContentLoaded JavaScript event is fired. This is called
 * when the DOM is fully loaded, before all assets, e.g., images, have been
 * loaded.
 */
function onReady() {
  // Keybind the escape key to close the About Dialog when pressed.
  $(document).keyup((e) => {
    if (e.keyCode == 27) {  // KeyCode 27 == Escape Key.
      window.close();
    }
  });
}
$(document).ready(onReady);
