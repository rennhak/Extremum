# File: Gemfile


# Sources to draw gems from
source "http://rubygems.org"
# source 'http://gems.rubyforge.org'
# source 'http://gemcutter.org'


# Depend on a certain ruby version
# ruby '2.0.0'


# Default gems used during other phases such as production or development, etc.
group :default do # {{{

  # System
  gem 'rake'
  gem 'andand'              # Adds existential operator to ruby

  # Data Exchange RPCs and Messaging
  gem 'msgpack'
  gem 'xmpp4r'
  gem 'xmpp4r-simple', :git => 'git://github.com/blaine/xmpp4r-simple.git'
  gem 'amqp'

  # Data Exchange Formats
  gem 'oj'
  gem 'ox'
  gem 'nokogiri'
  gem 'cobravsmongoose'      # turn xml into json via standard

  gem 'narray'
  gem 'gsl'

end # }}}

# Development gems used only during development phase
group :development do # {{{
  gem 'rerun'
  gem 'awesome_print'
end # }}}

# Test gems used only during development and testing
group :test do # {{{}
  gem 'cucumber'
  gem 'rspec'
  gem 'capybara'
end # }}}

# Documentation gems only used to generate documentations
group :docs do # {{{
  gem 'yumlcmd'
  gem 'coderay' # syntax highlighting and code formatting in html
  gem 'redcarpet'
  gem 'htmlentities'
end # }}}


# vim:ts=2:tw=100:wm=100
