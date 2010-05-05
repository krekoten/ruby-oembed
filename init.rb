$: << File.join(File.dirname(__FILE__), 'lib')

require 'oembed'
OEmbed::Providers.register_all