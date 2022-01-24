const formTextareaMixin = {
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

      for (let key in this.getRefs()) {
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
      this.parentFormData[this.props["key"]] = value
    }
  },
  mounted: function(){
    this.registerScopedEvent("init", this.initialize, this.parentFormUid)
  },
  beforeUnmount: function(){
    this.removeScopedEvent("init", this.initialize, this.parentFormUid)
  }

}

export default formTextareaMixin
