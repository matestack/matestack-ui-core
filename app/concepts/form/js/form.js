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
      showInlineForm: false
    }
  },
  methods: {
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
          basemateEventHub.$emit(self.componentConfig["success"][key], key);
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
        if (self.componentConfig["notify"] === true) {
          if (typeof basemateUiCoreActionError !== 'undefined') {
            basemateUiCoreActionError(error);
          }
        }
      })
    }
  }
}

let component = Vue.component('form-cell', componentDef)

export default componentDef
