## Sensu Handlers & Mailer for Redis

    2012/01/13 02:42:39
    host01 (10.2.1.11) frontend_http_check
    HTTP CRITICAL: HTTP/1.1 503 Service Temporarily Unavailable

#### About

 - `redis_handler.rb`: SensuのEventをRedisに保存(`occurrences`が1の場合)
 - `redis_mailer.rb`: Redisに保存されたEventをまとめてメール

#### How to use

Sensu内蔵のRubyを使用する。

    # /opt/sensu/embedded/bin/gem install redis mail
    # cd /etc/sensu/handlers
    # wget https://raw.githubusercontent.com/hico-horiuchi/sensu-redis-mailer/master/redis_handler.rb
    # wget https://raw.githubusercontent.com/hico-horiuchi/sensu-redis-mailer/master/redis_mailer.rb
    # chmod 755 redis_handler.rb redis_mailer.rb
    # cd /etc/sensu/conf.d
    # wget https://raw.githubusercontent.com/hico-horiuchi/sensu-redis-mailer/master/handler_redis.json
    # service sensu-server restart
    # crontab -e

Cronで定期的に`redis_mailer.rb`を実行する(ここでは2時間ごと)。

    0 */2 * * * /opt/sensu/embedded/bin/ruby /etc/sensu/handlers/redis_mailer.rb

## Settings

`handler_redis.json`の設定項目。  
RedisはSensuの設定に従い、メールは標準でlocalhostを使用する。

<table>
  <thead></thead>
  <tbody>
    <tr>
      <td>redis</td>
      <td>queue</td>
      <td>Eventを保存するRedisのkey</td>
    </tr>
    <tr>
      <td rowspan="6">mail</td>
      <td>address</td>
      <td>差出人メールアドレス</td>
    </tr>
    <tr>
      <td>port</td>
      <td>メールサーバのポート</td>
    </tr>
    <tr>
      <td>domain</td>
      <td>メールアドレスのHELOドメイン</td>
    </tr>
    <tr>
      <td>user_name</td>
      <td>メールアカウントのユーザ名</td>
    </tr>
    <tr>
      <td>password</td>
      <td>メールアカウントのパスワード</td>
    </tr>
    <tr>
      <td>to</td>
      <td>宛先メールアドレス</td>
    </tr>
  </tbody>
</table>
