import Vue from 'vue/dist/vue.esm'
import matestackEventHub from '../../event_hub'
import queryParamsHelper from '../../helpers/query_params_helper'
import componentMixin from '../mixin'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      ordering: {}
    }
  },
  methods: {
    toggleOrder: function(key){
      if (this.ordering[key] == undefined) {
        this.ordering[key] = "asc"
      } else if (this.ordering[key] == "asc") {
        this.ordering[key] = "desc"
      } else if (this.ordering[key] == "desc") {
        this.ordering[key] = undefined
      }
      var url;
      url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-order-" + key, this.ordering[key])
      url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", 0, url)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
      this.$forceUpdate()
    },
    orderIndicator(key, indicators){
      return indicators[this.ordering[key]]
    }
  },
  created: function(){
    var self = this;
    var queryParamsObject = queryParamsHelper.queryParamsToObject()
    Object.keys(queryParamsObject).forEach(function(key){
      if (key.startsWith(self.componentConfig["id"] + "-order-")){
        self.ordering[key.replace(self.componentConfig["id"] + "-order-", "")] = queryParamsObject[key]
      }
    })
  }
}

let component = Vue.component('matestack-ui-core-collection-order', componentDef)

export default componentDef
