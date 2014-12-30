#!/usr/bin/env ruby
# Sensu Redis Mailer

require 'sensu-handler'
require 'redis'
require 'mail'
require 'socket'

class RedisMailer < Sensu::Handler
  def host
    settings['redis']['host'] || 'localhost'
  end

  def port
    settings['redis']['port'] || '6379'
  end

  def queue
    settings['redis']['queue'] || 'sensu_events'
  end

  def prepare
    text = ''
    redis = Redis.new host: host, port: port
    length = redis.llen queue
    events = redis.lrange queue, 0, length - 1

    events.each do |event|
      metrics = JSON.parse event
      text += "#{Time.at(metrics['timestamp']).strftime('%Y/%m/%d %H:%M:%S')}\n"
      text += "#{metrics['client']} (#{metrics['address']}) #{metrics['check']}\n"
      text += "#{metrics['output'].split("\n").first}\n"
      text += "\n"
    end

    redis.del queue
    text
  end

  def deliver
    @@autorun = false
    text = prepare
    method = settings['mail']
    return if text.empty?

    mail = Mail.new do
      from "#{method['user_name']}@#{method['domain']}"
      to method['to']
      subject "#{Socket.gethostname} sensu summary #{Time.now.strftime('%Y/%m/%d %H:%M:%S')}"
      body text
    end

    mail.delivery_method(:smtp,
      address: method['address'] || 'localhost',
      port: method['port'] || 25,
      domain: method['domain'] || 'localhost.localdomain',
      authentication: :login,
      user_name: method['user_name'] || nil,
      password: method['password'] || nil
    )

    mail.deliver
  end
end

redis_mailer = RedisMailer.new
redis_mailer.deliver
