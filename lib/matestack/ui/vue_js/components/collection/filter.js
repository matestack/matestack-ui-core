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
        if(this.data[key] != null){
          url = queryParamsHelper.updateQueryParams(this.props["id"] + "-filter-" + key, JSON.stringify(this.data[key]), url)
        }
      }
      url = queryParamsHelper.updateQueryParams(this.props["id"] + "-offset", 0, url)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.props["id"] + "-update")
    },
    resetFilter: function(){
      var url;
      for (var key in this.data) {
        url = queryParamsHelper.updateQueryParams(this.props["id"] + "-filter-" + key, null, url)
        this.data[key] = null;
      }
      this.initValues();
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.props["id"] + "-update")
    }
  },
  created: function(){
    var self = this;
    var queryParamsObject = queryParamsHelper.queryParamsToObject()
    Object.keys(queryParamsObject).forEach(function(key){
      if (key.startsWith(self.props["id"] + "-filter-")){
        self.data[key.replace(self.props["id"] + "-filter-", "")] = JSON.parse(queryParamsObject[key])
      }
    })
  }
}

let component = Vue.component('matestack-ui-core-collection-filter', componentDef)

export default componentDef
