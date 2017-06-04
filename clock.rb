# frozen_string_literal: true
require 'clockwork'
ENV['DATABASE_URL'] ||= 'sqlite://development.db'
require_relative 'models'

module Clockwork
  interval = 10.minutes
  every(interval, 'fping') do
    Target.where(enable: true).each do |target|
      result = target.create_result
      alive = result.results.count('1')
      unreachable = result.results.count('0')
      STDERR.puts "fping #{target.range_with_min_max}, alive: #{alive}, unreachable: #{unreachable}"
    end
  end
end
