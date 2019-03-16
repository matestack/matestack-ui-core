import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import basemateEventHub from 'core/js/event-hub'

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
        data: self.componentConfig["data"],
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        }
      })
      .then(function(response){
        for (let key in self.componentConfig["success"]) {
          basemateEventHub.$emit(self.componentConfig["success"][key], key);
        }
        if (self.componentConfig["notify"] === true) {
          basemateEventHub.$emit("action_success", response);
          if (typeof basemateUiCoreActionSuccess !== 'undefined') {
            basemateUiCoreActionSuccess(response);
          }
        }
      })
      .catch(function(error){
        if (self.componentConfig["notify"] === true) {
          basemateEventHub.$emit("action_error", error);
          if (typeof basemateUiCoreActionError !== 'undefined') {
            basemateUiCoreActionError(error);
          }
        }
      })
    }
  }
}

let component = Vue.component('action-cell', componentDef)

export default componentDef
