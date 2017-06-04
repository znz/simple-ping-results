#!/usr/bin/env ruby
# frozen_string_literal: true
# import data of https://github.com/znz/simple-ping-summary
ENV['DATABASE_URL'] ||= "sqlite://development.db"
require_relative 'models'
def usage
  abort("usage: #$0 range min max path/to/dir")
end
range = ARGV.shift
min = ARGV.shift.to_i
max = ARGV.shift.to_i
path = ARGV.shift
unless path && File.directory?(path)
  usage
end
cond = { range: range, min: min, max: max }
target = Target.where(cond).first
unless target
  target = Target.create(cond)
end
Dir.glob("#{path}/**/*.out").sort.each do |file|
  mtime = File.mtime(file)
  if PingResult.where(cond.merge(created_at: mtime)).first
    puts "#{file}: skip"
    next
  end
  o = File.read(file)
  fping = target.addresses.each_with_object(''.dup) do |address, result|
    if /^#{Regexp.quote(address)} is alive$/ =~ o
      result << '1'
    else
      result << '0'
    end
  end
  PingResult.create(cond.merge(created_at: mtime, results: fping))
  puts "#{file}: import"
end
