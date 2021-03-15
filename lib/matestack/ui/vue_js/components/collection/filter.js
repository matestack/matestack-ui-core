import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../../event_hub'
import queryParamsHelper from '../../helpers/query_params_helper'

import formMixin from '../form/form'

const componentDef = {
  mixins: [formMixin],
  methods: {
    perform: function(){
      var url;
      var filter = this.data
      for (var key in this.data) {
        url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-filter-" + key, JSON.stringify(this.data[key]), url)
      }
      url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", 0, url)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    },
    resetFilter: function(){
      var url;
      for (var key in this.data) {
        url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-filter-" + key, null, url)
        this.data[key] = null;
        this.$forceUpdate();
      }
      this.initValues();
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    }
  },
  created: function(){
    var self = this;
    var queryParamsObject = queryParamsHelper.queryParamsToObject()
    Object.keys(queryParamsObject).forEach(function(key){
      if (key.startsWith(self.componentConfig["id"] + "-filter-")){
        self.data[key.replace(self.componentConfig["id"] + "-filter-", "")] = queryParamsObject[key]
      }
    })
  }
}

let component = Vue.component('matestack-ui-core-collection-filter', componentDef)

export default componentDef
