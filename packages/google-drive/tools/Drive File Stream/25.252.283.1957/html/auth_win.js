(() => {
  window.mm = new function() {

    function sendCefRequest(message) {
      window.cefQuery({
        request: message,
        persistent: false,
        onSuccess: (response) => {},
        onFailure: (errorCode, errorMessage) => console.log(errorMessage),
      });
    }

    this.systemBrowserAuth = (email) => {
      sendCefRequest("system_browser_auth=" + email);
    };

    this.addAccount = (result) => {
      sendCefRequest("add_account=" + result);
    };
  };
})();
