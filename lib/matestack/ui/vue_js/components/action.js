import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'
import matestackEventHub from '../event_hub'
import componentMixin from './mixin'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  methods: {
    perform: function(){
      const self = this
      if (
        (self.props["confirm"] == undefined) || confirm(self.props["confirm_text"])
      )
      {
        if (self.props["emit"] != undefined) {
          matestackEventHub.$emit(self.props["emit"]);
        }
        if (self.props["delay"] != undefined) {
          setTimeout(function () {
            self.sendRequest()
          }, parseInt(self.props["delay"]));
        } else {
          this.sendRequest()
        }
      }
    },
    sendRequest: function(){
      const self = this
      axios({
          method: self.props["method"],
          url: self.props["action_path"],
          data: self.props["data"],
          headers: {
            'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
          }
        }
      )
      .then(function(response){
        if (self.props["success"] != undefined && self.props["success"]["emit"] != undefined) {
          matestackEventHub.$emit(self.props["success"]["emit"], response.data);
        }

        // transition handling
        if (self.props["success"] != undefined
          && self.props["success"]["transition"] != undefined
          && (
            self.props["success"]["transition"]["follow_response"] == undefined
            ||
            self.props["success"]["transition"]["follow_response"] === false
          )
          && self.$store != undefined
        ) {
          let path = self.props["success"]["transition"]["path"]
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
          return;
        }
        if (self.props["success"] != undefined
          && self.props["success"]["transition"] != undefined
          && self.props["success"]["transition"]["follow_response"] === true
          && self.$store != undefined
        ) {
          let path = response.data["transition_to"] || response.request.responseURL
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
          return;
        }
        // redirect handling
        if (self.props["success"] != undefined
          && self.props["success"]["redirect"] != undefined
          && (
            self.props["success"]["redirect"]["follow_response"] == undefined
            ||
            self.props["success"]["redirect"]["follow_response"] === false
          )
          && self.$store != undefined
        ) {
          let path = self.props["success"]["redirect"]["path"]
          window.location.href = path
          return;
        }
        if (self.props["success"] != undefined
          && self.props["success"]["redirect"] != undefined
          && self.props["success"]["redirect"]["follow_response"] === true
          && self.$store != undefined
        ) {
          let path = response.data["redirect_to"] || response.request.responseURL
          window.location.href = path
          return;
        }
      })
      .catch(function(error){
        if (self.props["failure"] != undefined && self.props["failure"]["emit"] != undefined) {
          matestackEventHub.$emit(self.props["failure"]["emit"], error.response.data);
        }
        // transition handling
        if (self.props["failure"] != undefined
          && self.props["failure"]["transition"] != undefined
          && (
            self.props["failure"]["transition"]["follow_response"] == undefined
            ||
            self.props["failure"]["transition"]["follow_response"] === false
          )
          && self.$store != undefined
        ) {
          let path = self.props["failure"]["transition"]["path"]
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
          return;
        }
        if (self.props["failure"] != undefined
          && self.props["failure"]["transition"] != undefined
          && self.props["failure"]["transition"]["follow_response"] === true
          && self.$store != undefined
        ) {
          let path = error.response.data["transition_to"] || response.request.responseURL
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
          return;
        }
        // redirect handling
        if (self.props["failure"] != undefined
          && self.props["failure"]["redirect"] != undefined
          && (
            self.props["failure"]["redirect"]["follow_response"] == undefined
            ||
            self.props["failure"]["redirect"]["follow_response"] === false
          )
          && self.$store != undefined
        ) {
          let path = self.props["failure"]["redirect"]["path"]
          window.location.href = path
          return;
        }
        if (self.props["failure"] != undefined
          && self.props["failure"]["redirect"] != undefined
          && self.props["failure"]["redirect"]["follow_response"] === true
          && self.$store != undefined
        ) {
          let path = error.response.data["redirect_to"] || response.request.responseURL
          window.location.href = path
          return;
        }
      })
    }
  }
}

let component = Vue.component('matestack-ui-core-action', componentDef)

export default componentDef
