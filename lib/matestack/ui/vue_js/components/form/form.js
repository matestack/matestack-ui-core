import { inject, computed } from "vue";
import axios from "axios";

import matestackEventHub from "../../event_hub";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

import transitionHandlingMixin from '../transition_handling_mixin'

const componentDef = {
  mixins: [componentMixin, transitionHandlingMixin],
  template: componentHelpers.inlineTemplate,
  data: function () {
    return {
      data: {},
      errors: {},
      loading: false,
      isNestedForm: false,
      nestedForms: {},
      nestedFormRuntimeTemplates: {},
      nestedFormRuntimeTemplateDomElements: {},
      deletedNestedForms: {}
    };
  },
  setup() {
    // conditionally inject appNavigateTo
    // form component has to work in context without wrapping app as well!
    const appNavigateTo = inject('appNavigateTo', undefined)
    return {
      appNavigateTo
    }
  },
  provide: function() {
    return {
      parentFormUid: computed(() => this.props["component_uid"]),
      parentFormData: computed(() => this.data),
      parentFormErrors: computed(() => this.errors),
      parentFormLoading: computed(() => this.loading),
      parentNestedForms: computed(() => this.nestedForms),
      parentDeletedNestedForms: computed(() => this.deletedNestedForms),
      parentNestedFormRuntimeTemplates: computed(() => this.nestedFormRuntimeTemplates),
      parentNestedFormRuntimeTemplateDomElements: computed(() => this.nestedFormRuntimeTemplateDomElements),
      parentFormMapToNestedForms: this.mapToNestedForms,
      parentFormSetErrors: this.setErrors,
      parentFormResetErrors: this.resetErrors,
      parentFormIsNestedForm: this.isNestedForm, // need to provide this value for input components working both in form and nested form contexts
      parentNestedFormRuntimeId: null, // need to provide this value for input components working both in form and nested form contexts
    }
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
      }
    },
    setErrors: function(errors){
      this.errors = errors;
    },
    setErrorKey: function(key, value){
      this.errors[key] = value;
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
          nestedFormInstance.initValues()
          if(destroyed){
            nestedFormInstance.hideNestedForm = true
            nestedFormInstance.data["_destroy"] = true
          }
        })
      })
    },
    initValues: function () {
      this.emitScopedEvent("init") // received by child input components
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

      var form = this.getRefs()["form"]

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
            "X-CSRF-Token": self.getXcsrfToken(),
            "Content-Type": "multipart/form-data",
          },
        };
      } else {
        axios_config = {
          method: self.props["method"],
          url: self.props["submit_path"],
          data: payload,
          headers: {
            "X-CSRF-Token": self.getXcsrfToken(),
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

          self.successTransitionHandling(response)
          self.flushErrors();

          if (self.shouldResetFormOnSuccessfulSubmit())
          {
            self.initValues();
            self.resetNestedForms();
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

          self.failureTransitionHandling(error)
        });
    },
  },
  mounted: function () {
    this.initValues();
  }

};

export default componentDef;
