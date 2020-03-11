import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import matestackEventHub from '../js/event-hub'
import componentMixin from '../component/component'

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
    initDataKey: function(key, initValue){
      this.data[key] = initValue;
    },
    inputChanged: function(key){
      this.resetErrors(key)
    },
    updateFormValue: function(key, value){
      this.data[key] = value;
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
    initValues: function(){
      let self = this;
      let data = {}
      for (let key in self.$refs) {
        let initValue = self.$refs[key]["attributes"]["init-value"]
        let valueType = self.$refs[key]["attributes"]["value-type"]

        if (key.startsWith("input.")){
          if(initValue){
            data[key.replace('input.', '')] = initValue["value"]
          }else{
            data[key.replace('input.', '')] = null
          }
        }
        if (key.startsWith("select.")){
          if (key.startsWith("select.multiple.")){
            if(initValue){
              data[key.replace('select.multiple.', '')] = JSON.parse(initValue["value"])
            }else{
              data[key.replace('select.multiple.', '')] = []
            }
          }else{
            if(initValue){
              if(valueType && valueType["value"] == "Integer")
                data[key.replace('select.', '')] = parseInt(initValue["value"])
              else{
                data[key.replace('select.', '')] = initValue["value"]
              }
            }else{
              data[key.replace('select.', '')] = null
            }
          }

        }
      }
      self.data = data;
    },
    shouldResetFormOnSuccessfulSubmit() {
      const self = this
      if (self.componentConfig['success'] != undefined && self.componentConfig['success']['reset'] != undefined) {
        return self.componentConfig['success']['reset']
      } else {
        return self.shouldResetFormOnSuccessfulSubmitByDefault()
      }
    },
    shouldResetFormOnSuccessfulSubmitByDefault() {
      const self = this
      if (self.componentConfig["method"] == "put") {
        return false
      } else {
        return true
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
          let path = response.data["transition_to"] || response.request.responseURL
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
          return;
        }
        if (self.shouldResetFormOnSuccessfulSubmit())
        {
          self.setProps(self.data, null);
          self.initValues();
        }
        self.showInlineForm = false;
      })
      .catch(function(error){
        if(error.response && error.response.data && error.response.data.errors){
          self.errors = error.response.data.errors;
        }
        if (self.componentConfig["failure"] != undefined && self.componentConfig["failure"]["emit"] != undefined) {
          matestackEventHub.$emit(self.componentConfig["failure"]["emit"], error.response.data);
        }
        if (self.componentConfig["failure"] != undefined && self.componentConfig["failure"]["transition"] != undefined && self.$store != undefined) {
          let path = self.componentConfig["failure"]["transition"]["path"]
          self.$store.dispatch('navigateTo', {url: path, backwards: false})
        }
      })
    }
  },
  mounted: function(){
    this.initValues()
  }
}

let component = Vue.component('matestack-ui-core-form', componentDef)

export default componentDef
