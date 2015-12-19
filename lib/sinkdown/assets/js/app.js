(function () {
  var uri = 'ws://' + window.document.location.host + "/";
  var ws = new WebSocket(uri);
  ws.onmessage = function (message) {
    var data = JSON.parse(message.data);
    if (data.document.path === sinkdown_file) {
      window.location.reload();
    }
  }
})();
