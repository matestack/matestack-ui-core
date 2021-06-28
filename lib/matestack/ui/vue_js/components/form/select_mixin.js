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
            if (initValue) {
              data[key.replace("select.multiple.", "")] = JSON.parse(initValue["value"]);
              self.afterInitialize(JSON.parse(initValue["value"]))
            } else {
              data[key.replace("select.multiple.", "")] = [];
              self.afterInitialize([])
            }
          } else {
            if (initValue) {
              if (valueType && valueType["value"] == "Integer") {
                data[key.replace("select.", "")] = parseInt(initValue["value"]);
                self.afterInitialize(parseInt(initValue["value"]))
              } else {
                data[key.replace("select.", "")] = initValue["value"];
                self.afterInitialize(initValue["value"])
              }
            } else {
              data[key.replace("select.", "")] = null;
              self.afterInitialize(null)
            }
          }
        }
      }

      //without the timeout it's somehow not working
      setTimeout(function () {
        Object.assign(self.$parent.data, data);
        self.$parent.$forceUpdate();
        self.$forceUpdate();
      }, 1);
    },
    inputChanged: function (key) {
      if (this.$parent.isNestedForm){
        this.$parent.data["_destroy"] = false;
      }
      this.$parent.resetErrors(key);
      this.$parent.$forceUpdate();
      this.$forceUpdate();
    },
    afterInitialize: function(value){
      // can be used in the main component for further initialization steps
    },
    setValue: function (value){
      this.$parent.data[this.props["key"]] = value
      this.$parent.$forceUpdate();
      this.$forceUpdate();
    }
  }

}

export default formSelectMixin
