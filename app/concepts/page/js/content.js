import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import componentMixin from 'component/js/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncPageTemplate: state => state.pageTemplate,
  })
}

let component = Vue.component('page-content-cell', componentDef)

export default componentDef
