import { computed } from "vue";
import axios from "axios";

import matestackEventHub from "../../event_hub";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function () {
    return {
      data: {},
      errors: {},
      isNestedForm: true,
      hideNestedForm: false,
      nestedFormRuntimeId: "",
      nestedFormServerErrorIndex: "",
    };
  },
  provide: function() {
    return {
      parentFormUid: computed(() => this.props["component_uid"]),
      parentFormData: computed(() => this.data),
      parentFormErrors: computed(() => this.errors),
      parentNestedFormRuntimeId: computed(() => this.nestedFormRuntimeId),
      parentFormMapToNestedForms: this.mapToNestedForms,
      parentFormSetErrors: this.setErrors,
      parentFormResetErrors: this.resetErrors,
    }
  },
  inject: [
    'parentFormData',
    'parentFormErrors',
    'parentNestedForms',
    'parentDeletedNestedForms',
    'parentFormMapToNestedForms'
  ],
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
      var serverErrorKey = this.props["fields_for"].replace("_attributes", "")+"["+this.nestedFormServerErrorIndex+"]."+key
      if (this.parentFormErrors[serverErrorKey]) {
        delete this.parentFormErrors[serverErrorKey];
      }
    },
    setErrors: function(errors){
      this.errors = errors;
    },
    setNestedFormServerErrorIndex: function(value){
      this.nestedFormServerErrorIndex = value;
    },
    setErrorKey: function(key, value){
      this.errors[key] = value;
    },
    flushErrors: function(key, value){
      this.errors = {};
    },
    removeItem: function(){
      this.data["_destroy"] = true
      this.hideNestedForm = true;
      var id = parseInt(this.nestedFormRuntimeId.replace("_"+this.props["fields_for"]+"_child_", ""));
      this.parentDeletedNestedForms[this.props["fields_for"]].push(id);
      var serverErrorKey = this.props["fields_for"].replace("_attributes", "")+"["+this.nestedFormServerErrorIndex+"]."
      var self = this;
      Object.keys(self.parentFormErrors).forEach(function(errorKey){
        if (errorKey.lastIndexOf(serverErrorKey, 0) == 0) {
          delete self.parentFormErrors[errorKey];
        }
      });
    },
    initValues: function () {
      this.emitScopedEvent("init") // received by child input components
    }
  },
  mounted: function () {
    var self = this;

    this.data = { "_destroy": false };

    //initialize nestedForm data in parent form if required
    if(this.parentFormData[this.props["fields_for"]] == undefined){
      this.parentFormData[this.props["fields_for"]] = [];
    }
    if(this.parentNestedForms[this.props["fields_for"]] == undefined){
      this.parentNestedForms[this.props["fields_for"]] = [];
    }
    if(this.parentDeletedNestedForms[this.props["fields_for"]] == undefined){
      this.parentDeletedNestedForms[this.props["fields_for"]] = [];
    }

    var id = parseInt(self.getElement().querySelector('.matestack-form-fields-for').id.replace(this.props["fields_for"]+"_child_", ""))

    //setup data binding for serverside rendered nested forms
    if (isNaN(id)){
      id = this.parentNestedForms[this.props["fields_for"]].length
      this.nestedFormRuntimeId = "_"+this.props["fields_for"]+"_child_"+id
      this.getElement().id = this.props["fields_for"]+"_child_"+id
      this.initValues()
      this.parentFormData[this.props["fields_for"]].push(this.data);
      this.parentNestedForms[this.props["fields_for"]].push(this);
    }

    //setup data binding for runtime nested forms (dynamic add via matestack-ui-core-runtime-render)
    if (!isNaN(id)){
      this.nestedFormRuntimeId = "_"+this.props["fields_for"]+"_child_"+id
      if(this.parentFormData[this.props["fields_for"]][id] == undefined){
        //new runtime form
        this.initValues()
        this.parentFormData[this.props["fields_for"]].push(this.data);
        this.parentNestedForms[this.props["fields_for"]].push(this);
      }else{
        //retreive state for existing runtime form (after remount for example)
        this.data = this.parentFormData[this.props["fields_for"]][id]
        if (this.data["_destroy"] == true){
          this.hideNestedForm = true;
        }
        this.parentNestedForms[this.props["fields_for"]][id] = this;
        Object.keys(this.parentFormErrors).forEach(function(errorKey){
          if (errorKey.includes(".")){
            let childErrorKey = errorKey.split(".")[1]
            let childModelName = errorKey.split(".")[0].split("[")[0]
            let childModelIndex = errorKey.split(".")[0].split("[")[1].split("]")[0]
            let mappedChildModelIndex = self.parentFormMapToNestedForms(parseInt(childModelIndex), childModelName+"_attributes")
            if(childModelName+"_attributes" == self.props["fields_for"] && mappedChildModelIndex == id){
              self.setNestedFormServerErrorIndex(parseInt(childModelIndex))
              self.setErrorKey(childErrorKey, self.parentFormErrors[errorKey])
            }
          }
        })
      }
    }
  }
};

export default componentDef;
