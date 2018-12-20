import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import basemateEventHub from 'core/js/event-hub'

import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      data: {},
      showInlineForm: false,
      errors: {}
    }
  },
  methods: {
    initDataKey: function(key){
      this.data[key] = null;
    },
    inputChanged: function(key){
      this.resetErrors(key)
    },
    resetErrors: function(key){
      if (this.errors[key]){
        this.errors[key] = null;
      }
    },
    launchInlineForm: function(key, value){
      this.showInlineForm = true;
      this.data[key] = value;
      const self = this;
      setTimeout(function () {
        self.$refs.inlineinput.focus();
      }, 300);
    },
    closeInlineForm: function(){
      this.showInlineForm = false;
    },
    setProps: function(flat, newVal){
       for(var i in flat){
         if((typeof flat[i] === "object") && !(flat[i] instanceof Array)){
           setProps(flat[i], newVal);
           return;
         } else {
           flat[i] = newVal;
         }
      }
    },
    perform: function(){
      const self = this
      let payload = {}
      payload[self.componentConfig["for"]] = self.data
      axios({
        method: self.componentConfig["method"],
        url: self.componentConfig["submit_path"],
        data: payload,
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        }
      })
      .then(function(response){
        for (let key in self.componentConfig["success"]) {
          switch(key){
            case "transition":
              let path = self.componentConfig["success"]["transition"]["path"]
              self.$store.dispatch('navigateTo', {url: path, backwards: false})
              break;
            default:
              basemateEventHub.$emit(self.componentConfig["success"][key], key);
          }
        }
        if (self.componentConfig["notify"] === true) {
          if (typeof basemateUiCoreActionSuccess !== 'undefined') {
            basemateUiCoreActionSuccess(response);
          }
        }
        self.setProps(self.data, null);
        self.showInlineForm = false;
      })
      .catch(function(error){
        if(error.response && error.response.data && error.response.data.errors){
          self.errors = error.response.data.errors;
        }
        if (self.componentConfig["notify"] === true) {
          if (typeof basemateUiCoreActionError !== 'undefined') {
            basemateUiCoreActionError(error);
          }
        }
      })
    }
  },
  mounted: function(){
    let self = this;
    for (let key in self.$refs) {
      if (key.startsWith("input.")){
        self.initDataKey(key.replace('input.', ''));
      }
    }
  }
}

let component = Vue.component('form-cell', componentDef)

export default componentDef
