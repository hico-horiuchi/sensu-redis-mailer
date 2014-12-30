#!/usr/bin/env ruby
# Sensu Redis Handler

require 'sensu-handler'
require 'redis'

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

  def handle
    return if @event['occurrences'] > 1
    metrics = {
      timestamp: @event['client']['timestamp'],
      client: @event['client']['name'],
      address: @event['client']['address'],
      check: @event['check']['name'],
      output: @event['check']['output']
    }

    redis = Redis.new host: host, port: port
    redis.rpush queue, metrics.to_json
  end
end
