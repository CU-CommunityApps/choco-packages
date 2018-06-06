// The user preferences proto as specified during the construction of this
// dialog. This proto is amended when the user saves and sent back through a CEF
// request. See |save_()|.
let g_user_preferences = null;

/**
 * Updates the view.
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto.
 */
function updateView(update) {
  if (update.preferences_dialog.resources) {
    const resources = update.preferences_dialog.resources;
    $('#settings-title-primary-text')
        .text(resources.settings_title_primary_text);
    $('#settings-title-secondary-text')
        .text(resources.settings_title_secondary_text);
    $('#settings-body-title').text(resources.settings_title_primary_text);
    $('#ok-button').text(resources.ok_button);
    $('#error-message-ok-button').text(resources.ok_button);
    $('#cancel-button').text(resources.cancel_button);
    $('.change-button').text(resources.change_button);
    $('.reset-button').text(resources.reset_button);
    $('#restart-later-button').text(resources.restart_later_button);
    $('#restart-now-button').text(resources.restart_now_button);
    $('#sign-out-button').text(resources.sign_out_button);
    if (resources.hide_switch_account) {
      $('#switch-account-button').remove();
    } else {
      $('#switch-account-button').text(resources.switch_account_button);
    }
    $('#network-settings-link').text(resources.network_settings_button);
    $('.learn-more-link').text(resources.learn_more_link);
    $('#network-settings-ok-button').text(resources.ok_button);
    if (resources.show_drive_letter_picker) {
      $('#drive-letter-picker-title').text(resources.drive_letter_picker_title);
    } else {
      $('.drive-letter-picker-element').remove();
    }
    if (resources.show_mount_point_picker) {
      $('#mount-point-picker-title').text(resources.mount_point_picker_title);
    } else {
      $('.mount-point-picker-element').remove();
    }
    $('#content-cache-picker-title')
        .text(resources.content_cache_picker_title);
    $('#proxy-settings-title').text(resources.proxy_settings_title);
    $('#bandwidth-settings-title').text(resources.bandwidth_settings_title);
    $('#download-rate-title').text(resources.download_rate_title);
    $('#upload-rate-title').text(resources.upload_rate_title);
    $('#network-settings-bandwidth-download-limit-label')
        .text(resources.rate_limit_to_title);
    $('#network-settings-bandwidth-upload-limit-label')
        .text(resources.rate_limit_to_title);
    $('#network-settings-bandwidth-download-no-limit-label')
        .text(resources.rate_dont_limit_title);
    $('#network-settings-bandwidth-upload-no-limit-label')
        .text(resources.rate_dont_limit_title);
    $('#network-settings-proxy-direct-connection-label')
        .text(resources.proxy_direct_connection_title);
    $('#network-settings-proxy-auto-detect-label')
        .text(resources.proxy_auto_detect_title);
    $('#reboot-requested-label').text(resources.restart_needed_notice);
    // Account info.
    const DEFAULT_PROFILE_PHOTO = 'ic_account_circle_googblue_24dp.svg';
    $('#user-photo')
        .attr('alt', resources.profile_photo_alt_text)
        .attr('src', resources.user.photo_url)
        .on('error', function() { this.src = DEFAULT_PROFILE_PHOTO; });
    $('#user-name').text(resources.user.name);
    $('#user-email').text(resources.user.email);
    if (resources.show_drive_letter_picker &&
        resources.available_drive_letters) {
      const template = $('.drive-letter-picker-element-template');
      const drive_letter_list = $('#drive-letter-list');
      const mounted_drive_letter = update.preferences_dialog.user_preferences
          ?  update.preferences_dialog.user_preferences.mount_point_path
          : null;
      const all_drive_letters = jQuery.extend(
          /*deep=*/true, /*target=*/[], resources.available_drive_letters);
      all_drive_letters.push(mounted_drive_letter);
      all_drive_letters.sort();
      for (const letter of all_drive_letters) {
        const letter_element = template.clone()
            .removeClass('drive-letter-picker-element-template')
            .removeClass('hidden');
        letter_element.text(letter);
        letter_element.appendTo(drive_letter_list);
      }
    }
  }
  if (update.preferences_dialog.user_preferences) {
    const preferences = update.preferences_dialog.user_preferences;
    g_user_preferences = preferences;
    if (preferences.content_cache_path) {
      $('#content-cache-path').text(preferences.content_cache_path);
      $('#content-cache-path-tooltip').text(preferences.content_cache_path);
    }
    if (preferences.mount_point_path) {
      $('#drive-letter-button-value').text(preferences.mount_point_path);
      $('#mount-point-path').text(preferences.mount_point_path);
      $('#mount-point-path-tooltip').text(preferences.mount_point_path);
    }
    if (!!preferences.direct_connection) {
      $('#network-settings-proxy-direct-connection').click();
    }
    if (preferences.bandwidth_rx_kbps) {
      $('#network-settings-bandwidth-download-limit').click();
      $('#network-settings-bandwidth-download-limit-value')
          .val(preferences.bandwidth_rx_kbps);
    }
    if (preferences.bandwidth_tx_kbps) {
      $('#network-settings-bandwidth-upload-limit').click();
      $('#network-settings-bandwidth-upload-limit-value')
          .val(preferences.bandwidth_tx_kbps);
    }
  }
  if (update.preferences_dialog.updates) {
    const updates = update.preferences_dialog.updates;
    $('#reboot-requested-layer').toggleClass('hidden', !updates.restart_needed);
    if (updates.display_error) {
      $('#error-message-label').text(message);
      $('#error-message-layer').removeClass('hidden');
    }
    if (updates.content_cache_path) {
      $('#content-cache-path').text(updates.content_cache_path);
      $('#content-cache-path-tooltip').text(updates.content_cache_path);
    }
    if (updates.mount_point_path) {
      $('#mount-point-path').text(updates.mount_point_path);
      $('#mount-point-path-tooltip').text(updates.mount_point_path);
    }
  }
}

/**
 * Updates the UI to reflect the user's choice of drive letter.
 * @param {Element} menuItem The LI element of the selected letter.
 * @private
 */
function selectDriveLetter_(menuItem) {
  $('#drive-letter-button-value').text($(menuItem).text());
}

/**
 * Shows/hides network settings dialog.
 * @param {boolean} show Whether to show or hide the network settings.
 * @private
 */
function showNetworkSettings_(show) {
  $('#network-settings-layer').toggleClass('hidden', !show);
}

/**
 * Sends a "Switch Account" request to DriveFS.
 * @private
 */
function switchAccount_() {
  sendCefRequest_("switch_account");
}

/**
 * Sends a "Sign Out" request to DriveFS.
 * @private
 */
function signOut_() {
  sendCefRequest_("sign_out");
}

/**
 * Sends a request to DriveFS to open the native directory picker to select the
 * content cache location.
 * @private
 */
function openContentCachePicker_() {
  sendCefRequest_('open_content_cache_picker');
}

/**
 * Sends a request to DriveFS to open the native directory picker to select the
 * mount point location.
 * @private
 */
function openMountPointPicker_() {
  sendCefRequest_('open_mount_point_picker');
}

/**
 * Sends a request to DriveFS to restart the application.
 * @private
 */
function requestRestart_() {
  sendCefRequest_('request_restart');
}

/**
 * Selects the radio button corresponding to no download bandwidth limit option.
 * @private
 */
function maybeSelectDownloadRateNoLimitOption_() {
  if (!$('#network-settings-bandwidth-download-limit-value').val()) {
    $('#network-settings-bandwidth-download-no-limit').click();
  }
}

/**
 * Selects the radio button corresponding to limiting the download bandwidth.
 * @private
 */
function selectDownloadRateLimitToOption_() {
  $('#network-settings-bandwidth-download-limit').click();
}

/**
 * Selects the radio button corresponding to no upload bandwidth limit option.
 * @private
 */
function maybeSelectUploadRateNoLimitOption_() {
  if (!$('#network-settings-bandwidth-upload-limit-value').val()) {
    $('#network-settings-bandwidth-upload-no-limit').click();
  }
}

/**
 * Selects the radio button corresponding to limiting the upload bandwidth.
 * @private
 */
function selectUploadRateLimitToOption_() {
  $('#network-settings-bandwidth-upload-limit').click();
}

/**
 * Saves the user preferences.
 * @private
 */
function save_() {
  const download_limit =
      $('#network-settings-bandwidth-download-limit-option')
        .hasClass('is-checked');
  const download_limit_value =
      $('#network-settings-bandwidth-download-limit-value').val();
  const upload_limit =
      $('#network-settings-bandwidth-upload-limit-option')
        .hasClass('is-checked');
  const upload_limit_value =
      $('#network-settings-bandwidth-upload-limit-value').val();
  const request = jQuery.extend(/*deep=*/true, /*target=*/{},
                                g_user_preferences);
  request.content_cache_path = $('#content-cache-path').text();
  if ($('#mount-point-path').length) {
    request.mount_point_path = $('#mount-point-path').text();
  } else {
    request.mount_point_path = $('#drive-letter-button-value').text();
  }
  request.direct_connection =
      $('#network-settings-proxy-direct-connection-option')
          .hasClass('is-checked');
  if (download_limit && download_limit_value) {
    request.bandwidth_rx_kbps = +download_limit_value;
  } else {
    delete request.bandwidth_rx_kbps;
  }
  if (upload_limit && upload_limit_value) {
    request.bandwidth_tx_kbps = +upload_limit_value;
  } else {
    delete request.bandwidth_tx_kbps;
  }
  sendCefRequest_("save_settings=" + JSON.stringify(request));
}

/**
 * Exits the dialog.
 * @private
 */
function exit_() {
  window.close();
}
