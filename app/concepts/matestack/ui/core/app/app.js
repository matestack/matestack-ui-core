import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"
import Vuex from 'vuex'

const componentDef = {
  props: ['appConfig', 'params'],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncTemplate: state => state.pageTemplate,
  }),
  mounted: function(){
    const self = this;
    window.onpopstate = function(event) {
      self.$store.dispatch("navigateTo", {url: document.location.pathname, backwards: true} );
    }
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-app-cell', componentDef)

export default componentDef
