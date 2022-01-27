//used in specs!

import MatestackUiVueJs from 'matestack-ui-vue_js'

const testComponent = {
  mixins: [MatestackUiVueJs.componentMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
  data: function data() {
    return {
      dynamic_value: "foo",
      received_message: ""
    };
  },
  methods:{
    emitMessage: function(event_name, message){
      MatestackUiVueJs.eventHub.$emit(event_name, message)
    }
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "test-component: bar"
    }, 300);
    MatestackUiVueJs.eventHub.$on("some_external_event", function(data){
      self.received_message = data;
    })
  }
};

const myTestComponent = {
  mixins: [MatestackUiVueJs.componentMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
};

const customFormInputComponent = {
  mixins: [MatestackUiVueJs.componentMixin, MatestackUiVueJs.formInputMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
    if(this.getElement().querySelector("#bar") != undefined){
      this.getElement().querySelector("#bar").classList.add("js-added-class")
    }
    if(this.getElement().querySelector("#baz") != undefined){
      this.getElement().querySelector("#baz").classList.add("js-added-other-class")
    }
  }
};

const customFormTextareaComponent = {
  mixins: [MatestackUiVueJs.componentMixin, MatestackUiVueJs.formTextareaMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
    if(this.getElement().querySelector("#bar") != undefined){
      this.getElement().querySelector("#bar").classList.add("js-added-class")
    }
  }
};

const customFormRadioComponent = {
  mixins: [MatestackUiVueJs.componentMixin, MatestackUiVueJs.formRadioMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
    if(this.getElement().querySelector("#bar_1") != undefined){
      this.getElement().querySelector("#bar_1").classList.add("js-added-class")
    }
  }
};

const customFormCheckboxComponent = {
  mixins: [MatestackUiVueJs.componentMixin, MatestackUiVueJs.formCheckboxMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
    if(this.getElement().querySelector("#bar_1") != undefined){
      this.getElement().querySelector("#bar_1").classList.add("js-added-class")
    }
  }
};

const customFormSelectComponent = {
  mixins: [MatestackUiVueJs.componentMixin, MatestackUiVueJs.formSelectMixin],
  template: MatestackUiVueJs.componentHelpers.inlineTemplate,
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
    if(this.getElement().querySelector("#bar") != undefined){
      this.getElement().querySelector("#bar").classList.add("js-added-class")
    }
  }
};

const registerCustomComponents = function(appInstance){
  appInstance.component('custom-form-select-test', customFormSelectComponent)
  appInstance.component('custom-form-checkbox-test', customFormCheckboxComponent)
  appInstance.component('custom-form-radio-test', customFormRadioComponent)
  appInstance.component('custom-form-textarea-test', customFormTextareaComponent)
  appInstance.component('custom-form-input-test', customFormInputComponent)
  appInstance.component('my-test-component', myTestComponent)
  appInstance.component('test-component', testComponent)
}

export default registerCustomComponents
