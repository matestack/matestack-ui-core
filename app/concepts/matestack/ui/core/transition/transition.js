import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import componentMixin from '../component/component'
import matestackEventHub from '../js/event-hub'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    isActive (state) {
      return this.componentConfig["link_path"] === state.currentPath
    }
  }),
  methods: {
    navigateTo: function(url){
      const self = this
      if (self.componentConfig["emit"] != undefined) {
        matestackEventHub.$emit(self.componentConfig["emit"]);
      }
      if (self.componentConfig["min_defer"] != undefined) {
        setTimeout(function () {
          self.performNavigation(url)
        }, parseInt(self.componentConfig["min_defer"]));
      } else {
        this.performNavigation(url)
      }
    },
    performNavigation: function(url){
      this.$store.dispatch('navigateTo', {url: url, backwards: false}).then((response) => {
        // self.asyncTemplate = response;
      })
    }
  }
}

let component = Vue.component('matestack-ui-core-transition', componentDef)

export default componentDef
