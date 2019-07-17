import Vue from 'vue/dist/vue.esm'

import matestackEventHub from 'js/event-hub'

import componentMixin from 'component/component'
import asyncMixin from 'async/async'

const componentDef = {
  mixins: [componentMixin, asyncMixin],
  data: function(){
    return {
      currentLimit: null,
      currentOffset: null,
      currentFilteredCount: null
    }
  },
  methods: {
    next: function(){
      if (this.currentTo() < this.currentFilteredCount){
        this.currentOffset += this.currentLimit
        var url = this.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
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
        var url = this.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
        window.history.pushState({matestackApp: true, url: url}, null, url);
        matestackEventHub.$emit(this.componentConfig["id"] + "-update")
      }
    },
    currentTo: function(){
      var to = parseInt(this.currentOffset) + parseInt(this.currentLimit)
      if (to > parseInt(this.currentFilteredCount)){
        return this.currentFilteredCount;
      } else {
        return to;
      }
    },
    goToPage: function(page){
      this.currentOffset = parseInt(this.currentLimit) * (parseInt(page)-1)
      var url = this.updateQueryParams(this.componentConfig["id"] + "-offset", this.currentOffset)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
    },
    updateQueryParams: function (key, value, url) {
        if (!url) url = window.location.href;
        var re = new RegExp("([?&])" + key + "=.*?(&|#|$)(.*)", "gi"),
            hash;

        if (re.test(url)) {
            if (typeof value !== 'undefined' && value !== null)
                return url.replace(re, '$1' + key + "=" + value + '$2$3');
            else {
                hash = url.split('#');
                url = hash[0].replace(re, '$1$3').replace(/(&|\?)$/, '');
                if (typeof hash[1] !== 'undefined' && hash[1] !== null)
                    url += '#' + hash[1];
                return url;
            }
        }
        else {
            if (typeof value !== 'undefined' && value !== null) {
                var separator = url.indexOf('?') !== -1 ? '&' : '?';
                hash = url.split('#');
                url = hash[0] + separator + key + '=' + value;
                if (typeof hash[1] !== 'undefined' && hash[1] !== null)
                    url += '#' + hash[1];
                return url;
            }
            else
                return url;
        }
    },
    getQueryParam: function (name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, '\\$&');
        var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }
  },
  beforeCreate: function() {
    if(this.$options.propsData.componentConfig["rerender_on"] == undefined){
      this.$options.propsData.componentConfig["rerender_on"] = this.$options.propsData.componentConfig["id"] + "-update"
    }
  },
  mounted: function(){
    if(this.getQueryParam(this.componentConfig["id"] + "-offset") != null){
        this.currentOffset = parseInt(this.getQueryParam(this.componentConfig["id"] + "-offset"))
    } else {
      if(this.componentConfig["init_offset"] != undefined){
        this.currentOffset = this.componentConfig["init_offset"]
      } else {
        this.currentOffset = 0
      }
    }

    if(this.getQueryParam(this.componentConfig["id"] + "-limit") != null){
        this.currentOffset = parseInt(this.getQueryParam(this.componentConfig["id"] + "-limit"))
    } else {
      if(this.componentConfig["init_limit"] != undefined){
        this.currentLimit = this.componentConfig["init_limit"]
      } else {
        this.currentLimit = 10
      }
    }

    if(this.componentConfig["filtered_count"] != undefined){
      this.currentFilteredCount = this.componentConfig["filtered_count"]
    }
  }
}

let component = Vue.component('matestack-ui-core-collection-content', componentDef)

export default componentDef
