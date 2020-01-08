import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import matestackEventHub from 'js/event-hub'

import componentMixin from 'component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  methods: {
    perform: function(){
      const self = this
      if (
        (self.componentConfig["confirm"] == undefined) || confirm(self.componentConfig["confirm_text"])
      )
      {
        axios({
          method: self.componentConfig["method"],
          url: self.componentConfig["action_path"],
          data: self.componentConfig["data"],
          headers: {
            'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
          }
        })
        .then(function(response){
          if (self.componentConfig["success"] != undefined && self.componentConfig["success"]["emit"] != undefined) {
            matestackEventHub.$emit(self.componentConfig["success"]["emit"], response.data);
          }
          if (self.componentConfig["success"] != undefined
            && self.componentConfig["success"]["transition"] != undefined
            && (
              self.componentConfig["success"]["transition"]["follow_response"] == undefined
              ||
              self.componentConfig["success"]["transition"]["follow_response"] === false
            )
            && self.$store != undefined
          ) {
            let path = self.componentConfig["success"]["transition"]["path"]
            self.$store.dispatch('navigateTo', {url: path, backwards: false})
            return;
          }
          if (self.componentConfig["success"] != undefined
            && self.componentConfig["success"]["transition"] != undefined
            && self.componentConfig["success"]["transition"]["follow_response"] === true
            && self.$store != undefined
          ) {
            let path = response.data["transition_to"] || response.request.responseURL;
            self.$store.dispatch('navigateTo', {url: path, backwards: false});
            return;
          }
        })
        .catch(function(error){
          if (self.componentConfig["failure"] != undefined && self.componentConfig["failure"]["emit"] != undefined) {
            matestackEventHub.$emit(self.componentConfig["failure"]["emit"], error.response.data);
          }
          if (self.componentConfig["failure"] != undefined && self.componentConfig["failure"]["transition"] != undefined && self.$store != undefined) {
            let path = self.componentConfig["failure"]["transition"]["path"]
            self.$store.dispatch('navigateTo', {url: path, backwards: false})
          }
        })
      }
    }
  }
}

let component = Vue.component('matestack-ui-core-action', componentDef)

export default componentDef
