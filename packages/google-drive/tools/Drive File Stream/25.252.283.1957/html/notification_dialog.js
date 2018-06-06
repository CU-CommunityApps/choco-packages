/**
 * Updates the view.
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto
 */
function updateView(update) {
  if (update.common) {
    $('#drive-logo').attr('alt', update.common.google_drive_fs_logo_alt_text);
  }

  if (update.notification) {
    const resources = update.notification.resources;
    if (resources) {
      $('#title').text(resources.trouble_updating_multiple_items);
      $('#close-button').text(resources.ok_button);
      $('#lost-and-found-notice').html(resources.lost_and_found_notice);
      $('#lost-and-found')
          .attr('href', 'javascript: void(0)')
          .click(openLostAndFoundFolder_);
    }
    if (update.notification.display_lost_and_found_notice) {
      $('#lost-and-found-notice').removeClass('hidden');
    }
    const messages = $('#messages');
    const template = $('.message-template');
    for (const error_message of update.notification.error_messages) {
      const element = template.clone()
          .removeClass('message-template')
          .removeClass('hidden');
      element.text(error_message);
      element.appendTo(messages);
    }
  }
}

/**
 * Exits the dialog.
 * @private
 */
function exit_() {
  window.close();
}

/**
 * Opens the Lost&Found folder in the system file manager.
 * @private
 */
function openLostAndFoundFolder_() {
  sendCefRequest_('open_lost_and_found');
}
