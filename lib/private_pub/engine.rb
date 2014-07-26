require "private_pub/view_helpers"

module PrivatePub
  class Engine < Rails::Engine
    initializer "private_pub.config" do
      require 'private_pub/load_config'
    end

    initializer "private_pub.view_helpers" do
      ActionView::Base.send :include, ViewHelpers
    end
  end
end
