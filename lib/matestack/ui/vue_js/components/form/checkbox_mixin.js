const formCheckboxMixin = {
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
        let initValue;
        let valueType;

        if (key.startsWith("select.") || key.startsWith("input.")) {
          initValue = self.getRefs()[key]["attributes"]["init-value"];
          valueType = self.getRefs()[key]["attributes"]["value-type"];
        }

        if (key.startsWith("select.")) {
          if (key.startsWith("select.multiple.")) {
            self.parentFormData[key.replace("select.multiple.", "")] = null
            if (initValue) {
              self.setValue(JSON.parse(initValue["value"]));
              self.afterInitialize(JSON.parse(initValue["value"]))
            } else {
              self.setValue([]);
              self.afterInitialize([]);
            }
          } else {
            self.parentFormData[key.replace("select.", "")] = null
            if (initValue) {
              if (valueType && valueType["value"] == "Integer") {
                self.setValue(parseInt(initValue["value"]));
                self.afterInitialize(parseInt(initValue["value"]))
              } else {
                self.setValue(initValue["value"]);
                self.afterInitialize(initValue["value"])
              }
            } else {
              self.setValue(null);
              self.afterInitialize(null)
            }
          }
        } else {
          self.parentFormData[key.replace("input.", "")] = null
          if (initValue) {
            if(initValue["value"] === "true"){
              self.setValue(true);
              self.afterInitialize(true)
            }
            if(initValue["value"] === "false"){
              self.setValue(false);
              self.afterInitialize(false)
            }
          } else {
            self.setValue(null);
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

export default formCheckboxMixin
