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
    currentPath: state => state.currentPath
  }),
  mounted: function(){
    const self = this;
    window.onpopstate = (event) => {
      if (self.currentPath != document.location.pathname){
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
