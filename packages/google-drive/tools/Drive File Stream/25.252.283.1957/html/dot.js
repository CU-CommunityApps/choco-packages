// The UpdateViewRequest::DriveDot proto as JSON that we receved in previous
// update.
let currentState_ = null;

// Timeout ID for delayed collapse.
let collapseTimeout_ = 0;

// Records the mouse screen position when mousedown event last occurred.
let mousePressedX_ = 0;
let mousePressedY_ = 0;

// Indicates if the mouse is currently pressed on the document.
let mousePressed_ = false;

// Indicates if the mouse has been dragged beyond a threshold since last mouse
// down event.
let mouseDragged_ = false;

const COLLAPSED_SIZE = 32;
const MIN_HEIGHT = 32;
const MIN_WIDTH = 250;

// Enum for presence::UserState enum.
// Keep in sync with the enum.
const USER_STATE_ = {
  USER_STATE_UNSPECIFIED: 0,
  IDLE: 1,
  VIEWING: 2,
  EDITING: 3,
  EXITED: 4,
};

// Maps state key strings to their UpdateViewRequest::DriveDot::StateKey enum.
// Keep in sync with the enum.
const STATE_KEY_ = {
  ERROR: 1,
  ERROR_COLLAPSED: 2,
  LOADING: 3,
  OFFLINE: 19,
  OFFLINE_COLLAPSED: 20,
  PRIVATE: 21,
  PRIVATE_COLLAPSED: 22,
  SAFE: 4,
  SAFE_COLLAPSED: 5,
  SAFE_VIEWER: 6,
  WAIT: 7,
  WAIT_COLLAPSED: 8,
  WAIT_SEMI_COLLAPSED: 9,
  WAIT_SEMI_COLLAPSED_WILL_NOTIFY: 10,
  WAIT_COLLABORATORS: 11,
  STALE: 12,
  STALE_DOWNLOADING: 13,
  STALE_COLLAPSED: 14,
  CONFLICT: 15,
  CONFLICT_YOUR: 16,
  CONFLICT_THEIR: 17,
  CONFLICT_DISMISS: 18,
  CONFLICT_COLLAPSED: 23,
};

// Maps UpdateViewRequest::DriveDot::StateKey enums to their page info.
// Keep in sync with the enum.
const STATES_ = {
  // TODO(mdzoba): Add validation for states that can be transitioned-to from
  // another state in JS, like CONFLICT and CONFLICT_DISMISS.
  [STATE_KEY_.ERROR]: {
    id: 'page-error',
    uiStrings: ['error_title'],
  },

  [STATE_KEY_.ERROR_COLLAPSED]: {
    id: 'page-error_collapsed',
    uiStrings: [
      'error_icon_alt_text',
    ]
  },

  [STATE_KEY_.LOADING]: {
    id: 'page-loading',
    uiStrings: [
      'loading_icon_alt_text',
    ]
  },

  [STATE_KEY_.OFFLINE]: {
      id: 'page-offline',
      uiStrings: [
        'offline_title'
      ],
    },

  [STATE_KEY_.OFFLINE_COLLAPSED]: {
    id: 'page-offline_collapsed',
    uiStrings: [
      'offline_icon_alt_text'
    ],
  },

  [STATE_KEY_.PRIVATE]: {
    id: 'page-private',
    uiStrings: [
      'private_title'
    ],
  },

  [STATE_KEY_.PRIVATE_COLLAPSED]: {
    id: 'page-private_collapsed',
    uiStrings: [
      'private_icon_alt_text'
    ],
  },

  [STATE_KEY_.SAFE]: {
    id: 'page-safe',
    uiStrings: [
      'safe_title',
    ]
  },

  [STATE_KEY_.SAFE_COLLAPSED]: {
    id: 'page-safe_collapsed',
    uiStrings: [
      'safe_icon_alt_text',
    ]
  },

  [STATE_KEY_.SAFE_VIEWER]: {
    id: 'page-safe_viewer',
    heads: true,
    uiStrings: [
      'safe_viewer_title',
      'safe_viewer_message',
    ]
  },

  [STATE_KEY_.WAIT]: {
    id: 'page-wait',
    heads: true,
    uiStrings: [
      'wait_title',
      'wait_message',
      'wait_got_it_button',
    ],
  },

  [STATE_KEY_.WAIT_COLLAPSED]: {
    id: 'page-wait_collapsed',
    uiStrings: [
      'wait_title',
    ],
  },

  [STATE_KEY_.WAIT_SEMI_COLLAPSED]: {
    id: 'page-wait_semi_collapsed',
    heads: true,
    uiStrings: ['wait_title', 'wait_semi_collapsed_will_notify_message'],
  },

  [STATE_KEY_.WAIT_SEMI_COLLAPSED_WILL_NOTIFY]: {
    id: 'page-wait_semi_collapsed_will_notify',
    heads: true,
    uiStrings: ['wait_title', 'wait_semi_collapsed_will_notify_message'],
  },

  [STATE_KEY_.WAIT_COLLABORATORS]: {
    id: 'page-wait_collaborators',
    collaborators: true,
    uiStrings: [
      'wait_collaborators_title',
      'wait_collaborators_header_editing',
      'wait_collaborators_header_viewing',
      'wait_collaborators_email_icon_tooltip',
      'wait_collaborators_chat_icon_tooltip',
    ],
  },

  [STATE_KEY_.STALE]: {
    id: 'page-stale',
    creator: true,
    uiStrings: [
      'stale_title',
      'stale_message',
      'stale_get_latest_button',
    ],
  },

  [STATE_KEY_.STALE_DOWNLOADING]: {
    id: 'page-stale_downloading',
    creator: true,
    uiStrings: [
      'stale_title',
      'stale_message',
      'stale_downloading',
    ],
  },

  [STATE_KEY_.STALE_COLLAPSED]: {
    id: 'page-stale_collapsed',
    uiStrings: [
      'stale_collapsed_title',
    ]
  },

  [STATE_KEY_.CONFLICT]: {
    id: 'page-conflict',
    creator: true,
    uiStrings: [
      'conflict_title',
      'conflict_message',
      'conflict_copy_button',
      'conflict_preview_button',
    ],
  },

  [STATE_KEY_.CONFLICT_YOUR]: {
    id: 'page-conflict_your',
    uiStrings: [
      'conflict_your_title',
      'conflict_your_message',
      'conflict_your_back_button',
    ],
  },

  [STATE_KEY_.CONFLICT_THEIR]: {
    id: 'page-conflict_their',
    uiStrings: [
      'conflict_their_title',
      'conflict_their_message',
      'conflict_their_save_button',
    ],
  },

  [STATE_KEY_.CONFLICT_DISMISS]: {
    id: 'page-conflict_dismiss',
    uiStrings: [
      'conflict_dismiss_title',
      'conflict_dismiss_message',
      'conflict_dismiss_ignore_button',
      'conflict_dismiss_preview_button',
    ],
  },

  [STATE_KEY_.CONFLICT_COLLAPSED]: {
      id: 'page-conflict_collapsed',
      uiStrings: [
        'conflict_collapsed_title',
      ]
    },
};

/**
 * Called when the DOMContentLoaded JavaScript event is fired. This is called
 * when the DOM is fully loaded, before all assets, e.g., images, have been
 * loaded.
 */
function onReady() {
  log('DOM onReady fired.');

  setUpDocumentClickHandler_();
  setUpButtonClickHandlers_();

  $(document).mouseleave(function() {
    delayedCollapse_(2);
  });
  $(document).mouseover(cancelDelayedCollapse_);
}
$(document).ready(onReady);

/**
 * Updates the view.
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto
 */
function updateView(update) {
  const newState = update.dot;

  if (!newState) {
    log('updateView called with invalid parameter');
    showError(makeDefaultErrorState_());
    return;
  }

  log('Got new state: ' + JSON.stringify(newState, null, 2));
  if (!isValidState(newState)) {
    showError(newState);
    return;
  }

  if (currentState_ &&
      isEquivalentState(currentState_.state_key, newState.state_key)) {
    // Set the new state key to the current state key so we don't go from
    // a collapsed to an expanded state without the user clicking.
    // Do still use the new state because it may have upated info.
    newState.state_key = currentState_.state_key;
  } else {
    // Set a longer delayed collapse so the user can see what changed.
    delayedCollapse_(5);
  }

  setNewState(newState);
}

/**
 * Sets the current state to the new state. Renders the state and goes to
 * the appropriate page. Does not change window size.
 * @param {Object} newState Json |cello::fs::UpdateViewRequest::DriveDot|
 *     proto.
 */
function setNewState(newState) {
  if (!isValidState(newState)) {
    log('Tried to set invalid state: ' + JSON.stringify(newState, null, 2));
    showError(newState);
    return;
  }

  currentState_ = newState;

  // Re-enable any disabled buttons.
  $('.has-js-handler').prop('disabled', false);

  // Render, resize, then show the new state.
  renderState_(newState.state_key);
  updateWindowSize_(STATES_[newState.state_key].id);
  goToPage_(STATES_[newState.state_key].id);
}

/**
 * Picks an error state to show.
 * If newState exists and has a valid error state, show it. Otherwise, create
 * an ERROR state (will not be internationalized).
 * @param {Object} newState Json |cello::fs::UpdateViewRequest::DriveDot|
 *     proto.
 */
function showError(newState) {
  // Change the state key of newState to be ERROR since each state should
  // always have i18n-ized error strings.
  newState.state_key = STATE_KEY_.ERROR;
  if (isValidState(newState)) {
    setNewState(newState);
    return;
  }

  // We should never get here. We should always be passed in an i18n error.
  setNewState(makeDefaultErrorState_());
}

/**
 * Makes a default, not internationalized, ERROR state.
 * @return {object} A default, not internationalized, ERROR state Json
 *     |cello::fs::UpdateViewRequest::DriveDot| proto.
 * @private
 */
function makeDefaultErrorState_() {
  return {
    'state_key': STATE_KEY_.ERROR,
    'resources': {
      'error_title': 'JS ERROR',
    },
  };
}

/**
 * @param {Object} state Json |cello::fs::UpdateViewRequest::DriveDot| proto.
 * @return {boolean} Whether or not the state is valid.
 */
function isValidState(state) {
  let pageInfo = STATES_[state.state_key];
  if (!pageInfo) return false;

  if (state.presence_infos && state.presence_infos.length) {
    for (let presenceInfo of state.presence_infos) {
      fixCollaborator_(presenceInfo);
    }
  }
  if (state.creator_info) {
    fixCollaborator_(state.creator_info);
  }

  // No other checking if uiStrings is undefined.
  if (!pageInfo.uiStrings) return true;

  for (let uiString of pageInfo.uiStrings) {
    if (state.resources[uiString] === undefined) {
      log('Missing resource string ' + uiString);
      return false;
    }
  }
  return true;
}

/**
 * Fixes any presence infos, modified in place.
 * @param {Object} presenceInfo Json |google.apps.presence.v1.PresenceInfo|.
 * @private
 */
function fixCollaborator_(presenceInfo) {
  const userInfo = presenceInfo.user.basic_user_info;
  if (!userInfo.photo_url) {
    userInfo.photo_url = 'ic_account_circle_googblue_24dp.svg';
  } else if (!presenceInfo.user.user_id &&
             userInfo.photo_url.startsWith('//')) {
    // Anonymous profile photos from gstatic look like
    // '//ssl.gstatic.com/docs/common/profile/animal.png'.
    userInfo.photo_url = 'http:' + userInfo.photo_url;
  }
}

/**
 * @param {string} targetPageId The id of the page to calculate the size for.
 * @private
 */
function updateWindowSize_(targetPageId) {
  let $targetPage = $('[data-page=' + targetPageId + ']');

  if (!$targetPage) {
    log('Cannot update size for page: ', targetPageId);
    return;
  }

  switch (currentState_.state_key) {
    case STATE_KEY_.ERROR_COLLAPSED:
    case STATE_KEY_.LOADING:
    case STATE_KEY_.OFFLINE_COLLAPSED:
    case STATE_KEY_.PRIVATE_COLLAPSED:
    case STATE_KEY_.SAFE_COLLAPSED:
      // States that only show an icon.
      sendCefRequest_('resize=' + COLLAPSED_SIZE + ',' + COLLAPSED_SIZE);
      break;
    case STATE_KEY_.ERROR:
    case STATE_KEY_.OFFLINE:
    case STATE_KEY_.PRIVATE:
    case STATE_KEY_.SAFE:
    case STATE_KEY_.WAIT_COLLAPSED:
    case STATE_KEY_.STALE_COLLAPSED:
    case STATE_KEY_.CONFLICT_COLLAPSED:
      // States that look like a horizontal bar.
      $targetPage.height(MIN_HEIGHT);
      let width = $targetPage.width().toFixed();
      sendCefRequest_('resize=' + width + ',' + MIN_HEIGHT);
      break;
    case STATE_KEY_.WAIT_COLLABORATORS:
      // This state allows the user to scroll.
      sendCefRequest_('resize=' + MIN_WIDTH + ',' + 288);
      break;
    default:
      // States that have a fixed width but a flexible height.
      $targetPage.width(MIN_WIDTH);
      let height = $targetPage.height().toFixed();
      sendCefRequest_('resize=' + MIN_WIDTH + ',' + height);
  }
}

/**
 * @param {string} stateKey The state key string to render.
 * @param {string} parentId The id of the page the back button should go to.
 * @private
 */
function renderState_(stateKey, parentId) {
  let pageInfo = STATES_[stateKey];
  let $page = $('.' + pageInfo.id);

  // Render UI strings.
  if (pageInfo.uiStrings) {
    populateStrings_($page, pageInfo.uiStrings);
  }

  // Render collaborator heads and page.
  if (pageInfo.heads) {
    renderHeads_($page, currentState_.presence_infos);

    // Render this state early in case it gets clicked on.
    // TODO(jlure): Is this necessary?
    renderState_(STATE_KEY_.WAIT_COLLABORATORS, pageInfo.id);
  }

  // Render collaborators list.
  if (pageInfo.collaborators) {
    renderCollaborators_($page, currentState_.presence_infos);
  }

  // Render newer version creator.
  if (pageInfo.creator) {
    renderCreator_($page, currentState_.creator_info);
  }

  // Render back button.
  if (parentId !== undefined) {
    $page.find('.back-button').data('link-target', parentId);
  }
}

/**
 * @param {Object} $page The $page to render in.
 * @param {Array} keys A list of keys to render in $page.
 * @private
 */
function populateStrings_($page, keys) {
  for (let key of keys) {
    let stringValue = currentState_.resources[key];
    if (stringValue) {
      let element = $page.find('.' + key);
      if (element.is('img')) {
        element.attr('alt', stringValue);
      }
      element.text(stringValue)
          .attr('aria-label', stringValue)
          .attr('tabindex', 0);
    }
  }
}

/**
 * @param {Object} $page The page to render in.
 * @param {Object} presenceInfo A
 *     |google.apps.presence.v1.PresenceInfo| object.
 * @private
 */
function renderCreator_($page, presenceInfo) {
  let $creator = $page.find('.creator');
  $creator.empty();
  if (!presenceInfo) {
    $creator.hide();
  } else {
    templateHead_(presenceInfo.user.basic_user_info).
        appendTo($creator);
    $creator.show();
  }
}

/**
 * @param {Object} $page The page to render in.
 * @param {Array} presenceInfos An array of
 *                |google.apps.presence.v1.PresenceInfo| objects.
 * @private
 */
function renderHeads_($page, presenceInfos) {
  let $heads = $page.find('.heads');
  $heads.empty();
  let numDisplayed = 0;
  const MAX_DISPLAYED = 3;
  for (let presenceInfo of presenceInfos) {
    const userInfo = presenceInfo.user.basic_user_info;
    let $head = templateHead_(userInfo);
    $head.appendTo($heads);

    if (++numDisplayed >= MAX_DISPLAYED) {
      break;
    }
  }
  // Add the number icon.
  if (presenceInfos.length > MAX_DISPLAYED) {
    $('<div class="more"/>')
        .text('+' + (presenceInfos.length - MAX_DISPLAYED))
        .appendTo($heads);
  }
}

/**
 * @param {Object} $page The page to render in.
 * @param {Array} presenceInfos An array of
 *                |google.apps.presence.v1.PresenceInfo| objects.
 * @private
 */
function renderCollaborators_($page, presenceInfos) {
  let $editing = $page.find('#people-list-editing').empty();
  let $viewing = $page.find('#people-list-viewing').empty();

  for (let presenceInfo of presenceInfos) {
    const userInfo = presenceInfo.user.basic_user_info;
    let $user = templateCollaborator_(userInfo);

    let isEditor = false;
    for (let state of presenceInfo.session_states) {
      if (state.user_state == USER_STATE_.EDITING) {
        isEditor = true;
        break;
      }
    }
    if (isEditor) {
      $user.appendTo($editing);
    } else {
      $user.appendTo($viewing);
    }
  }

  if ($viewing.contents().length) {
    $page.find('.wait_collaborators_viewing').show();
    $page.find('.wait_collaborators_editing').addClass('with-border');
  } else {
    $page.find('.wait_collaborators_viewing').hide();
    $page.find('.wait_collaborators_editing').removeClass('with-border');
  }
}

/**
 * @param {Object} userInfo A |google.apps.presence.v1.BasicUserInfo| object.
 * @return {$Element} The created jQuery element.
 * @private
 */
function templateHead_(userInfo) {
  const $head = $('<img class="head"/>')
                    .attr('draggable', false)
                    .attr('src', userInfo.photo_url)
                    .attr('alt', userInfo.display_name);
  if (!userInfo.email) {
    // Set a background color for anonymous users.
    // TODO(jlure): Have a unique color for anonymous user.
    $head.css({'background-color' : 'orange'});
  }
  return $head;
}

/**
 * @param {Object} userInfo A |google.apps.presence.v1.BasicUserInfo| object.
 * @return {$Element} The created jQuery element.
 * @private
 */
function templateCollaborator_(userInfo) {
  return $('<li class="person" />')
      .append(templateHead_(userInfo))
      .append($('<div class="text" />')
                  .append($('<h5 />').text(userInfo.display_name))
                  .append($('<h6 />').text(userInfo.email)));
}

/** @private */
function setUpDocumentClickHandler_() {
  $(document).on('mousedown', onDocumentMouseDownHandler_);
  $(document).on('mousemove', onDocumentMouseMoveHandler_);
  $(document).on('mouseup', onDocumentMouseUpHandler_);
}

/** @private */
function setUpButtonClickHandlers_() {
  $('[data-link-target]').on('mouseup', onLinkMouseUpHandler_);
  $('.has-js-handler').on('mouseup', onButtonMouseUpHandler_);
}

/** @private */
function expand_() {
  let newState = $.extend({}, currentState_);
  // Set the state key to the expanded version of the current state.
  newState.state_key = makeExpandedState_(currentState_.state_key);
  if (newState.state_key == currentState_.state_key) {
    return;
  }
  if (isValidState(newState)) {
    setNewState(newState);
  } else {
    log('Invalid state, cannot expand to ' +
        JSON.stringify(newState, null, 2));
  }
}

/** @private */
function collapse_() {
  let newState = $.extend({}, currentState_);
  // Set the state key to the collapsed version of the current state.
  newState.state_key = makeCollapsedState_(currentState_.state_key);
  if (newState.state_key == currentState_.state_key) {
    return;
  }
  if (isValidState(newState)) {
    setNewState(newState);
  } else {
    log('Invalid state, cannot collapse to ' +
        JSON.stringify(newState, null, 2));
  }
}

/**
 * @private
 * @param {number} seconds Amount of time before collapsing.
 */
function delayedCollapse_(seconds) {
  cancelDelayedCollapse_();
  collapseTimeout_ = setTimeout(collapse_, seconds * 1000);
}

/** @private */
function cancelDelayedCollapse_() {
  if (collapseTimeout_) {
    clearTimeout(collapseTimeout_);
    collapseTimeout_ = 0;
  }
}

/**
 * Records the screen position when mousedown event last occurred.
 * @param {Event} event The JS event.
 * @private
 */
function onDocumentMouseDownHandler_(event) {
  mousePressed_ = true;
  mousePressedX_ = event.screenX;
  mousePressedY_ = event.screenY;
}


/**
 * Computes if mouse has been dragged beyond a threshold and sets mouseDragged_
 * variable.
 * @param {Event} event The JS event.
 * @private
 */
function onDocumentMouseMoveHandler_(event) {
  const DRAG_THRESHOLD = 5;
  if (mousePressed_ && !mouseDragged_ &&
      (Math.abs(event.screenX - mousePressedX_) > DRAG_THRESHOLD ||
       Math.abs(event.screenY - mousePressedY_) > DRAG_THRESHOLD)) {
    mouseDragged_ = true;
  }
}

/**
 * Document mouse up handler. Expands the dot unless mouse has been dragged.
 * @param {Event} event The JS event.
 * @private
 */
function onDocumentMouseUpHandler_(event) {
  if (!mouseDragged_) {
    expand_();
    cancelDelayedCollapse_();
  }
  mousePressed_ = false;
  mouseDragged_ = false;
}

/**
 * @param {Event} event The JS event.
 * @private
 */
function onLinkMouseUpHandler_(event) {
  if (mouseDragged_) {
    return;
  }
  event.stopPropagation();
  mousePressed_ = false;
  let newState = $.extend({}, currentState_);
  let linkTarget = $(this).data('link-target');
  // |linkTarget| is in the form 'page-insert_page_id_here'.
  newState.state_key = STATE_KEY_[linkTarget.substring(5).toUpperCase()];
  setNewState(newState);
}

/**
 * @param {string} targetPageId The id of the page to go to.
 * @private
 */
function goToPage_(targetPageId) {
  let $currentPage = $('.page:not(.hidden)');
  let $targetPage = $('[data-page=' + targetPageId + ']');

  if (!$targetPage) {
    log('No such page: ', $targetPage);
    return;
  }

  $currentPage.addClass('page-hidden');
  $targetPage.removeClass('page-hidden');
}

/**
 * @param {Event} event The JS event.
 * @private
 */
function onButtonMouseUpHandler_(event) {
  if (mouseDragged_) {
    return;
  }
  event.stopPropagation();
  mousePressed_ = false;

  $(this).prop('disabled', true);
  if ($(this).hasClass('stale_get_latest_button') ||
      $(this).hasClass('conflict_preview_button') ||
      $(this).hasClass('conflict_dismiss_preview_button')) {
    // TODO(jlure): Change conflict preview buttons to sending
    //    conflict_preview_button_clicked when diff is implemented.
    sendCefRequest_('stale_get_latest_button_clicked');
  } else if ($(this).hasClass('conflict_copy_button')) {
    sendCefRequest_('conflict_copy_button_clicked');
  } else if ($(this).hasClass('conflict_your_back_button')) {
    sendCefRequest_('your_back_button_clicked');
  } else if ($(this).hasClass('conflict_their_save_button')) {
    sendCefRequest_('their_save_button_clicked');
  } else if ($(this).hasClass('wait_collaborators_email_button')) {
    sendCefRequest_('email');
  } else if ($(this).hasClass('wait_collaborators_chat_button')) {
    sendCefRequest_('chat');
  } else {
    log('Unknown button clicked: ' + $(this));
  }
}

/**
 * @param {number} stateKey The state key enum.
 * @return {number} The collapsed state or ERROR if none.
 * @private
 */
function makeCollapsedState_(stateKey) {
  // TODO(jlure): Should we collapse the SAFE_VIEWER state?
  switch (stateKey) {
    case STATE_KEY_.ERROR:
    case STATE_KEY_.ERROR_COLLAPSED:
      return STATE_KEY_.ERROR_COLLAPSED;
    case STATE_KEY_.OFFLINE:
    case STATE_KEY_.OFFLINE_COLLAPSED:
      return STATE_KEY_.OFFLINE_COLLAPSED;
    case STATE_KEY_.PRIVATE:
    case STATE_KEY_.PRIVATE_COLLAPSED:
      return STATE_KEY_.PRIVATE_COLLAPSED;
    case STATE_KEY_.SAFE:
    case STATE_KEY_.SAFE_COLLAPSED:
      return STATE_KEY_.SAFE_COLLAPSED;
    case STATE_KEY_.WAIT:
    case STATE_KEY_.WAIT_COLLAPSED:
    case STATE_KEY_.WAIT_SEMI_COLLAPSED:
    case STATE_KEY_.WAIT_SEMI_COLLAPSED_WILL_NOTIFY:
      return STATE_KEY_.WAIT_COLLAPSED;
    case STATE_KEY_.STALE:
    case STATE_KEY_.STALE_COLLAPSED:
      return STATE_KEY_.STALE_COLLAPSED;
    case STATE_KEY_.LOADING:
    case STATE_KEY_.SAFE_VIEWER:
    case STATE_KEY_.WAIT_COLLABORATORS:
    case STATE_KEY_.STALE_DOWNLOADING:
    case STATE_KEY_.CONFLICT:
    case STATE_KEY_.CONFLICT_YOUR:
    case STATE_KEY_.CONFLICT_THEIR:
    case STATE_KEY_.CONFLICT_DISMISS:
    case STATE_KEY_.CONFLICT_COLLAPSED:
      return stateKey;
    default:
      return STATE_KEY_.ERROR_COLLAPSED;
  }
}

/**
 * @param {number} stateKey The state key enum.
 * @return {number} The expanded state or ERROR if none.
 * @private
 */
function makeExpandedState_(stateKey) {
  switch (stateKey) {
    case STATE_KEY_.ERROR:
    case STATE_KEY_.ERROR_COLLAPSED:
      return STATE_KEY_.ERROR;
    case STATE_KEY_.OFFLINE:
    case STATE_KEY_.OFFLINE_COLLAPSED:
      return STATE_KEY_.OFFLINE;
    case STATE_KEY_.PRIVATE:
    case STATE_KEY_.PRIVATE_COLLAPSED:
      return STATE_KEY_.PRIVATE;
    case STATE_KEY_.SAFE:
    case STATE_KEY_.SAFE_COLLAPSED:
      return STATE_KEY_.SAFE;
    case STATE_KEY_.WAIT_COLLAPSED:
    case STATE_KEY_.WAIT_SEMI_COLLAPSED:
    case STATE_KEY_.WAIT_SEMI_COLLAPSED_WILL_NOTIFY:
      return STATE_KEY_.WAIT;
    case STATE_KEY_.STALE:
    case STATE_KEY_.STALE_COLLAPSED:
      return STATE_KEY_.STALE;
    case STATE_KEY_.CONFLICT_COLLAPSED:
      return STATE_KEY_.CONFLICT;
    // TODO(jlure): Should WAIT_SEMI_COLLAPSED* states go here?
    case STATE_KEY_.LOADING:
    case STATE_KEY_.SAFE_VIEWER:
    case STATE_KEY_.WAIT:
    case STATE_KEY_.WAIT_COLLABORATORS:
    case STATE_KEY_.STALE_DOWNLOADING:
    case STATE_KEY_.CONFLICT:
    case STATE_KEY_.CONFLICT_YOUR:
    case STATE_KEY_.CONFLICT_THEIR:
    case STATE_KEY_.CONFLICT_DISMISS:
      return stateKey;
    default:
      return STATE_KEY_.ERROR;
  }
}
/**
 * @param {number} currState The current state enum.
 * @param {number} newState The new state enum.
 * @return {boolean} Whether or not we should switch from |currState| to
  *     |newState|.
 */
function isEquivalentState(currState, newState) {
  if (currState == newState) {
    return true;
  }

  // Each inner-set represents a set of equivalent states.
  let equivalentStates = [
    new Set([STATE_KEY_.ERROR, STATE_KEY_.ERROR_COLLAPSED]),
    new Set([STATE_KEY_.OFFLINE, STATE_KEY_.OFFLINE_COLLAPSED]),
    new Set([STATE_KEY_.PRIVATE, STATE_KEY_.PRIVATE_COLLAPSED]),
    new Set([STATE_KEY_.SAFE, STATE_KEY_.SAFE_COLLAPSED]),
    new Set([
      STATE_KEY_.WAIT, STATE_KEY_.WAIT_COLLAPSED,
      STATE_KEY_.WAIT_SEMI_COLLAPSED,
      STATE_KEY_.WAIT_SEMI_COLLAPSED_WILL_NOTIFY, STATE_KEY_.WAIT_COLLABORATORS
    ]),
    new Set([
      STATE_KEY_.STALE, STATE_KEY_.STALE_DOWNLOADING, STATE_KEY_.STALE_COLLAPSED
    ]),
    new Set([
      STATE_KEY_.CONFLICT, STATE_KEY_.CONFLICT_DISMISS,
      STATE_KEY_.CONFLICT_THEIR, STATE_KEY_.CONFLICT_YOUR,
      STATE_KEY_.CONFLICT_COLLAPSED,
      // TODO(mdzoba): Remove this when Diff Flow is implemented.
      STATE_KEY_.STALE_DOWNLOADING,
    ]),
  ];
  for (s of equivalentStates) {
    if (s.has(currState) && s.has(newState)) {
      return true;
    }
  }
  return false;
}
