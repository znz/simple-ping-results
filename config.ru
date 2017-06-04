# frozen_string_literal: true
require 'bundler'
Bundler.require
require_relative 'app'
run Sinatra::Application
