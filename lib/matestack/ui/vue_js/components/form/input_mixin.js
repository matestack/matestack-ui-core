import matestackEventHub from '../../event_hub'

const formInputMixin = {
  inject: [
    'parentFormUid',
    'parentFormData',
    'parentFormErrors',
    'parentFormLoading',
    'parentFormIsNestedForm',
    'parentFormResetErrors',
    'parentNestedFormRuntimeId'
  ],
  methods: {
    initialize: function(){
      const self = this
      let data = {};

      for (let key in self.getRefs()) {
        if (key.startsWith("input.")) {
          let initValue = self.getRefs()[key]["attributes"]["init-value"];

          self.parentFormData[key.replace("input.", "")] = null

          if (initValue) {
            self.setValue(initValue["value"])
            self.afterInitialize(initValue["value"])
          } else {
            self.setValue(null)
            self.afterInitialize(null)
          }
        }
      }

    },
    filesAdded: function (key) {
      const dataTransfer = event.dataTransfer || event.target;
      const files = dataTransfer.files;
      if (event.target.attributes.multiple) {
        this.parentFormData[key] = [];
        for (let index in files) {
          if (files[index] instanceof File) {
            this.parentFormData[key].push(files[index]);
          }
        }
      } else {
        this.parentFormData[key] = files[0];
      }
    },
    inputChanged: function (key) {
      if (this.parentFormIsNestedForm){
        this.parentFormData["_destroy"] = false;
      }
      this.parentFormResetErrors(key);

    },
    afterInitialize: function(value){
      // can be used in the main component for further initialization steps
    },
    setValue: function (value){
      if(this.getRefs()["input."+this.props["key"]]){
        this.getRefs()["input."+this.props["key"]].value = value;  // reset file upload inputs properly
      }
      if(this.getRefs()["input."+this.props["key"]+"[]"]){
        this.getRefs()["input."+this.props["key"]+"[]"].value = value;  // reset multiple file upload inputs properly
      }
      this.parentFormData[this.props["key"]] = value;
    }
  },
  mounted: function(){
    this.registerScopedEvent("init", this.initialize, this.parentFormUid)
  },
  beforeUnmount: function(){
    this.removeScopedEvent("init", this.initialize, this.parentFormUid)
  }


}

export default formInputMixin
