(() => {
  window.shareapi = new function() {

    let margin = -1;

    function initMargin() {
      if (margin == -1) {
        let count = document.getElementsByClassName("modal-dialog").length;
        margin = count > 0 ? 20 : 0;
      }
    }

    function sendCefRequest(message) {
      window.cefQuery({
        request: message,
        persistent: false,
        onSuccess: (response) => {},
        onFailure: (errorCode, errorMessage) => console.log(errorMessage),
      });
    }

    function DeferredTask(task) {
      let timeoutId = -1;

      this.schedule = () => {
        if (timeoutId == -1) {
          timeoutId = window.setTimeout(() => {
            task();
            timeoutId = -1;
          }, 0);
        }
      };

      this.cancel = () => {
        if (timeoutId != -1) {
          window.clearTimeout(timeoutId);
          timeoutId = -1;
        }
      };
    }

    let relocateTask = new DeferredTask(() => {
      let elements = document.getElementsByClassName("modal-dialog");
      for (let i = 0; i < elements.length; i++) {
        elements[i].style.top = margin + "px";
        elements[i].style.left = margin + "px";
      }
    });

    let closeTask = new DeferredTask(window.close);

    this.rewriteUrl = (url) => {};

    this.setTitle = (title) => {};

    this.resize = (width, height) => {
      initMargin();
      width += 2 * margin;
      height += 2 * margin;
      sendCefRequest("resize=" + width + "," + height);

      // We use the following hack to relocate the content in the browser window
      // since it doesn't happen automatically. SyncClient and DriveForOffice
      // use a similar hack.
      // Team Drive Share Dialog works well without this hack.
      if (margin > 0) {
        relocateTask.schedule();
      }
    };

    this.setVisible = (visible) => {
      // Team Drive Share Dialog sometimes calls |setVisible(false)| before
      // |setVisible(true)|.
      if (visible) {
        closeTask.cancel();
      } else {
        closeTask.schedule();
      }
    };

    this.prepareForVisible = () => {};

    this.setClientModel = (clientModel) => {};

    this.dispatchEvent = (eventType) => {};

    this.init = (errorMsg) => {};

    this.handleError = (code, opt_htmlErrorMsg) => {};

    this.handleCommandComplete =
        (shareSystemCommandType, shareSystemCommandStatus) => {};
  };
})();
