import Vue from 'vue/dist/vue.esm'
import VRuntimeTemplate from "v-runtime-template"
import Vuex from 'vuex'
import isNavigatingToAnotherPage from "app/location"

const componentDef = {
  props: ['appConfig', 'params'],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncTemplate: state => state.pageTemplate,
  }),
  mounted: function(){
    window.onpopstate = (event) => {
      if (isNavigatingToAnotherPage(window.location, event)) {
        this.$store.dispatch("navigateTo", {url: document.location.pathname, backwards: true} );
      };
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-app', componentDef)

export default componentDef
