import consumer from "./consumer"
import MatestackUiVueJs from 'matestack-ui-vue_js'

consumer.subscriptions.create("MatestackUiVueJsChannel", {
  connected() {
    console.log('connected')
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    MatestackUiVueJs.eventHub.$emit(data.event, data)
  }
});
