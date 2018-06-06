const DEFAULT_FILE_THUMBNAIL = 'ic_file_black_24dp.svg';
const DEFAULT_PROFILE_PHOTO = 'ic_account_circle_googblue_24dp.svg';
const MAX_ACTIVITY_LIST_SIZE = 5;

/**
 * See fs.proto's UpdateViewRequest::StatusWindow::State::Item::Event.
 * @enum {int}
 */
const ItemEvent = {
  COMPLETED: 1,
  DOWNLOAD: 2,
  UPLOAD: 3,
};

/** @enum {int} */
const CoreStatus = {
  NOT_STARTED: 1,
  STARTING: 2,
  STARTED: 3,
  STOPPING: 4,
};

var confirmInProgress_ = false;

var coreStatus_ = CoreStatus.NOT_STARTED;
var resources_ = {};
var user_ = {};

/** @private */
function hideAllPanes_() {
  $('#loading-pane').addClass('hidden');
  $('#loading-spinner').removeClass('is-active');
  $('#main-pane').addClass('hidden');
  $('#sign-in-pane').addClass('hidden');
}

/**
 * Shows the Sign In Pane. This should not be called directly, instead use
 * showActivePane_() which picks the correct view based on the DriveFS State.
 * @private
 */
function showSignInPane_() {
  hideAllPanes_();
  showSignedInOptions_(false);
  showUserInformation_(false);
  user_ = {};

  $('#sign-in-pane').removeClass('hidden');
}

/**
 * Shows the Main Pane. This should not be called directly, instead use
 * showActivePane_() which picks the correct view based on the DriveFS State.
 * @private
 */
function showMainPane_() {
  hideAllPanes_();
  $('#main-pane').removeClass('hidden');
}

/**
 * Shows the Loading Pane. This should not be called directly, instead use
 * showActivePane_() which picks the correct view based on the DriveFS State.
 * @private
 */
function showLoadingPane_() {
  hideAllPanes_();
  $('#loading-spinner').addClass('is-active');
  $('#loading-pane').removeClass('hidden');
}

/** @private */
function showActivePane_() {
  hideAllPanes_();
  if (coreStatus_ == CoreStatus.NOT_STARTED) {
    showSignInPane_();
  } else if (
      coreStatus_ == CoreStatus.STARTING ||
      coreStatus_ == CoreStatus.STOPPING) {
    showLoadingPane_();
  } else if (coreStatus_ == CoreStatus.STARTED) {
    if (user_.name) {
      showMainPane_();
    } else {
      showLoadingPane_();
    }
  }
}

/**
 * Updates the UI view.
 * @param {!Object} update An UpdateViewRequest from fs.proto.
 */
function updateView(update) {
  const status_win = update.status_win;

  if (update.common) {
    $('#sign-in-img').attr('alt', update.common.google_drive_fs_logo_alt_text);
    $('#menu-list')
        .toggleClass('mdl-menu--bottom-right', !update.common.is_rtl)
        .toggleClass('mdl-menu--bottom-left', !!update.common.is_rtl);
  }
  if (status_win.resources) {
    resources_ = status_win.resources;
    initResources_();
  }
  if (status_win.init_options) {
    processInitOptions_(status_win.init_options);
  }
  if (status_win.core_status && status_win.core_status != coreStatus_) {
    confirmInProgress_ = false;
    coreStatus_ = status_win.core_status;
    showActivePane_();
  }
  if (status_win.state) {
    const state = status_win.state;
    updateStatusBar_(state);
    updateActivityList_(state);
    if (state.syncing_paused !== undefined) {
      togglePauseSyncing_(state.syncing_paused);
    }
  }
  if (status_win.user) {
    user_ = status_win.user;
    updateAccount_();
    showActivePane_();
  }
  if (status_win.confirm_action_cancelled) {
    if (confirmInProgress_) {
      confirmInProgress_ = false;
      showActivePane_();
    }
  }
  if (status_win.hide_window) {
    const menuContainer = $('#menu-list').parent('.mdl-menu__container');
    if (menuContainer && menuContainer.hasClass('is-visible')) {
      $('#menu-button').click();
    }
    // Remove focus from the active element.
    document.activeElement.blur();
  }
}

/**
 * Initializes static text using the i18n string resources.
 * @private
 */
function initResources_() {
  $('#user-img').attr('alt', resources_.profile_photo_alt_text);
  $('#open-drive-folder-tooltip').text(resources_.open_drive_icon_tooltip);
  $('#menu-button-tooltip').text(resources_.more_menu_icon_tooltip);
  $('#open-google-drive-icon').attr('alt', resources_.open_drive_icon_alt_text);
  $('#more-menu-icon').attr('alt', resources_.more_menu_icon_alt_text);
  $('#about').text(resources_.about_menu_title);
  $('#help').text(resources_.help_menu_title);
  $('#submit-feedback').text(resources_.submit_feedback_menu_title);
  $('#pause-syncing').text(resources_.pause_syncing_menu_title);
  $('#resume-syncing').text(resources_.resume_syncing_menu_title);
  $('#switch-account').text(resources_.switch_accounts_menu_title);
  $('#preferences').text(resources_.preferences_menu_title);
  $('#sign-out').text(resources_.sign_out_menu_title);
  $('#quit').text(resources_.quit_menu_title);
  $('#full-product-name').text(resources_.full_product_name);
  $('#sign-in-button').text(resources_.sign_in_button);
  $('#up-to-date-icon').attr('alt', resources_.up_to_date_icon_alt_text);
  $('#quota-exceeded-icon').attr('alt', resources_.quota_exceeded_alt_text);

  $('.activity-list-item-icon').attr('alt', resources_.file_type_icon_alt_text);
  $('.activity-list-item-completed').attr('alt', resources_.completed_icon_alt_text);
}

/**
 * Processes the passed-in UI initialization options.
 * @param {!Object} init_options the initialization options. Corresponds to the
 *     InitOptions proto message.
 * @private
 */
function processInitOptions_(init_options) {
  if (init_options.hide_switch_account) {
    $('#switch-account').remove();
  }
  if (init_options.hide_submit_feedback) {
    $('#submit-feedback').remove();
  }
  if (init_options.hide_pause_syncing_option) {
    $('#pause-syncing').remove();
    $('#resume-syncing').remove();
  }
  if (init_options.hide_preferences_option) {
    $('#preferences').remove();
    $('#preferences-separator').remove();
  } else {
    $('#sign-out').remove();
  }
}

/**
 * Updates an HTML element to sync its state with a State::Item.
 * @param {!Object} item An UpdateViewRequest::StatusWindow::State::Item.
 * @param {!Object} element The jQuery object mapping to the element to update.
 * @private
 */
function updateActivityListItem_(item, element) {
  function className_(suffix) {
    return '.activity-list-item-' + suffix;
  }

  element.data('event_group_id', item.event_group_id);
  element.find(className_('description-primary')).text(item.primary_text);
  element.find(className_('description-secondary')).text(item.secondary_text);
  element.find(className_('icon'))
      .attr('src', item.thumbnail_src || DEFAULT_FILE_THUMBNAIL);
  element.find(className_('queued-download-title'))
      .text(resources_.download_queued_icon_alt_text);
  element.find(className_('queued-upload-title'))
      .text(resources_.upload_queued_icon_alt_text);

  // Note: .toggleClass('class', undefined) adds the class, hence using "!!".
  element.find(className_('progress-spinner'))
      .add(element.find(className_('circle')))
      .toggleClass('hidden ', !item.show_spinner)
      .toggleClass('is-active', !!item.show_spinner);
  element.find(className_('completed'))
      .toggleClass('hidden', item.event !== ItemEvent.COMPLETED);
  element.find(className_('queued-download'))
      .add(element.find(className_('queued-upload')))
      .addClass('hidden')
      .attr('aria-hidden', true)
      .removeClass('is-active');

  let svgSuffix = null;
  switch (item.event) {
    case ItemEvent.DOWNLOAD:
      svgSuffix = 'download';
      element.find(className_('progress-spinner'))
          .attr('aria-label', resources_.downloading_icon_alt_text);
      break;
    case ItemEvent.UPLOAD:
      svgSuffix = 'upload';
      element.find(className_('progress-spinner'))
          .attr('aria-label', resources_.uploading_icon_alt_text);
      break;
  }
  if (svgSuffix) {
    element.find(className_('circle'))
        .add(element.find(className_('queued-' + svgSuffix)))
        .removeClass('hidden')
        .attr('aria-hidden', !!item.show_spinner)
        .toggleClass('is-active', !!item.show_spinner);
  }
}

/**
 * Updates the activity list with the content of |state|.
 * @param {!Object} state An UpdateViewRequest::StatusWindow::State.
 * @private
 */
function updateActivityList_(state) {
  const template = $('.activity-list-item-template');
  const activity_list = $('#activity-list');
  // Ordered map of item ID to item.
  const items = new Map();
  if (state.backfill_in_progress) {
    const BACKFILL_FAKE_EVENT_ID = -1;
    items.set(BACKFILL_FAKE_EVENT_ID, {
      event_group_id: BACKFILL_FAKE_EVENT_ID,
      primary_text: resources_.backfill_text,
      show_spinner: true,
    });
  }
  for (const item of state.items) {
    items.set(item.event_group_id, item);
  }

  // Remove existing items that should no longer be displayed.
  activity_list.children().each(function() {
    if (!items.has($(this).data('event_group_id'))) {
      $(this).remove();
    }
  });
  // Update existing elements and insert new ones. Note that we reuse existing
  // elements when possible and rely on the CSS to maintain the correct item
  // order. Otherwise, re-ordering existing items by detaching and re-inserting
  // them at the correct place in the DOM resets the spinner animation.
  let order = 1;
  for (const [event_group_id, item] of items) {
    let element = activity_list.children().filter(function() {
      return $(this).data('event_group_id') === event_group_id;
    });
    if (order > MAX_ACTIVITY_LIST_SIZE) {
      // Activity list max size exceeded: remove leftover elements.
      element.remove();
      continue;
    }
    if (!element.length) {
      element = template.clone()
                    .removeClass('activity-list-item-template')
                    .removeClass('hidden');
      element.appendTo(activity_list);
    }
    updateActivityListItem_(item, element);
    element.css('order', (order++).toString());
  }
}

/**
 * @param {!Object} state An UpdateViewRequest::StatusWindow::State.
 * @private
 */
function updateStatusBar_(state) {
  $('#status-bar-message').text(state.status_message);
  $('#quota-exceeded-icon').toggleClass('hidden',
                                        !state.show_quota_exceeded_icon);
  $('#up-to-date-icon').toggleClass('hidden', !state.show_up_to_date_icon);
}

/**
 * Updates the UI and its options based on whether syncing has been paused or
 * not.
 * @param {bool} paused Whether syncing is paused or not.
 * @private
 */
function togglePauseSyncing_(paused) {
  $('#resume-syncing').attr('disabled', !paused || !user_.name);
  $('#resume-syncing').toggleClass('hidden', !paused);
  $('#pause-syncing').attr('disabled', paused || !user_.name);
  $('#pause-syncing').toggleClass('hidden', paused);
}

/** @private */
function updateAccount_() {
  showSignedInOptions_(true);
  showUserInformation_(true);

  if ($('#loading-pane').is(':visible')) {
    hideAllPanes_();
    showMainPane_();
  }
}

/**
 * Shows or hides the signed-in user's information in the header bar.
 * @param {bool} show Whether to show or hide the user information.
 * @private
 */
function showUserInformation_(show) {
  const username = show ? user_.name : '';
  const userEmail = show ? user_.email : '';
  const userPhoto = show ? (user_.photo_url || DEFAULT_PROFILE_PHOTO) : '';

  $('#user-name').text(username);
  $('#user-email').text(userEmail);
  $('#user-img')
      .attr('src', userPhoto)
      .on('error', function() { this.src = DEFAULT_PROFILE_PHOTO; })
      .toggleClass('hidden', !show);
}

/**
 * Shows or hides all UI options related to whether a user is signed-in.
 * @param {bool} show Whether to show or hide the options.
 * @private
 */
function showSignedInOptions_(show) {
  $('#sign-out').attr('disabled', !show);
  $('#switch-account').attr('disabled', !show);
  $('#submit-feedback').attr('disabled', !show);
  $('#pause-syncing').attr('disabled', !show);
  $('#resume-syncing').attr('disabled', !show);
  $('#open-drive-folder-button').attr('disabled', !show);
  $('#open-drive-folder-button').toggleClass('hidden', !show);
}

/**
 * Called when the DOMContentLoaded JavaScript event is fired. This is called
 * when the DOM is fully loaded, before all assets, e.g., images, have been
 * loaded.
 */
function onReady() {
  log('DOM onReady fired.');

  // Close More Options menu, if it is open while escape key is pressed.
  $(document).keyup((e) => {
    if (e.keyCode == 27) {  // KeyCode 27 == Escape Key.
      $('.mdl-menu__container').removeClass('is-visible');
    }
  });

  // mdl-menu is a bit buggy in that some actions prevent the menu from closing
  // when then menu items are clicked.  (For example, setting items to disabled
  // prevents the menu from closing.  Or setting to hidden will cause the item
  // to visibly hide before the menu closes due to the menu transition
  // animation). So manually close the menu upon clicking a menu item.
  $('.mdl-menu__item')
      .click(() => $('.mdl-menu__container').toggleClass('is-visible', false));
}
$(document).ready(onReady);

/**
 * Opens the user's Google Drive folder in the file explorer.
 * @private
 */
function openGoogleDriveFolder_() {
  if ($('#open-drive-folder-button').attr('disabled')) {
    return;
  }
  sendCefRequest_('open_google_drive_folder');
}

/**
 * Switches accounts.
 * @private
 */
function switchAccount_() {
  if ($('#switch-account').attr('disabled')) {
    return;
  }
  confirmInProgress_ = true;
  showLoadingPane_();
  sendCefRequest_('switch_account');
}

/**
 * Shows the about dialog.
 * @private
 */
function about_() {
  sendCefRequest_('show_about_dialog');
}

/**
 * Shows the preferences dialog.
 * @private
 */
function preferences_() {
  sendCefRequest_('show_preferences_dialog');
}

/**
 * Shows a dialog where feedback can be provided by the user.
 * @private
 */
function submitFeedback_() {
  if ($('#submit-feedback').attr('disabled')) {
    return;
  }
  sendCefRequest_('show_submit_feedback_dialog');
}

/** @private */
function help_() {
  sendCefRequest_('open_help_site');
}

/**
 * Pauses syncing such that all uploads and pinned downloads are stopped.
 * @private
 */
function pauseSyncing_() {
  if ($('#pause-syncing').attr('disabled')) {
    return;
  }
  sendCefRequest_('pause_syncing');
}

/**
 * Resumes syncing such that uploads and pinned downloads are resumed.
 * @private
 */
function resumeSyncing_() {
  if ($('#resume-syncing').attr('disabled')) {
    return;
  }
  sendCefRequest_('resume_syncing');
}

/**
 * Initiates sign out.
 * @private
 */
function signOut_() {
  if ($('#sign-out').attr('disabled')) {
    return;
  }
  confirmInProgress_ = true;
  showLoadingPane_();
  sendCefRequest_('sign_out');
}

/**
 * Quits the application.
 * @private
 */
function quit_() {
  confirmInProgress_ = true;
  showLoadingPane_();
  sendCefRequest_('quit');
}

/**
 * Initiates sign in.
 * @private
 */
function signIn_() {
  showLoadingPane_();
  sendCefRequest_('sign_in');
}
