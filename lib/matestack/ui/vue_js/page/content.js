import Vue from 'vue'
import Vuex from 'vuex'
import componentMixin from '../components/mixin'

import VRuntimeTemplate from "vue3-runtime-template"

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncPageTemplate: state => state.pageTemplate,
    loading: state => state.pageLoading
  }),
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

let component = Vue.component('matestack-ui-core-page-content', componentDef)

export default componentDef
