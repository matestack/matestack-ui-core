import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import componentMixin from 'component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncPageTemplate: state => state.pageTemplate,
  })
}

let component = Vue.component('matestack-ui-core-page-content', componentDef)

export default componentDef
