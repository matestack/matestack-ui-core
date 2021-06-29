const formTextareaMixin = {
  methods: {
    initialize: function(){
      const self = this
      let data = {};

      for (let key in this.$refs) {
        let initValue = this.$refs[key]["attributes"]["init-value"];

        self.$set(self.$parent.data, key.replace("input.", ""), null)

        if (initValue) {
          self.setValue(initValue["value"])
          self.afterInitialize(initValue["value"])
        } else {
          self.setValue(null)
          self.afterInitialize(null)
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

export default formTextareaMixin
