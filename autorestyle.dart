import 'dart:crypto';
import 'dart:html';
import 'dart:isolate';

//-----------------------------------------------------------------------------
// Stylesheets are reloaded by periodically polling all <link> URLs and
// checking whether the old content differs from the new one.
// -----------------------------------------------------------------------------

int STYLESHEET_RELOAD_INTERVAL = 1000;

main() {
  for (var link in queryAll('link[rel=stylesheet]')) {
    new StylesheetReloader(STYLESHEET_RELOAD_INTERVAL, link).start();
  }
}

class Poller {
  num interval;
  Function pollback, callback;

  Poller(this.interval, this.pollback, this.callback);

  bool _running, _polling;
  Timer _timer;

  bool get running => _running;
  void start() { running = true; }
  void stop() { running = false; }
  set running(bool value) {
    if (_running != value) {
      _running = value;
      _running_changed();
    }
  }

  void _running_changed() {
    if (running) {
      _polling || _poll();
    } else {
      _cancel_timer();
    }
  }

  void _poll() {
    _polling = true;
    pollback((result) {
      _polling = false;
      _handle_result(result);
    });
  }

  void _handle_result(result) {
    if (running) {
      callback(result);
      _start_timer();
    }
  }

  void _start_timer() {
    _cancel_timer();
    _timer = new Timer(interval, (timer) {
      _timer = null;
      _poll();
    });
  }

  void _cancel_timer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}

class StylesheetReloader {
  LinkElement link;
  String _digest;
  Poller _poller;

  StylesheetReloader(interval, this.link) {
    _poller = new Poller(interval, _send_request, _handle_response);
  }

  void start() => _poller.start();
  void stop() => _poller.stop();

  void _send_request(Function callback) {
    new HttpRequest.get(link.href, (request) {
      callback(request.responseText);
    });
  }

  static String get_digest(text) {
    var input = text.charCodes;
    var output = new SHA256().update(input).digest();

    return CryptoUtils.bytesToHex(output);
  }

  void _handle_response(String response) {
    var digest = get_digest(response);

    if (digest != _digest) {
      _digest = digest;
      _reload_stylesheet();
    }
  }

  void _reload_stylesheet() {
    link.href = link.href;
  }
}
