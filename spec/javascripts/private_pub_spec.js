describe("PrivatePub", function() {
  var pub, doc, faye;
  beforeEach(function() {
    doc = {};
    pub = buildPub('server');
    faye = {
      publish: function() {
        return Promise.resolve();
      },
      subscribe: function() {
        return {
          cancel: function() { },
          whenDone: Promise.resolve()
        };
      }
    };
  });

  var buildPub = function(server) {
    return PrivatePub(server, doc);
  };

  describe('.sign', function() {
    it('adds subscription', function() {
      var options = { channel: 'somechannel', action: 'subscribe'};
      pub.sign(options);

      expect(pub.signatures.subscribe['somechannel']).toBeDefined();
    });

    it('adds publication', function() {
      var options = { channel: 'somechannel', action: 'publish'};
      pub.sign(options);

      expect(pub.signatures.publish['somechannel']).toBeDefined();
    });

    it('returns signature', function() {
      var options = { channel: 'somechannel', action: 'publish', expires_at: 123, mac: 'mac'};
      var signature = pub.sign(options);

      expect(signature.channel).toEqual('somechannel');
      expect(signature.action).toEqual('publish');
      expect(signature.expires_at).toEqual(123);
      expect(signature.mac).toEqual('mac');

    });

    it('errors on unknown action', function() {
      var options = { channel: 'somechannel', action: 'wrong'};

      expect(function() {
        pub.sign(options);
      }).toThrow(new Error('Action must be publish or subscribe'));
    });
  });

  describe('.faye', function() {

    it('returns createFaye() promise', function(done) {
      spyOn(pub, 'createFaye').and.returnValue(Promise.resolve('faye'));

      pub.faye().then(function(faye) {
        expect(faye).toBe('faye');
        done();
      }, function () {
        expect(true).toEqual(false);
        done();
      });
    });

    it('memoizes createFaye', function(done) {
      spyOn(pub, 'createFaye').and.returnValue(Promise.resolve('faye'));

      Promise.all([pub.faye(), pub.faye()]).then(function(fayes) {
        expect(fayes).toEqual(['faye', 'faye']);
        expect(pub.createFaye.calls.count()).toEqual(1);
        done();
      }, function () {
        expect(true).toEqual(false);
        done();
      });
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

  describe('.getSubscribeSignature', function() {

    it('gets signature when present and not expired', function(done) {
      var options =  {mac: 'abcd', expires_at: Date.now() + 2000, action: 'subscribe', channel: 'hello'};
      var sig = pub.sign(options);
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
        expect(signature.channel).toEqual('/channel');
        expect(pub.signatures.subscribe['/channel']).toBeDefined();
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

  describe('.publish', function() {

    it('proxies to faye client', function(done) {
      spyOn(faye, 'publish').and.returnValue(Promise.resolve('foo'));

      spyOn(pub, 'faye').and.returnValue(Promise.resolve(faye));

      pub.publish('/foo', {text: 'Hi there'}).then(function(value) {
        expect(faye.publish).toHaveBeenCalledWith('/foo', {text: 'Hi there'});
        expect(value).toEqual('foo');
        done();
      }, function () {
        expect(true).toEqual(false);
        done();
      });
    });

  });

  describe('.subscribe', function() {

    it('proxies to faye client', function(done) {
      var subscription = {
        cancel: function() { },
        whenDone: Promise.resolve()
      };
      spyOn(faye, 'subscribe').and.returnValue(subscription);

      spyOn(pub, 'faye').and.returnValue(Promise.resolve(faye));

      pub.subscribe('/foo', function() {}).then(function(sub) {
        expect(faye.subscribe).toHaveBeenCalled();
        expect(sub).toBe(subscription);
        done();
      }, function () {
        expect(true).toEqual(false);
        done();
      });
    });

  });

});
