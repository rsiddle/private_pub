env_mode = ENV["RACK_ENV"] || "production"
vars = YAML.load_file(File.join("/www", env_mode, "www", "current", "config", "private_pub", "config.yml"))
PrivatePub.config[:secret_token] = vars[env_mode]["secret_token"]
PrivatePub.config[:signature_expiration] = vars[env_mode]["signature_expiration"].to_i
PrivatePub.config[:server] = vars[env_mode]["server"]
