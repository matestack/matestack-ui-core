const formSelectMixin = {
  methods: {
    initialize: function(){
      const self = this
      let data = {};

      for (let key in self.$refs) {
        let initValue = self.$refs[key]["attributes"]["init-value"];
        let valueType = self.$refs[key]["attributes"]["value-type"];

        if (key.startsWith("select.")) {
          if (key.startsWith("select.multiple.")) {
            self.$set(self.$parent.data, key.replace("select.multiple.", ""), null)
            if (initValue) {
              self.setValue(JSON.parse(initValue["value"]));
              self.afterInitialize(JSON.parse(initValue["value"]))
            } else {
              self.setValue([]);
              self.afterInitialize([]);
            }
          } else {
            self.$set(self.$parent.data, key.replace("select.", ""), null)
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
        }
      }
    },
    inputChanged: function (key) {
      if (this.$parent.isNestedForm){
        this.$parent.data["_destroy"] = false;
      }
      this.$parent.resetErrors(key);
    },
    afterInitialize: function(value){
      // can be used in the main component for further initialization steps
    },
    setValue: function (value){
      this.$parent.data[this.props["key"]] = value
    }
  }

}

export default formSelectMixin
