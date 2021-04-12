# Vue.js Event Hub

Matestack offers an event hub, which can be used to communicate between components.

## Emitting events

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {}
  },
  mounted(){
    MatestackUiCore.matestackEventHub.$emit("some-event", { some: "optional data" })
  }
})
```

Use `MatestackUiCore.matestackEventHub.$emit(EVENT_NAME, OPTIONAL PAYLOAD)`

## Receiving events

`app/matestack/components/some_component.js`

```javascript
MatestackUiCore.Vue.component('some-component', {
  mixins: [MatestackUiCore.componentMixin],
  data() {
    return {}
  },
  methods: {
    reactToEvent(payload){
      console.log(payload)
    }
  },
  mounted(){
    MatestackUiCore.matestackEventHub.$on("some-event", this.reactToEvent)
  },
  beforeDestroy: function() {
    matestackEventHub.$off("some-event", this.reactToEvent)
  }
})
```

Make sure to cancel the event listener within the `beforeDestroy` hook!

