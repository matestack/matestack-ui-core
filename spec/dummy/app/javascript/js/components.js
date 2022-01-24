//used in specs!

import MatestackUiCore from 'matestack-ui-core'

const testComponent = {
  mixins: [MatestackUiCore.componentMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
  data: function data() {
    return {
      dynamic_value: "foo",
      received_message: ""
    };
  },
  methods:{
    emitMessage: function(event_name, message){
      MatestackUiCore.eventHub.$emit(event_name, message)
    }
  },
  mounted(){
    const self = this
    setTimeout(function () {
      self.dynamic_value = "test-component: bar"
    }, 300);
    MatestackUiCore.eventHub.$on("some_external_event", function(data){
      self.received_message = data;
    })
  }
};

const myTestComponent = {
  mixins: [MatestackUiCore.componentMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formInputMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formTextareaMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formRadioMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formCheckboxMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
  mixins: [MatestackUiCore.componentMixin, MatestackUiCore.formSelectMixin],
  template: MatestackUiCore.componentHelpers.inlineTemplate,
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
