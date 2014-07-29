describe("PrivatePub", function() {
  var pub, doc;
  beforeEach(function() {
    Faye = {}; // To simulate global Faye object
    doc = {};
    pub = buildPub('server');
  });

  var buildPub = function(server) {
    return new PrivatePub(server, doc)
  };

  describe('.sign', function() {
    it('adds subscription', function() {
      var options = { channel: 'somechannel', action: 'subscribe'};
      var opts = pub.sign(options);

      expect(pub.subscriptions['somechannel']).toEqual(options);
      expect(opts).toEqual(options);
    });

    it('adds publication', function() {
      var options = { channel: 'somechannel', action: 'publish'};
      var opts = pub.sign(options);

      expect(pub.publications['somechannel']).toEqual(options);
      expect(opts).toEqual(options);

    });

    it('errors on unknown action', function() {
      var options = { channel: 'somechannel', action: 'wrong'};

      expect(function() {
        pub.sign(options);
      }).toThrow(new Error('Action must be publish or subscribe'));
    });
  });

  describe('.subscribe', function() {

    var faye, subscription;

    beforeEach(function() {
      subscription = { cancel: jasmine.createSpy().and.returnValue('cancel_value') };
      faye = { subscribe: jasmine.createSpy().and.returnValue(subscription) };
      spyOn(pub, 'faye').and.returnValue(Promise.resolve(faye));
    });

    it('resolves and calls faye.subscribe', function(done) {
      pub.subscribe('hello', 'callback').then(function() {
        expect(faye.subscribe).toHaveBeenCalled();
        done();
      }, function(error) {
        console.log(error);
        expect(true).toBe(false);
        done();
      });
    });

    it('resolves with cancel method', function(done) {
      pub.subscribe('hello', 'callback').then(function(cancel) {
        var cancel_value = cancel();
        expect(subscription.cancel).toHaveBeenCalled();
        expect(cancel_value).toBe('cancel_value');
        done();
      }, function(error) {
        console.log(error);
        expect(true).toBe(false);
        done();
      });
    });

    it('returns object with cancel method', function(done) {
      sub = pub.subscribe('hello', 'callback')
      sub.cancel().then(function(cancel_value) {
        expect(subscription.cancel).toHaveBeenCalled();
        expect(cancel_value).toBe('cancel_value');
        done();
      }, function(error) {
        console.log(error);
        expect(true).toBe(false);
        done();
      });
    });

  });

  describe('.setupFaye', function() {
    it('inserts faye script then returns faye client.', function(done) {
      spyOn(pub, 'insertFayeScript').and.callFake(function() {
        return Promise.resolve();
      });

      spyOn(pub, 'createFayeClient').and.callFake(function() {
        return 'faye';
      });

      pub.setupFaye().then(function(faye) {
        expect(faye).toEqual('faye');
        done();
      }, function() {
        expect(true).toEqual(false);
        done();
      });
    });

    it('calls error handler if insertFayeScript fails', function(done) {
      spyOn(pub, 'insertFayeScript').and.callFake(function() {
        return Promise.reject();
      });

      pub.setupFaye().then(function() {
        expect(true).toEqual(false);
        done();
      }, function() {
        done();
      });
    });
  });

  describe('.faye', function() {

    it('calls callback if insertFayeScript() resolves', function(done) {

      spyOn(pub, 'insertFayeScript').and.callFake(function() {
        return Promise.resolve();
      });

      spyOn(pub, 'createFayeClient').and.callFake(function() {
        return 'faye';
      });

      pub.faye().then(function(faye) {
        expect(faye).toEqual('faye');
        done();
      }, function() {
        expect(true).toEqual(false);
        done();
      });

    });

    it('only calls insertFayeScript once', function() {
      spyOn(pub, 'insertFayeScript').and.returnValue(Promise.resolve());
      spyOn(pub, 'createFayeClient').and.returnValue('faye');

      Promise.all([pub.faye(), pub.faye()]).then(function(fayes) {
        expect(fayes).toEqual(['faye', 'faye']);
        expect(pub.insertFayeScript.calls.count()).toEqual(1);
        done();
      });
    });

    it('calls error handler if insertFayeScript() rejects', function(done) {
      spyOn(pub, 'insertFayeScript').and.returnValue(Promise.reject('error'));
      spyOn(pub, 'createFayeClient').and.returnValue('faye');

      pub.faye().then(function(faye) {
        expect(true).toEqual(false);
        done();
      }, function(error) {
        done();
      });

    });

  });

  describe('.insertFayeScript', function() {
    it('adds a script tag to document', function() {
      pub = buildPub('path/to/faye');

      script = {};
      doc.createElement = function() { return script; };
      doc.documentElement = {appendChild: jasmine.createSpy()};

      pub.insertFayeScript();

      expect(script.type).toEqual('text/javascript');
      expect(script.src).toEqual('path/to/faye.js');
      expect(doc.documentElement.appendChild).toHaveBeenCalledWith(script);
    });

    it('returns a future that resolves when the script tags onload event fires', function(done) {
      script = {};
      doc.createElement = function() { return script; };
      doc.documentElement = {appendChild: function() {}};

      pub.insertFayeScript('path/to/faye').then(function() {
        done();
      });

      script.onload();
    });
  });
//
//  it("connects to faye server, adds extension, and executes callbacks", function() {
//    callback = jasmine.createSpy();
//    client = {addExtension: jasmine.createSpy()};
//    Faye.Client = function(server) {
//      expect(server).toEqual("server")
//      return client;
//    };
//    pub.subscriptions.server = "server";
//    pub.fayeCallbacks.push(callback);
//    pub.connectToFaye();
//    expect(pub.fayeClient).toEqual(client);
//    expect(client.addExtension).toHaveBeenCalledWith(pub.fayeExtension);
//    expect(callback).toHaveBeenCalledWith(client);
//  });

  describe('.fayeExtension', function () {

    it('lets meta channels except /meta/subscribe pass through', function(done) {
      var message = {channel: '/meta/channel'}
      pub.fayeExtension.outgoing(message, function(processed_message) {
        expect(processed_message).toEqual(message);
        done();
      });
    });

    it('adds matching signature and timestamp with publications', function(done) {
      var message = {channel: '/channel'};
      var time = Date.now() + 2000;
      pub.publications['/channel'] = {signature: 'abcd', expires_at: time};

      pub.generateSignature = function() {
        expect(true).toEqual(false);
        done();
      }

      pub.fayeExtension.outgoing(message, function(message) {
        expect(message.ext.private_pub_signature).toEqual('abcd');
        expect(message.ext.private_pub_expires_at).toEqual(time);
        done();
      });
    });

    it('adds matching signature and timestamp with subscriptions', function(done) {
      var message = {channel: '/meta/subscribe', subscription: '/channel'};
      var time = Date.now() + 2000;
      pub.subscriptions['/channel'] = {signature: 'abcd', expires_at: time};

      pub.generateSignature = function() {
        expect(true).toEqual(false);
        done();
      };

      pub.fayeExtension.outgoing(message, function(message) {
        expect(message.ext.private_pub_signature).toEqual('abcd');
        expect(message.ext.private_pub_expires_at).toEqual(time);
        done();
      });
    });

  });

  describe('.getSubscribeSignature', function() {
    it('gets signature when present and not expired', function(done) {
      var sig =  {signature: 'abcd', expires_at: Date.now() + 2000};
      pub.subscriptions['hello'] = sig;
      pub.getSubscribeSignature('hello').then(function(signature) {
        expect(signature).toEqual(sig);
        done();
      }, function() {
        expect(true).toEqual(false);
        done();
      })
    });

    it('propagates success from generateSignature when not present', function(done) {
      var sig = {action: 'subscribe', channel: '/channel'};

      spyOn(pub, 'generateSignature').and.returnValue(Promise.resolve(sig));

      pub.getSubscribeSignature('hello').then(function(signature) {
        expect(signature).toEqual(sig);
        expect(pub.subscriptions['/channel']).toEqual(sig);
        done();
      }, function(error) {
        console.log(error, error.stack);
        expect(true).toEqual(false);
        done();
      })
    });

    it('propagates error from generateSignature when not present', function(done) {
      var expected_error = new Error('Error');
      pub.generateSignature = function() {
        return Promise.reject(expected_error);
      };

      pub.getSubscribeSignature('hello').then(function(signature) {
        expect(true).toEqual(false);
        done();
      }, function(error) {
        expect(error).toEqual(expected_error);
        done();
      })
    })
  });

//  describe('.handleResponse', function() {
//    it('triggers callback matching message channel in response', function(done) {
//      pub.subscribe('test', function(data, channel) {
//        expect(data).toEqual('abcd');
//        expect(channel).toEqual('test');
//        done();
//      });
//      pub.handleResponse({channel: 'test', data: 'abcd'});
//    });
//  });

  describe('.publish', function() {

    it('proxies to fayeClient', function(done) {
      var faye = { publish: function(channel, data) {
        expect(channel).toEqual('/foo');
        expect(data).toEqual({text: 'Hi there'});

        return Promise.resolve('foo');
      } };

      spyOn(pub, 'faye').and.callFake(function() {
        return Promise.resolve(faye);
      });

      pub.publish('/foo', {text: 'Hi there'}).then(function(value) {
        expect(value).toEqual('foo');
        done();
      }, function () {
        expect(true).toEqual(false);
        done();
      });
    });

  });
});
