# frozen_string_literal: true
require 'sequel'
require 'active_support/time'

DB = Sequel.connect(ENV['DATABASE_URL'])

class Target < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:range, :min, :max, :group]
    validates_format /\A(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|x)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|x)\z/, :range
    errors.add(:range, 'has multiple x') if /x.*x/ =~ range
    errors.add(:range, 'has no x') if /x/ !~ range
    validates_includes (0..255), [:min, :max]
    validates_unique :range
  end

  def range_with_min_max
    range.sub(/x/, "#{min}-#{max}")
  end

  def addresses
    (min..max).map do |x|
      range.sub(/x/, x.to_s)
    end
  end

  def fping
    require 'open3'
    addresses = addresses()
    o, s = Open3.capture2(*%w(fping -a -r 0), stdin_data: addresses.join("\n"))
    addresses.each_with_object(''.dup) do |address, result|
      if /^#{Regexp.quote(address)}$/ =~ o
        result << '1'
      else
        result << '0'
      end
    end
  end

  def create_result
    PingResult.create(range: range, min: min, max: max, results: fping)
  end

  def all_results(where={})
    {
      range: range,
      min: min,
      max: max,
      results: PingResult.where(where).where(range: range, min: min, max: max).order(:created_at).select_map([:created_at, :results])
    }
  end

  def ip_results(x, where={})
    n = x.to_i - min
    h = {}
    PingResult.where(where).where(range: range, min: min, max: max).order(:created_at).select_map([:created_at, :results]).map do |created_at, results|
      array = (h[created_at.to_date] ||= [])
      array << [
        created_at,
        results[n]
      ]
    end
    h.to_a
  end
end

class PingResult < Sequel::Model
  plugin :validation_helpers

  def validate
    super
    validates_presence [:range, :min, :max, :results]
  end

  def before_validation
    super
    self.created_at ||= Time.now
  end
end
