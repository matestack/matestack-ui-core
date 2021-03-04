const formRadioMixin = {
  methods: {
    initialize: function(){
      const self = this
      let data = {};

      for (let key in self.$refs) {
        let initValue = self.$refs[key]["attributes"]["init-value"];
        let valueType = self.$refs[key]["attributes"]["value-type"];

        if (key.startsWith("select.")) {
          if (key.startsWith("select.multiple.")) {
            if (initValue) {
              data[key.replace("select.multiple.", "")] = JSON.parse(initValue["value"]);
              Object.assign(self.$parent.data, data);
              self.afterInitialize(JSON.parse(initValue["value"]))
            } else {
              data[key.replace("select.multiple.", "")] = [];
              Object.assign(self.$parent.data, data);
              self.afterInitialize([])
            }
          } else {
            if (initValue) {
              if (valueType && valueType["value"] == "Integer") {
                data[key.replace("select.", "")] = parseInt(initValue["value"]);
                Object.assign(self.$parent.data, data);
                self.afterInitialize(parseInt(initValue["value"]))
              } else {
                data[key.replace("select.", "")] = initValue["value"];
                Object.assign(self.$parent.data, data);
                self.afterInitialize(initValue["value"])
              }
            } else {
              data[key.replace("select.", "")] = null;
              Object.assign(self.$parent.data, data);
              self.afterInitialize(null)
            }
          }
        }
      }

      //without the timeout it's somehow not working
      setTimeout(function () {
        self.$forceUpdate();
      }, 1);
    },
    inputChanged: function (key) {
      this.$parent.resetErrors(key);
      this.$forceUpdate();
    },
    afterInitialize: function(value){
      // can be used in the main component for further initialization steps
    },
    setValue: function (value){
      this.$parent.data[this.componentConfig["key"]] = value
      this.$forceUpdate();
    }
  }

}

export default formRadioMixin
