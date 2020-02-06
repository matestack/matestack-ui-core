import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../../js/event-hub'
import queryParamsHelper from '../../js/helpers/query-params-helper'
import componentMixin from '../../component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      filter: {}
    }
  },
  methods: {
    submitFilter: function(){
      var url;
      var filter = this.filter
      for (var key in this.filter) {
        url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-filter-" + key, this.filter[key], url)
      }
      url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", 0, url)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    },
    resetFilter: function(){
      var url;
      for (var key in this.filter) {
        url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-filter-" + key, null, url)
        this.filter[key] = null;
        this.$forceUpdate();
      }
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    }
  },
  created: function(){
    var self = this;
    var queryParamsObject = queryParamsHelper.queryParamsToObject()
    Object.keys(queryParamsObject).forEach(function(key){
      if (key.startsWith(self.componentConfig["id"] + "-filter-")){
        self.filter[key.replace(self.componentConfig["id"] + "-filter-", "")] = queryParamsObject[key]
      }
    })
  }
}

let component = Vue.component('matestack-ui-core-collection-filter', componentDef)

export default componentDef
