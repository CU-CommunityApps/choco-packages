/**
 * Updates the view.
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto.
 */
function updateView(update) {
  if (update.common) {
    $('#drive-logo').attr('alt', update.common.google_drive_fs_logo_alt_text);
  }

  if (update.feedback.resources) {
    const resources = update.feedback.resources;
    $('#title').text(resources.title);
    $('#description').text(resources.description);
    $('#close-button').text(resources.close_button);
    $('#cancel-button').text(resources.cancel_button);
    $('#submit-button').text(resources.submit_button);
    $('#submit-in-progress-message')
        .text(resources.feedback_submitting_message);
    $('#feedback-text').attr('placeholder', resources.placeholder_text);
    $('#additional-info-title').text(resources.additional_info_title);
    $('#legal-notice').html(resources.legal_notice);
    $('#attach-logs-label').html(resources.attach_logs_checkbox_label);
    // Only display the option to attach logs when the feature flag in enabled.
    $('#attach-logs-option')
        .toggleClass('hidden', !update.feedback.show_attach_logs_option);
    $('#attach-logs-checkbox')
        .change(function() { toggleAttachUserLogs_(this.checked); });
    $('#logs-folder')
        .attr('href', 'javascript: void(0)')
        .click(openLogsFolder_);
    $('#additional-info')
        .add($('#privacy-policy'))
        .add($('#terms-of-service'))
        .attr('href', 'javascript: void(0)');
    $('#additional-info-back-button-icon')
        .attr('alt', resources.back_button_alt_text);
    $('#additional-info').click(() => showAdditionalInfo_(true));
    $('#privacy-policy').click(openPrivacyPolicy_);
    $('#terms-of-service').click(openTermsOfService_);
  }

  if (update.feedback.additional_info) {
    function className_(suffix) {
      return '.additional-info-list-item-' + suffix;
    }
    const additional_info = update.feedback.additional_info.common_data;
    const additional_info_list = $('#additional-info-list');
    const template = $(className_('template'));
    const version = template.clone()
        .removeClass(className_('template'))
        .removeClass('hidden');
    version.find(className_('key')).text('product_version');
    version.find(className_('value')).text(additional_info.product_version);
    version.appendTo(additional_info_list);
    for (const item of additional_info.product_specific_data) {
      const element = template.clone()
          .removeClass(className_('template'))
          .removeClass('hidden');
      element.find(className_('key')).text(item.key);
      element.find(className_('value')).text(item.value);
      element.appendTo(additional_info_list);
    }
  }

  if (update.feedback.submission_response &&
      update.feedback.submission_successful !== undefined) {
    onSubmissionResponseReceived_(update.feedback);
  }
}

/**
 * Updates the UI when a feedback submission response is received, based on
 * whether the submission was successful or not.
 * @param {Object} feedback |cello::fs::UpdateViewRequest::Feedback| proto.
 * @private
 */
function onSubmissionResponseReceived_(feedback) {
  $('#submit-in-progress-message').addClass('hidden');
  $('#submit-complete-message').removeClass('hidden');
  $('#submit-complete-message').text(feedback.submission_response);

  if (feedback.submission_successful) {
    // Only close dialog button is now available.
    $('#close-button').removeClass('hidden');
    $('#cancel-button').addClass('hidden');
    $('#submit-button').addClass('hidden');
  } else {
    // Enable UI so user may try feedback submission again.
    disableUI_(false);
  }
}

/**
 * @return {string} The trimmed content of the textarea element.
 * @private
 */
function getFeedbackText_() {
  return $('#feedback-text').val().trim();
}

/**
 * Updates the color of the OK button and enables/disables it depending on the
 * length of text in the text area.
 * @private
 */
function onInputChange_() {
  $('#submit-button').prop('disabled', !getFeedbackText_().length);
}

/**
 * Disables or enables all user-interactive parts of the UI.
 * @param {bool} disable Whether to disable or enable the UI.
 * @private
 */
function disableUI_(disable) {
  $('#feedback-text')
      .add($('#submit-button'))
      .add($('#attach-logs-checkbox'))
      .attr('disabled', disable);
}

/**
 * "Attach logs" checkbox status.
 * @param {bool} attach Whether to attach user's logs.
 * @private
 */
function toggleAttachUserLogs_(attach) {
  sendCefRequest_(attach ? "attach_user_logs" : "detach_user_logs");
}

/**
 * Opens the Logs folder in the system file manager.
 * @private
 */
function openLogsFolder_() {
  sendCefRequest_('open_logs_folder');
}

/**
 * Submits the feedback entered.
 * @private
 */
function submit_() {
  disableUI_(true);
  $('#submit-in-progress-message').removeClass('hidden');
  $('#submit-complete-message').addClass('hidden');
  sendCefRequest_('feedback=' + getFeedbackText_());
}

/**
 * Exits the dialog.
 * @private
 */
function exit_() {
  window.close();
}

/**
 * Shows/hides the additional info dialog.
 * @param {boolean} show Whether to show or hide the dialog.
 * @private
 */
function showAdditionalInfo_(show) {
  $('#additional-info-layer').toggleClass('hidden', !show);
  $('#main-layer').toggleClass('hidden', show);
}

/**
 * Opens the "Privacy Policy" URL in the user's browser.
 * @private
 */
function openPrivacyPolicy_() {
  sendCefRequest_('open_privacy_policy');
}

/**
 * Opens the "Terms of Service" URL in the user's browser.
 * @private
 */
function openTermsOfService_() {
  sendCefRequest_('open_terms_of_service');
}
