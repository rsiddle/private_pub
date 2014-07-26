module PrivatePub
  class SignatureValidator
    def initialize(signature)
      @signature = signature
    end

    def valid?
      validations.all? { |(condition, _)| !condition }
    end

    def error
      validations.find(->() { [nil, nil] }) { |(condition, _)| condition }.last
    end

  private

    def validations
      [
        [!valid_signature?, 'Incorrect signature.'],
        [expired?, 'Signature has expired.']
      ]
    end

    def expired?
      @signature.expired?
    end

    def valid_signature?
      @signature.valid?
    end

  end
end