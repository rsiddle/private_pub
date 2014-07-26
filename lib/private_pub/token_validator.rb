module PrivatePub
  class TokenValidator
    def initialize(token)
      raise 'No secret_token config set, ensure private_pub.yml is loaded properly.' unless PrivatePub.config[:secret_token]
      @token = token
    end

    def valid?
      valid_token?
    end

    def error
      'Incorrect token.' unless valid_token?
    end

  private

    def valid_token?
      @token == PrivatePub.config[:secret_token]
    end

  end
end