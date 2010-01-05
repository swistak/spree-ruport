class RuportExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/ruport"

  # Please use ruport/config/routes.rb instead for extension routes.

  def self.require_gems(config)
    #require 'ruport'
    #require 'ruport/util'
    #require 'ruport/acts_as_reportable'
    config.gem "ruport", :version => '1.6.1'
    config.gem "ruport-util", :lib => 'ruport/util'
    config.gem "acts_as_reportable", :lib => 'ruport/acts_as_reportable'
    config.gem 'prawn'
  end

  def activate
    base = File.dirname(__FILE__)
    unless ActiveSupport::Dependencies.load_paths.include? File.join(base, 'app', 'reports')
      ActiveSupport::Dependencies.load_paths << File.join(base, 'app', 'reports')
    end

    require 'prawn'
    require 'prawn/table'
    require 'prawn/format'

    # This hacks will be required to preserve compatibility with 0.9 series
    # They should not be needed for 1.0 if proper patches get accepted into core.
    # TODO: add issue numbers to monitor.
    require 'spree_0.9_hacks'

    if (RAILS_ENV=="production")
      require 'model_extensions_for_ruport'
    else
      FileUtils.cp Dir.glob(File.join(base, "public/stylesheets/*.css")), File.join(RAILS_ROOT, "public/stylesheets/")
      FileUtils.cp Dir.glob(File.join(base, "public/javascripts/*.js")), File.join(RAILS_ROOT, "public/javascripts")
      load 'model_extensions_for_ruport.rb'
    end

    Report::AVAILABLE_FORMATS.each do |formater|
      Formatter.const_get(formater.camelize)
    end
  end
end
