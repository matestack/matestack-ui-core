import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"

const componentDef = {
  props: ['appConfig', 'params'],
  data: function(){
    return {
      asyncTemplate: null
    }
  },
  methods: {
    navigateTo: function(url){
      var self = this;
      // if(self.params == undefined) {
      //   self.params = {}
      // }
      // self.params["only_page"] = true;
      axios({
        method: "get",
        url: url,
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: {"only_page": true}
      })
      .then(function(response){
        self.asyncTemplate = response["data"];
      })
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('app', componentDef)

export default componentDef
