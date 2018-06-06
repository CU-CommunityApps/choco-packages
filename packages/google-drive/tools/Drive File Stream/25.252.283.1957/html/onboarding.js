const keyframes = [
  {index: 0, time: 0, action: 'start', text: null},
  {index: 1, time: 0, action: 'fade-out', text: null},
  {index: 2, time: 0, action: 'set-indicator', text: null, value: 1}, {
    index: 3,
    time: 1.98,
    action: 'fade-in',
    text: 'Stream Google Drive files right to your computer',
  },
  {index: 4, time: 8.50, action: 'pause', text: null},
  {index: 5, time: 8.53, action: 'set-indicator', text: null, value: 2},
  {index: 6, time: 8.53, action: 'fade-out', text: null}, {
    index: 7,
    time: 9.13,
    action: 'fade-in',
    text: 'Save disk space by only downloading the files you need',
  },
  {index: 8, time: 11.0, action: 'pause', text: null},
  {index: 9, time: 11.13, action: 'set-indicator', text: null, value: 3},
  {index: 10, time: 11.13, action: 'fade-out', text: null}, {
    index: 11,
    time: 11.66,
    action: 'fade-in',
    text: 'Mark items “Available offline” to edit without a connection',
  },
  {index: 12, time: 18.0, action: 'pause', text: null},
  {index: 13, time: 18.2, action: 'set-indicator', text: null, value: 4},
  {index: 14, time: 18.2, action: 'show-cta', text: null, value: 4},
  {index: 15, time: 18.2, action: 'fade-out', text: null}, {
    index: 16,
    time: 19.2,
    action: 'fade-in',
    text: 'Any changes will sync automatically when you’re back online',
  }
];

/**
 * Updates the view
 * @param {Object} update Json |cello::fs::UpdateViewRequest| proto
 */
function updateView(update) {
  if (!update.onboarding) {
    log('updateView called with invalid parameter');
    return;
  }

  log('Updating message');
  const messages = update.onboarding.frame_messages;
  let j = 0;
  for (let i = 0; i < keyframes.length && j < messages.length; i++) {
    const frame = keyframes[i];
    if (frame.text) {
      frame.text = messages[j++];
    }
  }
  if (j < messages.length) {
    log('Unused frame messages detected');
  }
  if (update.onboarding.open_button) {
    document.getElementById('open').innerText = update.onboarding.open_button;
  }
}

/**
 * Starts the onboarding process.
 *
 * @param {array} keyframes State list of the onboarding process.
 * @private
 */
function startOnboarding(keyframes) {

  let playing = false;
  let needsRestart = false;
  let time = 0;
  let keyframeIndex = 0;

  const playerElement = document.getElementById('player');
  const forwardButton = document.getElementById('forward');
  const backButton = document.getElementById('back');
  const textElement = document.getElementById('text');
  const openButton = document.getElementById('open');

  playerElement.addEventListener('playing', function() {
    if (!playing) {
      playing = true;

      if (needsRestart) {
        keyframeIndex = 0;
        needsRestart = false;
      }

      tick(0);
    }
  });

  playerElement.addEventListener('ended', function() {
    playing = false;
    needsRestart = true;
  });

  playerElement.addEventListener('pause', function() {
    playing = false;
  });

  forwardButton.addEventListener('click', stepForward);

  backButton.addEventListener('click', stepBackward);

  function fadeText() {
    textElement.classList.add('fade');
  }

  function showText() {
    textElement.classList.remove('fade');
  }

  function stepForward() {
    if (!playing) {
      playerElement.play();
    } else {
      const pauseKeyframes = keyframes.filter(function(keyframe) {
        return keyframe.action === 'pause' && keyframe.time > time;
      });
      if (pauseKeyframes.length) {
        const pauseKeyframe = pauseKeyframes[0];
        fadeText();
        playerElement.currentTime = pauseKeyframe.time;
        keyframeIndex = pauseKeyframe.index + 1;
      } else {
        playerElement.currentTime = 0;
        keyframeIndex = 0;
        fadeText();
      }
    }
  }

  function stepBackward() {
    const pauseKeyframes = keyframes.filter(function(keyframe) {
      return (keyframe.action === 'pause' || keyframe.action === 'start') && keyframe.time < time;
    });

    if (pauseKeyframes.length) {
      let pauseKeyframe = null;
      if (pauseKeyframes.length <= 2) {
        pauseKeyframe = pauseKeyframes[0];
      } else {
        pauseKeyframe = pauseKeyframes[pauseKeyframes.length - 2];
      }
      textElement.innerText = '';
      fadeText();
      playerElement.currentTime = pauseKeyframe.time;
      keyframeIndex = pauseKeyframe.index + 1;
    } else {
      playerElement.currentTime = 0;
      keyframeIndex = 0;
      fadeText();
    }
    playerElement.play();
  }

  function tick() {
    time = playerElement.currentTime.toFixed(2);
    const nextKeyframe = keyframes[keyframeIndex];
    if (nextKeyframe) {
      if (time >= nextKeyframe.time) {
        if (nextKeyframe.text) {
          textElement.innerText = nextKeyframe.text;
        }
        if (nextKeyframe.action === 'pause') {
          playerElement.pause();
        }
        if (nextKeyframe.action === 'fade-in') {
          showText();
        }
        if (nextKeyframe.action === 'fade-out' || nextKeyframe.action === 'start') {
          fadeText();
        }
        if (nextKeyframe.action === 'show-cta') {
          openButton.removeAttribute('disabled');
        }
        if (nextKeyframe.action === 'set-indicator') {
          if (nextKeyframe.value > 1) {
            backButton.removeAttribute('disabled');
          }
          let circles = document.querySelectorAll('.circle');
          for (let circle of circles) {
            circle.classList.remove('active');
          }
          document.getElementById('circle-' + nextKeyframe.value).classList.add('active');
        }
        keyframeIndex++;
      }
    }
    if (playing) {
      window.requestAnimationFrame(tick);
    }
  }

  playerElement.play();

}

/**
 * Start the on boarding animations.
 */
window.onload = function() {
  startOnboarding(keyframes);
};
