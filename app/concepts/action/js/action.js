import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  methods: {
    perform: function(){
      const self = this
      axios({
        method: self.componentConfig["method"],
        url: self.componentConfig["action_path"],
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        }
      })
      .then(function(response){
        for (let key in self.componentConfig["success"]) {
          self.$root.$refs[key][self.componentConfig["success"][key]]()
        }
        if (typeof basemateUiCoreActionSuccess !== 'undefined') {
          basemateUiCoreActionSuccess(response);
        }
      })
      .catch(function(response){
        if (typeof basemateUiCoreActionError !== 'undefined') {
          basemateUiCoreActionError(response);
        }
      })
    }
  }
}

let component = Vue.component('action-cell', componentDef)

export default componentDef
