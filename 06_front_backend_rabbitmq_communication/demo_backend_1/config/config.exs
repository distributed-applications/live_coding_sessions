import Config

amqp_connection_options = [
  host: "localhost",
  port: 5672,
  virtual_host: "/",
  username: "guest",
  password: "guest"
]

config :amqp,
  connections: [
    publish_tcp_connection: amqp_connection_options,
    consume_tcp_connection: amqp_connection_options
  ],
  channels: [
    webserver_channel: [connection: :publish_tcp_connection],
    garbage_can_channel: [connection: :consume_tcp_connection]
  ]
