import Vue from 'vue/dist/vue.esm'

import matestackEventHub from 'js/event-hub'

import componentMixin from 'component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {
      ordering: {}
    }
  },
  methods: {
    toggelOrder: function(key){
      if (this.ordering[key] == undefined) {
        this.ordering[key] = "asc"
      } else if (this.ordering[key] == "asc") {
        this.ordering[key] = "desc"
      } else if (this.ordering[key] = "desc") {
        this.ordering[key] = undefined
      }
      var url;
      url = this.updateQueryParams(this.componentConfig["id"] + "-order-" + key, this.ordering[key])
      url = this.updateQueryParams(this.componentConfig["id"] + "-offset", 0, url)
      window.history.pushState({matestackApp: true, url: url}, null, url);
      matestackEventHub.$emit(this.componentConfig["id"] + "-update")
      this.$forceUpdate()
    },
    orderIndicator(key, indicators){
      return indicators[this.ordering[key]]
    },
    resetFilter: function(){
      var url;
      for (var key in this.filter) {
        url = this.updateQueryParams(this.componentConfig["id"] + "-filter-" + key, null)
        this.filter[key] = null;
        this.$forceUpdate();
      }
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
    },
    queryParamsToObject: function(){
      var search = window.location.search.substring(1);
      if(search.length === 0){
        return {}
      } else {
        var result = JSON.parse(
          '{"' + search.replace(/&/g, '","').replace(/=/g,'":"') + '"}',
          function(key, value) { return key===""?value:decodeURIComponent(value) }
        )
        return result;
      }
    }
  },
  created: function(){
    var self = this;
    var queryParamsObject = this.queryParamsToObject()
    Object.keys(queryParamsObject).forEach(function(key){
      if (key.startsWith(self.componentConfig["id"] + "-order-")){
        self.ordering[key.replace(self.componentConfig["id"] + "-order-", "")] = queryParamsObject[key]
      }
    })
  }
}

let component = Vue.component('matestack-ui-core-collection-order', componentDef)

export default componentDef
