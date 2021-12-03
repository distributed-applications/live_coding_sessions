# Demo1

## Look at following changes

* dev.exs config for rabbitmq config
* application.ex to see which consumer / producer I start (and how)
* [FRONTEND] application.ex to see a simple in-mem db for logs (should be notifications which are sent real-time over websockets...)

## Steps / approach

0. Make config
1. Publish a message with your frontend
2. Check in management console!
3. Consume and apply necessary logic

## Extra fun reading materials (not a must!)

* This is a request/reply pattern. Since it's so common, RabbitMQ automated some things for this. You're free to implement it manually (like this demo) or to use this header. Before doing everything with reply-to, think about scalibility for both the front en backend though... [https://www.rabbitmq.com/direct-reply-to.html](https://www.rabbitmq.com/direct-reply-to.html)
* [https://blog.rabbitmq.com/posts/2010/10/exchange-to-exchange-bindings/](https://blog.rabbitmq.com/posts/2010/10/exchange-to-exchange-bindings/)
* For bonus points - understanding (publish) acknowledgements [https://www.rabbitmq.com/confirms.html](https://www.rabbitmq.com/confirms.html)
  * Tip: In this demo, you can make the publisher GenServer also a module. GenServer has benefits since it can hold state. What's the relation between GenServer state and above confirms-related link?
  * Personal memo: _Untested and has to be verified: can the publish be module based (parallel publishes) where the handler is a separate GS? This in order to let the executor send the GS it's seqno - so that publish confirm can be tracked..._
