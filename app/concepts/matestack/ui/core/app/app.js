import Vue from 'vue/dist/vue.esm'
import VRuntimeTemplate from "v-runtime-template"
import Vuex from 'vuex'

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
    window.onpopstate = (event) => {
      let needToNavigate = self.currentPathName !== document.location.pathname ||
        self.currentOrigin !== document.location.origin ||
        self.currentSearch !== document.location.search

      if (needToNavigate){
        self.$store.dispatch("navigateTo", {url: document.location.pathname, backwards: true} );
      }
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}



let component = Vue.component('matestack-ui-core-app', componentDef)

export default componentDef
