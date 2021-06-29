import Vue from "vue/dist/vue.esm";
import Vuex from "vuex";
import VRuntimeTemplate from "v-runtime-template"

import axios from "axios";

import matestackEventHub from "../../event_hub";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin],
  data: function () {
    return {
      data: {},
      errors: {},
      loading: false,
      nestedForms: {},
      isNestedForm: false,
      hideNestedForm: false,
      nestedFormRuntimeTemplates: {},
      nestedFormRuntimeTemplateDomElements: {},
      deletedNestedForms: {},
      nestedFormRuntimeId: "",
      nestedFormServerErrorIndex: "",
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
        delete this.errors[key];
        Vue.set(this.errors);
      }
      if (this.isNestedForm){
        var serverErrorKey = this.props["fields_for"].replace("_attributes", "")+"["+this.nestedFormServerErrorIndex+"]."+key
        if (this.$parent.errors[serverErrorKey]) {
          delete this.$parent.errors[serverErrorKey];
          Vue.set(this.$parent.errors);
        }
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
    setNestedFormServerErrorIndex: function(value){
      this.nestedFormServerErrorIndex = value;
    },
    setErrorKey: function(key, value){
      Vue.set(this.errors, key, value);
    },
    flushErrors: function(key, value){
      this.errors = {};
    },
    setNestedFormsError: function(errors){
      let self = this;
      Object.keys(errors).forEach(function(errorKey){
        if (errorKey.includes(".")){
          let childErrorKey = errorKey.split(".")[1]
          let childModelName = errorKey.split(".")[0].split("[")[0]
          let childModelIndex = errorKey.split(".")[0].split("[")[1].split("]")[0]
          let mappedChildModelIndex = self.mapToNestedForms(parseInt(childModelIndex), childModelName+"_attributes")
          self.nestedForms[childModelName+"_attributes"][mappedChildModelIndex].setNestedFormServerErrorIndex(parseInt(childModelIndex))
          self.nestedForms[childModelName+"_attributes"][mappedChildModelIndex].setErrorKey(childErrorKey, errors[errorKey])
        }
      })
    },
    mapToNestedForms: function(serverIndex, nestedFormKey){
      var primaryKey;
      if(this.props["primary_key"] != undefined){
        primaryKey = this.props["primary_key"];
      }else{
        primaryKey = "id";
      }

      var formIdMap = []
      var childModelKey = 0;
      while(this.data[nestedFormKey].length > childModelKey){
        var ignore = this.data[nestedFormKey][childModelKey]["_destroy"] == true && this.data[nestedFormKey][childModelKey][primaryKey] == null
        if(!ignore){
          formIdMap.push(childModelKey)
        }
        childModelKey++;
      }

      return formIdMap[serverIndex];
    },
    resetNestedForms: function(){
      var self = this;
      Object.keys(self.nestedForms).forEach(function(childModelKey){
        self.nestedForms[childModelKey].forEach(function(nestedFormInstance){
          if(nestedFormInstance.data["_destroy"] == true){
            var destroyed = true;
          }
          nestedFormInstance.setProps(nestedFormInstance.data, null)
          nestedFormInstance.initValues()
          Vue.set(nestedFormInstance.data)
          if(destroyed){
            nestedFormInstance.hideNestedForm = true
            Vue.set(nestedFormInstance.data, "_destroy", true)
          }
        })
      })
    },
    removeItem: function(){
      Vue.set(this.data, "_destroy", true)
      this.hideNestedForm = true;
      var id = parseInt(this.nestedFormRuntimeId.replace("_"+this.props["fields_for"]+"_child_", ""));
      this.$parent.deletedNestedForms[this.props["fields_for"]].push(id);
      var serverErrorKey = this.props["fields_for"].replace("_attributes", "")+"["+this.nestedFormServerErrorIndex+"]."
      var self = this;
      Object.keys(self.$parent.errors).forEach(function(errorKey){
        if (errorKey.lastIndexOf(serverErrorKey, 0) == 0) {
          delete self.$parent.errors[errorKey];
          Vue.set(self.$parent.errors)
        }
      });
    },
    addItem: function(key){
      var templateString = JSON.parse(this.$el.querySelector('#prototype-template-for-'+key).dataset[":template"])
      if (this.nestedFormRuntimeTemplateDomElements[key] == null){
        var dom_elem = document.createElement('div')
        dom_elem.innerHTML = templateString
        var existingItemsCount;
        if (this.nestedForms[key] == undefined){
          existingItemsCount = 0
        }else{
          existingItemsCount = this.nestedForms[key].length
        }
        dom_elem.querySelector('.matestack-form-fields-for').id = key+"_child_"+existingItemsCount
        Vue.set(this.nestedFormRuntimeTemplateDomElements, key, dom_elem)
        Vue.set(this.nestedFormRuntimeTemplates, key, this.nestedFormRuntimeTemplateDomElements[key].outerHTML)
      }else{
        var dom_elem = document.createElement('div')
        dom_elem.innerHTML = templateString
        var existingItemsCount = this.nestedForms[key].length
        dom_elem.querySelector('.matestack-form-fields-for').id = key+"_child_"+existingItemsCount
        this.nestedFormRuntimeTemplateDomElements[key].insertAdjacentHTML(
          'beforeend',
          dom_elem.innerHTML
        )
        Vue.set(this.nestedFormRuntimeTemplates, key, this.nestedFormRuntimeTemplateDomElements[key].outerHTML)
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
    transformToFormData: function (formData, dataNode, parentKey=null) {
      var self = this;
      for (let key in dataNode) {
        if (key.endsWith("[]")) {
          for (let i in dataNode[key]) {
            let file = dataNode[key][i];
            if (parentKey != null) {
              formData.append(self.props["for"] + parentKey + "[" + key.slice(0, -2) + "][]", file);
            } else {
              formData.append(self.props["for"] + "[" + key.slice(0, -2) + "][]", file);
            }
          }
        } else {
          if (Array.isArray(dataNode[key])){
            dataNode[key].forEach(function(item, index){
              if (parentKey != null) {
                let _key = parentKey + "[" + key + "]" + "[]";
                formData = self.transformToFormData(formData, item, _key)
              } else {
                let _key = "[" + key + "]" + "[]";
                formData = self.transformToFormData(formData, item, _key)
              }
            })
          } else {
            if (dataNode[key] != null){
              if (parentKey != null) {
                formData.append(self.props["for"] + parentKey + "[" + key + "]", dataNode[key]);
              } else {
                formData.append(self.props["for"] + "[" + key + "]", dataNode[key]);
              }
            }
          }
        }
      }

      return formData;
    },
    sendRequest: function(){
      const self = this;
      let payload = {};
      payload[self.props["for"]] = self.data;
      let axios_config = {};
      if (self.props["multipart"] == true ) {
        let formData = new FormData();
        formData = this.transformToFormData(formData, this.data)
        axios_config = {
          method: self.props["method"],
          url: self.props["submit_path"],
          data: formData,
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

          self.flushErrors();

          if (self.shouldResetFormOnSuccessfulSubmit())
          {
            self.setProps(self.data, null);
            self.resetNestedForms();
            self.initValues();
          }
        })
        .catch(function (error) {
          self.loading = false;
          if (error.response && error.response.data && error.response.data.errors) {
            self.errors = error.response.data.errors;
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
    var self = this;
    if (this.props["fields_for"] != undefined) {
      this.isNestedForm = true;

      this.data = { "_destroy": false };

      //initialize nestedForm data in parent form if required
      if(this.$parent.data[this.props["fields_for"]] == undefined){
        this.$parent.data[this.props["fields_for"]] = [];
      }
      if(this.$parent.nestedForms[this.props["fields_for"]] == undefined){
        this.$parent.nestedForms[this.props["fields_for"]] = [];
      }
      if(this.$parent.deletedNestedForms[this.props["fields_for"]] == undefined){
        this.$parent.deletedNestedForms[this.props["fields_for"]] = []
      }

      var id = parseInt(self.$el.id.replace(this.props["fields_for"]+"_child_", ""));

      //setup data binding for serverside rendered nested forms
      if (isNaN(id)){
        id = this.$parent.nestedForms[this.props["fields_for"]].length
        this.nestedFormRuntimeId = "_"+this.props["fields_for"]+"_child_"+id
        this.$el.id = this.props["fields_for"]+"_child_"+id
        this.initValues()
        this.$parent.data[this.props["fields_for"]].push(this.data);
        this.$parent.nestedForms[this.props["fields_for"]].push(this);
      }

      //setup data binding for runtime nested forms (dynamic add via v-runtime-template)
      if (!isNaN(id)){
        this.nestedFormRuntimeId = "_"+this.props["fields_for"]+"_child_"+id
        if(this.$parent.data[this.props["fields_for"]][id] == undefined){
          //new runtime form
          this.initValues()
          this.$parent.data[this.props["fields_for"]].push(this.data);
          this.$parent.nestedForms[this.props["fields_for"]].push(this);
        }else{
          //retreive state for existing runtime form (after remount for example)
          this.data = this.$parent.data[this.props["fields_for"]][id]
          if (this.data["_destroy"] == true){
            this.hideNestedForm = true;
          }
          this.$parent.nestedForms[this.props["fields_for"]][id] = this;
          Object.keys(this.$parent.errors).forEach(function(errorKey){
            if (errorKey.includes(".")){
              let childErrorKey = errorKey.split(".")[1]
              let childModelName = errorKey.split(".")[0].split("[")[0]
              let childModelIndex = errorKey.split(".")[0].split("[")[1].split("]")[0]
              let mappedChildModelIndex = self.$parent.mapToNestedForms(parseInt(childModelIndex), childModelName+"_attributes")
              if(childModelName+"_attributes" == self.props["fields_for"] && mappedChildModelIndex == id){
                self.setNestedFormServerErrorIndex(parseInt(childModelIndex))
                self.setErrorKey(childErrorKey, self.$parent.errors[errorKey])
              }
            }
          })
        }
      }

      //without the timeout it's somehow not working
      setTimeout(function () {
        self.$parent.$forceUpdate();
        self.$forceUpdate();
      }, 1);
    } else {
      this.initValues();
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
};

let component = Vue.component("matestack-ui-core-form", componentDef);

export default componentDef;
