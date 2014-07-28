describe("PrivatePub", function() {
  var pub, doc;
  beforeEach(function() {
    Faye = {}; // To simulate global Faye object
    doc = {};
    pub = buildPrivatePub(doc);
  });

  it("adds a subscription callback", function() {
    pub.subscribe("hello", "callback");
    expect(pub.subscriptionCallbacks["hello"]).toEqual("callback");
  });

  it("adds a faye subscription with response handler when signing", function() {
    var faye = {subscribe: jasmine.createSpy()};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = {server: 'server', channel: 'somechannel', action: 'subscribe'};
    pub.sign(options);
    expect(faye.subscribe).toHaveBeenCalledWith('somechannel', pub.handleResponse);
    expect(pub.subscriptions.server).toEqual("server");
    expect(pub.subscriptions.somechannel).toEqual(options);
  });

  it("adds a faye subscription with response handler when signing", function() {
    var faye = {subscribe: jasmine.createSpy()};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = {server: 'server', channel: 'somechannel', action: 'subscribe'};
    pub.sign(options);
    expect(faye.subscribe).toHaveBeenCalledWith("somechannel", pub.handleResponse);
    expect(pub.subscriptions.server).toEqual("server");
    expect(pub.subscriptions.somechannel).toEqual(options);
  });

  it("takes a callback for subscription object when signing", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel", action: 'subscribe' };
    options.subscription = jasmine.createSpy();
    pub.sign(options);
    expect(options.subscription).toHaveBeenCalledWith("subscription");
  });

  it("returns the subscription object for a subscribed channel", function(){
    var faye = {subscribe: function(){ return "subscription"; }};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel", action: 'subscribe' };
    pub.sign(options);
    expect(pub.subscription("somechannel")).toEqual("subscription")
  });

  it("unsubscribes a channel by name", function(){
    var sub = { cancel: jasmine.createSpy() };
    var faye = {subscribe: function(){ return sub; }};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    var options = { server: "server", channel: "somechannel", action: 'subscribe' };
    pub.sign(options);
    expect(pub.subscription("somechannel")).toEqual(sub);
    pub.unsubscribe("somechannel");
    expect(sub.cancel).toHaveBeenCalled();
    expect(pub.subscription("somechannel")).toBeFalsy();
  });

  it("unsubscribes all channels", function(){
    var created = 0;
    var sub = function() {
      created ++;
      var sub = { cancel: function(){ created --; } };
      return sub;
    };
    var faye = { subscribe: function(){ return sub(); }};
    spyOn(pub, 'faye').and.callFake(function(callback) {
      callback(faye);
    });
    pub.sign({server: 'server', channel: 'firstchannel', action: 'subscribe'});
    pub.sign({server: 'server', channel: 'secondchannel', action: 'subscribe'});
    expect(created).toEqual(2);
    expect(pub.subscription("firstchannel")).toBeTruthy();
    expect(pub.subscription("secondchannel")).toBeTruthy();
    pub.unsubscribeAll()
    expect(created).toEqual(0);
    expect(pub.subscription("firstchannel")).toBeFalsy();
    expect(pub.subscription("secondchannel")).toBeFalsy();
  });

  it("triggers faye callback function immediately when fayeClient is available", function(done) {
    pub.fayeClient = 'faye';
    pub.faye(function(faye) {
      expect(faye).toEqual('faye');
      done();
    });
  });

  describe('.faye', function() {
    it('returns fayeClient if present', function(done) {
      pub.fayeClient = 'faye';
      pub.faye(function(faye) {
        expect(faye).toEqual('faye');
        done();
      });
    });

    it('calls callback if insertFayeScript() resolves', function(done) {
      pub.subscriptions.server = 'server';

      pub.insertFayeScript = function() {
        return new Promise(function(resolve, reject) {
          resolve();
        });
      };
      pub.createFayeClient = function() {
        pub.fayeClient = 'faye';
      };

      pub.faye(function(faye) {
        expect(faye).toEqual('faye');
        done();
      });

    });

    it('does not call callback unless insertFayeScript() resolves', function() {
      pub.subscriptions.server = 'server';

      pub.insertFayeScript = function() {
        return new Promise(function(resolve, reject) {
          reject();
        });
      };
      pub.createFayeClient = function() {
        pub.fayeClient = 'faye';
      };

      pub.faye(function(faye) {
        expect(true).toEqual(false);
      });

    });

  });

  describe('.insertFayeScript', function() {
    it('adds a script tag to document', function() {
      script = {};
      doc.createElement = function() { return script; };
      doc.documentElement = {appendChild: jasmine.createSpy()};

      pub.insertFayeScript('path/to/faye');

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
      }

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
      pub.generateSignature = function() {
        return Promise.resolve(sig);
      };

      pub.getSubscribeSignature('hello').then(function(signature) {
        expect(signature).toEqual(sig);
        done();
      }, function() {
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

  describe('.handleResponse', function() {
    it("triggers callback matching message channel in response", function() {
      var called = false;
      pub.subscribe("test", function(data, channel) {
        expect(data).toEqual("abcd");
        expect(channel).toEqual("test");
        called = true;
      });
      pub.handleResponse({channel: "test", data: "abcd", action: 'subscribe'});
      expect(called).toBeTruthy();
    });
  });

  describe('.publish', function() {

    it('proxies to fayeClient', function(done) {
      var faye = { publish: function(channel, data) {
        expect(channel).toEqual('/foo');
        expect(data).toEqual({text: 'Hi there'});

        return new Promise(function(resolve, reject) {
          resolve('foo');
        });
      } };

      spyOn(pub, 'faye').and.callFake(function(callback) {
        callback(faye);
      });

      pub.publish('/foo', {text: 'Hi there'}).then(function(value) {
        expect(value).toEqual('foo');
        done();
      }, function () {
        throw new Error('Promise should not be rejected');
      });
    });

  });
});
