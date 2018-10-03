import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"

const componentDef = {
  props: ['appConfig', 'params'],
  data: function(){
    return {
      asyncTemplate: null
    }
  },
  methods: {
    navigateTo: function(url, backwards){
      if (typeof basemateUiCoreTransitionStart !== 'undefined') {
        basemateUiCoreTransitionStart(url);
      }
      if (window.history.pushState) {
        if (backwards){
          window.history.replaceState({basemateApp: true, url: url}, null, url);
        } else {
          window.history.pushState({basemateApp: true, url: url}, null, url);
        }
      } else {
        document.location.href = url;
      }
      axios({
        method: "get",
        url: url,
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: {"only_page": true}
      })
      .then(function(response){
        setTimeout(function () {
          self.asyncTemplate = response["data"];
          if (typeof basemateUiCoreTransitionSuccess !== 'undefined') {
            basemateUiCoreTransitionSuccess(url);
          }
        }, 500);

      })
    }
  },
  mounted: function(){
    const self = this;
    window.onpopstate = function(event) {
      self.navigateTo(document.location.pathname, true);
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('app', componentDef)

export default componentDef
