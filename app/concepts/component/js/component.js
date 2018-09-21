import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"

const componentMixin = {
  props: ['componentConfig', 'params'],
  data: function(){
    return {
      asyncTemplate: null
    }
  },
  methods: {
    rerender: function(){
      var self = this;
      self.params["component_key"] = self.componentConfig["component_key"]
      axios({
        method: "get",
        url: self.componentConfig["origin_url"],
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: self.params
      })
      .then(function(response){
        self.asyncTemplate = response["data"];
      })
    },
    rerenderWith: function(newParams){
      Object.assign(this.params, newParams);
      this.rerender()
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

export default componentMixin
