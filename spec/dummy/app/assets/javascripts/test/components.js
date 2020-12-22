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

MatestackUiCore.Vue.component('custom-form-input-test', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formInputMixin],
  data() {
    return {};
  },
  methods: {
    changeValueViaJs: function(value){
      this.setValue(value);
    },
    afterInitialize: function(value){
      if(value == "change me via JS"){
        this.setValue("done");
      }
    }
  },
  mounted: function(){
    if(this.$el.querySelector("#bar") != undefined){
      this.$el.querySelector("#bar").classList.add("js-added-class")
    }
  }
});

MatestackUiCore.Vue.component('custom-form-textarea-test', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formTextareaMixin],
  data() {
    return {};
  },
  methods: {
    changeValueViaJs: function(value){
      this.setValue(value);
    },
    afterInitialize: function(value){
      if(value == "change me via JS"){
        this.setValue("done");
      }
    }
  },
  mounted: function(){
    if(this.$el.querySelector("#bar") != undefined){
      this.$el.querySelector("#bar").classList.add("js-added-class")
    }
  }
});

MatestackUiCore.Vue.component('custom-form-radio-test', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formRadioMixin],
  data() {
    return {};
  },
  methods: {
    changeValueViaJs: function(value){
      this.setValue(value);
    },
    afterInitialize: function(value){
      if(value == "change me via JS"){
        this.setValue("Array Option 1");
      }
    }
  },
  mounted: function(){
    if(this.$el.querySelector("#bar_1") != undefined){
      this.$el.querySelector("#bar_1").classList.add("js-added-class")
    }
  }
});

MatestackUiCore.Vue.component('custom-form-checkbox-test', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formCheckboxMixin],
  data() {
    return {};
  },
  methods: {
    changeValueViaJs: function(value){
      this.setValue(value);
    },
    afterInitialize: function(value){
      if(value == "change me via JS"){
        this.setValue(2);
      }
    }
  },
  mounted: function(){
    if(this.$el.querySelector("#bar_1") != undefined){
      this.$el.querySelector("#bar_1").classList.add("js-added-class")
    }
  }
});

MatestackUiCore.Vue.component('custom-form-select-test', {
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formSelectMixin],
  data() {
    return {};
  },
  methods: {
    changeValueViaJs: function(value){
      this.setValue(value);
    },
    afterInitialize: function(value){
      if(value == "change me via JS"){
        this.setValue(2);
      }
    }
  },
  mounted: function(){
    if(this.$el.querySelector("#bar") != undefined){
      this.$el.querySelector("#bar").classList.add("js-added-class")
    }
  }
});
