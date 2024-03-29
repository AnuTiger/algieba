require File.expand_path('boot', __dir__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Algieba
  class Application < Rails::Application
    config.i18n.default_locale = :ja
    config.active_record.raise_in_transactional_callbacks = true
    config.autoload_paths += ["#{config.root}/lib/errors"]
  end
end
