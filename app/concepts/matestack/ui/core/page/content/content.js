import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import componentMixin from '../../component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    asyncPageTemplate: state => state.pageTemplate,
    loading: state => state.pageLoading,
    loadingStart: state => state.pageLoadingStart,
    loadingEnd: state => state.pageLoadingEnd
  })
}

let component = Vue.component('matestack-ui-core-page-content', componentDef)

export default componentDef
