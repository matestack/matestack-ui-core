import Vue from "vue/dist/vue.esm";
import Vuex from "vuex";
import axios from "axios";

import matestackEventHub from "../../event_hub";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin],
  data: function () {
    return {
      data: {},
      errors: {},
      nestedForms: {},
      loading: false,
      isNestedForm: false,
      hideNestedForm: false,
      positionInNestedForm: 0
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
    setErrors: function(errors){
      this.errors = errors;
    },
    setErrorKey: function(key, value){
      Vue.set(this.errors, key, value);
    },
    setNestedFormsError: function(errors){
      let self = this;
      Object.keys(errors).forEach(function(errorKey){
        if (errorKey.includes(".")){
          let childErrorKey = errorKey.split(".")[1]
          let childModelName = errorKey.split(".")[0].split("[")[0]
          let childModelIndex = errorKey.split(".")[0].split("[")[1].split("]")[0]
          self.nestedForms[childModelName+"_attributes"][childModelIndex].setErrorKey(childErrorKey, errors[errorKey])
        }
      })
    },
    removeItem: function(){
      Vue.set(this.data, "_destroy", true)
      this.hideNestedForm = true;
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
        if (key.startsWith("matestack-form-fields-for")) {
          self.$refs[key].initializeNestedForm()
        }
      }
    },
    initializeNestedForm(){
      const self = this;
      self.isNestedForm = true;
      if (this.props["fields_for"] != undefined) {
        this.data = {}
        this.initValues()
        if(this.$parent.data[this.props["fields_for"]] == undefined){
          this.$parent.data[this.props["fields_for"]] = [];
        }
        this.$parent.data[this.props["fields_for"]].push(this.data);

        if(this.$parent.nestedForms[this.props["fields_for"]] == undefined){
          this.$parent.nestedForms[this.props["fields_for"]] = [];
        }
        let existingItemsCount = this.$parent.nestedForms[this.props["fields_for"]].length
        this.$parent.nestedForms[this.props["fields_for"]].push(this);
        this.positionInNestedForm = existingItemsCount

        //without the timeout it's somehow not working
        setTimeout(function () {
          self.$parent.$forceUpdate();
          self.$forceUpdate();
        }, 1);
      }
    },
    shouldResetFormOnSuccessfulSubmit() {
      const self = this;
      if (self.props["success"] != undefined && self.props["success"]["reset"] != undefined) {
        return self.props["success"]["reset"];
      } else {
        return self.shouldResetFormOnSuccessfulSubmitByDefault();
      }
    },
    shouldResetFormOnSuccessfulSubmitByDefault() {
      const self = this;
      if (self.props["method"] == "put") {
        return false;
      } else {
        return true;
      }
    },
    perform: function(){
      const self = this
      if (self.props["fields_for"] != null) {
        return;
      }
      var form = self.$el.tagName == 'FORM' ? self.$el : self.$el.querySelector('form');
      if(form.checkValidity()){
        self.loading = true;
        if (self.props["emit"] != undefined) {
          matestackEventHub.$emit(self.props["emit"]);
        }
        if (self.props["delay"] != undefined) {
          setTimeout(function () {
            self.sendRequest()
          }, parseInt(self.props["delay"]));
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
      payload[self.props["for"]] = self.data;
      let axios_config = {};
      if (self.props["multipart"] == true ) {
        let form_data = new FormData();
        for (let key in self.data) {
          if (key.endsWith("[]")) {
            for (let i in self.data[key]) {
              let file = self.data[key][i];
              form_data.append(self.props["for"] + "[" + key.slice(0, -2) + "][]", file);
            }
          } else {
            if (self.data[key] != null){
              form_data.append(self.props["for"] + "[" + key + "]", self.data[key]);
            }
          }
        }
        axios_config = {
          method: self.props["method"],
          url: self.props["submit_path"],
          data: form_data,
          headers: {
            "X-CSRF-Token": document.getElementsByName("csrf-token")[0].getAttribute("content"),
            "Content-Type": "multipart/form-data",
          },
        };
      } else {
        axios_config = {
          method: self.props["method"],
          url: self.props["submit_path"],
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

          if (self.shouldResetFormOnSuccessfulSubmit())
          {
            self.setProps(self.data, null);
            self.initValues();
          }
        })
        .catch(function (error) {
          self.loading = false;
          if (error.response && error.response.data && error.response.data.errors) {
            // self.errors = error.response.data.errors;
            self.setErrors(error.response.data.errors);
            self.setNestedFormsError(error.response.data.errors);
          }
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
        });
    },
  },
  mounted: function () {
    this.initValues();
  },
};

let component = Vue.component("matestack-ui-core-form", componentDef);

export default componentDef;
