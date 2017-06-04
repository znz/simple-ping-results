#!/usr/bin/env ruby
# frozen_string_literal: true
require 'sinatra'
require 'sinatra/reloader' if development?
ENV['DATABASE_URL'] ||= "sqlite://#{Sinatra::Base.environment}.db"
require_relative 'models'

get '/' do
  @target_cond = params[:all] ? {} : { enable: true }
  @offset = 0
  @title = 'Simple Ping Results'
  haml :index
end

get '/index/:offset' do
  @target_cond = params[:all] ? {} : { enable: true }
  @offset = params[:offset].to_i
  @title = 'Simple Ping Results'
  haml :index
end

get '/target/:range/:offset?' do
  @range = params[:range]
  @offset = params[:offset].to_i
  @target = Target.where(range: @range).first
  @title = "#{@target.range_with_min_max}: Simple Ping Results"
  haml :target
end

get '/ip/:range/:x/:offset?' do
  @range = params[:range]
  @x = params[:x]
  @offset = params[:offset].to_i
  @target = Target.where(range: @range).first
  @ip = @target.range.sub(/x/, @x)
  @title = "#{@ip}: Simple Ping Results"
  haml :ip
end

helpers do
  def protect!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    username = ENV['BASIC_AUTH_USERNAME']
    password = ENV['BASIC_AUTH_PASSWORD']
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end
end

get '/admin' do
  protect!
  @title = 'Admin'
  haml :admin
end

get '/admin/target/new' do
  protect!
  @target = Target.new
  @title = "New target: Simple Ping Results"
  haml :admin_target
end

post '/admin/target/new' do
  protect!
  @target = Target.new
  @target.range = params[:range]
  @target.min = params[:min]
  @target.max = params[:max]
  @target.enable = !!params[:enable]
  begin
    @target.save
    redirect '/admin'
  rescue Sequel::ValidationFailed
    haml :admin_target
  end
end

get '/admin/target/:id' do
  protect!
  @target = Target.where(id: params[:id]).first
  @title = "Edit #{@target.range_with_min_max}: Simple Ping Results"
  haml :admin_target
end

put '/admin/target/:id' do
  protect!
  @target = Target.where(id: params[:id]).first
  @target.range = params[:range]
  @target.min = params[:min]
  @target.max = params[:max]
  @target.enable = !!params[:enable]
  begin
    @target.save
    redirect '/admin'
  rescue Sequel::ValidationFailed
    haml :admin_target
  end
end
