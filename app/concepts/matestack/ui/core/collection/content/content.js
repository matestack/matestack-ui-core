import Vue from 'vue/dist/vue.esm'
import matestackEventHub from 'js/event-hub'
import queryParamsHelper from 'js/helpers/query-params-helper'
import componentMixin from 'component/component'
import asyncMixin from 'async/async'

const componentDef = {
  mixins: [componentMixin, asyncMixin],
  data: function(){
    return {
      currentLimit: null,
      currentOffset: null,
      currentFilteredCount: null,
      currentBaseCount: null
    }
  },
  methods: {
    next: function(){
      if (this.currentTo() < this.currentCount()){
        this.currentOffset += this.currentLimit
        var url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
        window.history.pushState({matestackApp: true, url: url}, null, url);
        matestackEventHub.$emit(this.componentConfig["id"] + "-update")
      }
    },
    previous: function(){
      if ((this.currentOffset - this.currentLimit)*-1 != this.currentLimit){
        if((this.currentOffset - this.currentLimit) < 0){
          this.currentOffset = 0
        } else {
          this.currentOffset -= this.currentLimit
        }
        var url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
        window.history.pushState({matestackApp: true, url: url}, null, url);
        matestackEventHub.$emit(this.componentConfig["id"] + "-update")
      }
    },
    currentTo: function(){
      var to = parseInt(this.currentOffset) + parseInt(this.currentLimit)
      if (to > parseInt(this.currentCount())){
        return this.currentCount();
      } else {
        return to;
      }
    },
    currentCount: function(){
      if (this.currentFilteredCount != null || this.currentFilteredCount != undefined){
        return this.currentFilteredCount;
      } else {
        return this.currentBaseCount;
      }
    },
    goToPage: function(page){
      this.currentOffset = parseInt(this.currentLimit) * (parseInt(page)-1)
      var url = queryParamsHelper.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    }
  },
  mounted: function(){
    if(queryParamsHelper.getQueryParam(this.componentConfig["id"] + "-offset") != null){
        this.currentOffset = parseInt(queryParamsHelper.getQueryParam(this.componentConfig["id"] + "-offset"))
    } else {
      if(this.componentConfig["init_offset"] != undefined){
        this.currentOffset = this.componentConfig["init_offset"]
      } else {
        this.currentOffset = 0
      }
    }

    if(queryParamsHelper.getQueryParam(this.componentConfig["id"] + "-limit") != null){
        this.currentOffset = parseInt(queryParamsHelper.getQueryParam(this.componentConfig["id"] + "-limit"))
    } else {
      if(this.componentConfig["init_limit"] != undefined){
        this.currentLimit = this.componentConfig["init_limit"]
      } else {
        this.currentLimit = 10
      }
    }

    if(this.componentConfig["filtered_count"] != undefined){
      this.currentFilteredCount = this.componentConfig["filtered_count"]
      if(this.currentOffset >= this.currentFilteredCount){
        this.previous()
      }
    }
    if(this.componentConfig["base_count"] != undefined){
      this.currentBaseCount = this.componentConfig["base_count"]
      if(this.currentOffset >= this.currentBaseCount){
        this.previous()
      }
    }
  }
}

let component = Vue.component('matestack-ui-core-collection-content', componentDef)

export default componentDef
