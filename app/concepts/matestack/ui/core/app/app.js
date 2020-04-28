import Vue from 'vue/dist/vue.esm'
import VRuntimeTemplate from "v-runtime-template"
import Vuex from 'vuex'
import isNavigatingToAnotherPage from "./location"

const componentDef = {
  props: ['appConfig', 'params'],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncTemplate: state => state.pageTemplate,
    currentPathName: state => state.currentPathName,
    currentSearch: state => state.currentSearch,
    currentOrigin: state => state.currentOrigin,
  }),
  mounted: function(){
    const self = this;
    window.addEventListener("popstate", (event) => {
      if (isNavigatingToAnotherPage({
          origin: self.currentOrigin,
          pathName: self.currentPathName,
          search: self.currentSearch
        }, document.location)){
        self.$store.dispatch("navigateTo", { url: document.location.pathname + document.location.search, backwards: true } );
      }
    })
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}



let component = Vue.component('matestack-ui-core-app', componentDef)

export default componentDef
