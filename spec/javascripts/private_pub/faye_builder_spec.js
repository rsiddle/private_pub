describe("PrivatePub.FayeBuilder", function() {
  var builder, doc, faye, signatures;
  beforeEach(function() {
    doc = {};

    var signature = { signature: 'sig', expires_at: 123};

    signatures = {
      subscribe: function() {
        return Promise.resolve(signature);
      },
      publish: function() {
        return Promise.resolve(signature);
      }
    };

    builder = PrivatePub.FayeBuilder('server', doc, signatures);

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

  describe('.build', function() {

    it('inserts faye script then returns faye client.', function(done) {
      spyOn(builder, 'insertFayeScript').and.returnValue(Promise.resolve());
      spyOn(builder, 'createClient').and.returnValue('faye');

      builder.build().then(function(faye) {
        expect(faye).toEqual('faye');
        done();
      }, function() {
        expect(true).toEqual(false);
        done();
      });
    });

    it('calls error handler if insertFayeScript fails', function(done) {
      spyOn(builder, 'insertFayeScript').and.returnValue(Promise.reject('error'));
      spyOn(builder, 'createClient');

      builder.build().then(function() {
        expect(true).toEqual(false);
        done();
      }, function(error) {
        expect(error).toEqual('error');
        expect(builder.createClient.calls.count()).toEqual(0);
        done();
      });
    });

  });

  describe('.fayeExtension', function() {

    it('lets meta channels except /meta/subscribe pass through', function(done) {
      var message = { channel: '/meta/channel' };
      builder.fayeExtension.outgoing(message, function(processed_message) {
        expect(processed_message).toEqual(message);
        done();
      });
    });

    it('adds matching signature and timestamp with publications', function(done) {
      var message = { channel: '/channel' };

      var signature = { signature: 'pub_sig', expires_at: 123}

      spyOn(signatures, 'publish').and.returnValue(Promise.resolve(signature));

      builder.fayeExtension.outgoing(message, function(message) {
        expect(message.ext.private_pub_signature).toEqual('pub_sig');
        expect(message.ext.private_pub_expires_at).toEqual(123);
        done();
      });
    });

    it('adds matching signature and timestamp with subscriptions', function(done) {
      var message = { channel: '/meta/subscribe', subscription: '/channel' };

      var signature = { signature: 'sub_sig', expires_at: 123}

      spyOn(signatures, 'subscribe').and.returnValue(Promise.resolve(signature));

      builder.fayeExtension.outgoing(message, function(message) {
        expect(message.ext.private_pub_signature).toEqual('sub_sig');
        expect(message.ext.private_pub_expires_at).toEqual(123);
        done();
      });
    });

  });

  describe('.insertFayeScript', function() {
    var script;

    beforeEach(function() {
      script = {};
      doc.createElement = function() { return script; };
      doc.documentElement = { appendChild: jasmine.createSpy() };
    });

    // TODO: Use a real DOM to test this.
    it('adds a script tag to document', function() {

      builder.insertFayeScript();

      expect(script.type).toEqual('text/javascript');
      expect(script.src).toEqual('server.js');
      expect(doc.documentElement.appendChild).toHaveBeenCalledWith(script);
    });

    it('returns a future that resolves when the script tags onload event fires', function(done) {

      builder.insertFayeScript().then(function() {
        done();
      });

      script.onload();
    });

  });

});