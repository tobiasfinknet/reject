# encoding: utf-8

require 'rack'

module Rack
  module Reject
    autoload :Rejector, 'rack/reject/rejector'  
    autoload :VERSION, 'rack/reject/version'  
  end
end
