import Mix.Config

amqp_connection_options = [
  host: "localhost",
  port: 5672,
  virtual_host: "/",
  username: "guest",
  password: "guest"
]

config :amqp,
  connections: [
    hello_tcp_connection: amqp_connection_options,
    world_tcp_connection: amqp_connection_options
  ],
  channels: [
    hello_produce_channel: [connection: :hello_tcp_connection],
    world_consume_channel: [connection: :world_tcp_connection]
  ]
