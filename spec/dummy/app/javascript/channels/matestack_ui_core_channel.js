import consumer from "./consumer"

consumer.subscriptions.create("MatestackUiCoreChannel", {
  connected() {
    console.log('connected')
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    console.log('received data')
    MatestackUiCore.matestackEventHub.$emit(data.event, data)
  }
});
