//used in specs!

MatestackUiCore.Vue.component('test-component', {
  mixins: [MatestackUiCore.componentMixin],
  data: function data() {
    return {
      dynamic_value: "foo",
      received_message: ""
    };
  },
  methods:{
    emitMessage: function(event_name, message){
      MatestackUiCore.matestackEventHub.$emit(event_name, message)
    }
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "test-component: bar"
    }, 300);
    MatestackUiCore.matestackEventHub.$on("some_external_event", function(event){
      self.received_message = event.payload;
    })
  }
});

MatestackUiCore.Vue.component('my-test-component', {
  mixins: [MatestackUiCore.componentMixin],
  data: function data() {
    return {
      dynamic_value: "foo"
    };
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "my-test-component: bar"
    }, 300);
  }
});
