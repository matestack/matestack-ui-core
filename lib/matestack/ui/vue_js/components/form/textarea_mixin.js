const formTextareaMixin = {
  methods: {
    initialize: function(){
      const self = this
      let data = {};

      for (let key in this.$refs) {
        let initValue = this.$refs[key]["attributes"]["init-value"];

        if (initValue) {
          data[key.replace("input.", "")] = initValue["value"];
          Object.assign(self.$parent.data, data);
          self.afterInitialize(initValue["value"])
        } else {
          data[key.replace("input.", "")] = null;
          Object.assign(self.$parent.data, data);
          self.afterInitialize(null)
        }
      }

      //without the timeout it's somehow not working
      setTimeout(function () {
        self.$parent.$forceUpdate();
        self.$forceUpdate();
      }, 1);
    },
    inputChanged: function (key) {
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

export default formTextareaMixin
