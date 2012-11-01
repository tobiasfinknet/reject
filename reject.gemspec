# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "rack/reject/version"
require "rack/reject/rejector"
Gem::Specification.new do |s|
  s.name = 'reject'
  s.version = Rack::Reject::VERSION
  s.authors = ["Tobias Fink"]
  s.email = ["code@tobias-fink.net"]
  s.homepage = "https://github.com/tobiasfinknet/reject"
  s.summary = "Rack Module to reject unwanted requests."
  s.description = "Rack Module to reject unwanted requests."
  s.licenses = ["MIT", "GPLv3"]

  s.files = `git ls-files`.split("\n")
end