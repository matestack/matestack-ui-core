const formInputMixin = {
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
    filesAdded: function (key) {
      const dataTransfer = event.dataTransfer || event.target;
      const files = dataTransfer.files;
      if (event.target.attributes.multiple) {
        this.$parent.data[key] = [];
        for (let index in files) {
          if (files[index] instanceof File) {
            this.$parent.data[key].push(files[index]);
          }
        }
      } else {
        this.$parent.data[key] = files[0];
      }
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

export default formInputMixin
