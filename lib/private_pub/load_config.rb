PrivatePub.config[:secret_token] = ENV['PRIVATE_PUB_SECRET_TOKEN']
PrivatePub.config[:signature_expiration] = ENV['PRIVATE_PUB_EXPIRES'].to_i
PrivatePub.config[:server] = ENV['PRIVATE_PUB_SERVER']