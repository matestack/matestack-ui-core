import Vue from "vue/dist/vue.esm";
import Vuex from "vuex";
import axios from "axios";

import matestackEventHub from "../../../../../../app/concepts/matestack/ui/core/js/event-hub";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin],
  data: function () {
    return {
      data: {},
      errors: {},
      loading: false
    };
  },
  methods: {
    initDataKey: function (key, initValue) {
      this.data[key] = initValue;
    },
    updateFormValue: function (key, value) {
      this.data[key] = value;
    },
    hasErrors: function(){
      //https://stackoverflow.com/a/27709663/13886137
      for (var key in this.errors) {
        if (this.errors[key] !== null && this.errors[key] != ""){
          return true;
        }
      }
      return false;
    },
    resetErrors: function (key) {
      if (this.errors[key]) {
        this.errors[key] = null;
      }
    },
    setProps: function (flat, newVal) {
      for (var i in flat) {
        if (flat[i] === null){
          flat[i] = newVal;
        } else if (flat[i] instanceof File){
          flat[i] = newVal;
          this.$refs["input-component-for-"+i].value = newVal
        } else if (flat[i] instanceof Array) {
          if(flat[i][0] instanceof File){
            flat[i] = newVal
            this.$refs["input-component-for-"+i].value = newVal
          }
        } else if (typeof flat[i] === "object" && !(flat[i] instanceof Array)) {
          setProps(flat[i], newVal);
        } else {
          flat[i] = newVal;
        }
      }
    },
    initValues: function () {
      let self = this;
      let data = {};
      for (let key in self.$refs) {
        if (key.startsWith("input-component")) {
          self.$refs[key].initialize()
        }
        if (key.startsWith("textarea-component")) {
          self.$refs[key].initialize()
        }
        if (key.startsWith("select-component")) {
          self.$refs[key].initialize()
        }
        if (key.startsWith("radio-component")) {
          self.$refs[key].initialize()
        }
        if (key.startsWith("checkbox-component")) {
          self.$refs[key].initialize()
        }
      }
    },
    shouldResetFormOnSuccessfulSubmit() {
      const self = this;
      if (self.componentConfig["success"] != undefined && self.componentConfig["success"]["reset"] != undefined) {
        return self.componentConfig["success"]["reset"];
      } else {
        return self.shouldResetFormOnSuccessfulSubmitByDefault();
      }
    },
    shouldResetFormOnSuccessfulSubmitByDefault() {
      const self = this;
      if (self.componentConfig["method"] == "put") {
        return false;
      } else {
        return true;
      }
    },
    perform: function(){
      const self = this
      var form = self.$el.tagName == 'FORM' ? self.$el : self.$el.querySelector('form');
      if(form.checkValidity()){
        self.loading = true;
        if (self.componentConfig["emit"] != undefined) {
          matestackEventHub.$emit(self.componentConfig["emit"]);
        }
        if (self.componentConfig["delay"] != undefined) {
          setTimeout(function () {
            self.sendRequest()
          }, parseInt(self.componentConfig["delay"]));
        } else {
          self.sendRequest()
        }
      } else {
        matestackEventHub.$emit('static_form_errors');
      }
    },
    sendRequest: function(){
      const self = this;
      let payload = {};
      payload[self.componentConfig["for"]] = self.data;
      let axios_config = {};
      if (self.componentConfig["multipart"] == true ) {
        let form_data = new FormData();
        for (let key in self.data) {
          if (key.endsWith("[]")) {
            for (let i in self.data[key]) {
              let file = self.data[key][i];
              form_data.append(self.componentConfig["for"] + "[" + key.slice(0, -2) + "][]", file);
            }
          } else {
            if (self.data[key] != null){
              form_data.append(self.componentConfig["for"] + "[" + key + "]", self.data[key]);
            }
          }
        }
        axios_config = {
          method: self.componentConfig["method"],
          url: self.componentConfig["submit_path"],
          data: form_data,
          headers: {
            "X-CSRF-Token": document.getElementsByName("csrf-token")[0].getAttribute("content"),
            "Content-Type": "multipart/form-data",
          },
        };
      } else {
        axios_config = {
          method: self.componentConfig["method"],
          url: self.componentConfig["submit_path"],
          data: payload,
          headers: {
            "X-CSRF-Token": document.getElementsByName("csrf-token")[0].getAttribute("content"),
            "Content-Type": "application/json",
          },
        };
      }
      axios(axios_config)
        .then(function (response) {
          self.loading = false;
          if (self.componentConfig["success"] != undefined && self.componentConfig["success"]["emit"] != undefined) {
            matestackEventHub.$emit(self.componentConfig["success"]["emit"], response.data);
          }
          // transition handling
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
          // redirect handling
          if (self.componentConfig["success"] != undefined
            && self.componentConfig["success"]["redirect"] != undefined
            && (
              self.componentConfig["success"]["redirect"]["follow_response"] == undefined
              ||
              self.componentConfig["success"]["redirect"]["follow_response"] === false
            )
            && self.$store != undefined
          ) {
            let path = self.componentConfig["success"]["redirect"]["path"]
            window.location.href = path
            return;
          }
          if (self.componentConfig["success"] != undefined
            && self.componentConfig["success"]["redirect"] != undefined
            && self.componentConfig["success"]["redirect"]["follow_response"] === true
            && self.$store != undefined
          ) {
            let path = response.data["redirect_to"] || response.request.responseURL
            window.location.href = path
            return;
          }

          if (self.shouldResetFormOnSuccessfulSubmit())
          {
            self.setProps(self.data, null);
            self.initValues();
          }
        })
        .catch(function (error) {
          self.loading = false;
          if (error.response && error.response.data && error.response.data.errors) {
            self.errors = error.response.data.errors;
          }
          if (self.componentConfig["failure"] != undefined && self.componentConfig["failure"]["emit"] != undefined) {
            matestackEventHub.$emit(self.componentConfig["failure"]["emit"], error.response.data);
          }
          // transition handling
          if (self.componentConfig["failure"] != undefined
            && self.componentConfig["failure"]["transition"] != undefined
            && (
              self.componentConfig["failure"]["transition"]["follow_response"] == undefined
              ||
              self.componentConfig["failure"]["transition"]["follow_response"] === false
            )
            && self.$store != undefined
          ) {
            let path = self.componentConfig["failure"]["transition"]["path"]
            self.$store.dispatch('navigateTo', {url: path, backwards: false})
            return;
          }
          if (self.componentConfig["failure"] != undefined
            && self.componentConfig["failure"]["transition"] != undefined
            && self.componentConfig["failure"]["transition"]["follow_response"] === true
            && self.$store != undefined
          ) {
            let path = error.response.data["transition_to"] || response.request.responseURL
            self.$store.dispatch('navigateTo', {url: path, backwards: false})
            return;
          }
          // redirect handling
          if (self.componentConfig["failure"] != undefined
            && self.componentConfig["failure"]["redirect"] != undefined
            && (
              self.componentConfig["failure"]["redirect"]["follow_response"] == undefined
              ||
              self.componentConfig["failure"]["redirect"]["follow_response"] === false
            )
            && self.$store != undefined
          ) {
            let path = self.componentConfig["failure"]["redirect"]["path"]
            window.location.href = path
            return;
          }
          if (self.componentConfig["failure"] != undefined
            && self.componentConfig["failure"]["redirect"] != undefined
            && self.componentConfig["failure"]["redirect"]["follow_response"] === true
            && self.$store != undefined
          ) {
            let path = error.response.data["redirect_to"] || response.request.responseURL
            window.location.href = path
            return;
          }
        });
    },
  },
  mounted: function () {
    this.initValues();
  },
};

let component = Vue.component("matestack-ui-core-form", componentDef);

export default componentDef;
