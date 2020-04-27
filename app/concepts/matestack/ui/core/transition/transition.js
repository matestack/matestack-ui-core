import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import componentMixin from '../component/component'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    isActive (state) {
      return (this.componentConfig["link_path"].split("?")[0]) === state.currentPathName
    },
    isChildActive (state) {
      return ((this.componentConfig["link_path"].split("?")[0]) !== state.currentPathName) && (state.currentPathName.indexOf(this.componentConfig["link_path"].split("?")[0]) !== -1)
    }
  }),
  methods: {
    navigateTo: function(url){
      this.$store.dispatch('navigateTo', {url: url, backwards: false}).then((response) => {
        // self.asyncTemplate = response;
      })
    }
  }
}

let component = Vue.component('matestack-ui-core-transition', componentDef)

export default componentDef
