# Questions

AMQP.Application.get_connection => why :ok tuple if it crashes with a GenServer call?

[https://hexdocs.pm/amqp/AMQP.Application.html#get_channel/1-caveat](https://hexdocs.pm/amqp/AMQP.Application.html#get_channel/1-caveat) => why seperate send message when monitor fails? Isn't it better to handle this in a handle_continue? (race condition)

Update docs - get_channel returns a conn variable name?

What exactly is the consumer tag used for? E.g., I got this:
"amq.ctag-4LCNMKPb1j8VTpRVjbUEyQ"

Docs regarding consumer process isn't immediately available in default OTP structure.

Docs manually start connection in consumer process -> restarts / crashes not taken into account?

Typo "comsumer"
