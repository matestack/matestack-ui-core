import Vue from 'vue'
import Vuex from 'vuex'
import componentMixin from './mixin'
import matestackEventHub from '../event_hub'

const componentDef = {
  mixins: [componentMixin],
  data: function(){
    return {}
  },
  computed: Vuex.mapState({
    isActive (state) {
      return (this.props["link_path"].split("?")[0]) === state.currentPathName
    },
    isChildActive (state) {
      return ((this.props["link_path"].split("?")[0]) !== state.currentPathName) && (state.currentPathName.indexOf(this.props["link_path"].split("?")[0]) !== -1)
    }
  }),
  methods: {
    navigateTo: function(url){
      const self = this
      matestackEventHub.$emit("page_loading_triggered", url);
      this.$store.commit('setPageLoading', true);
      if (self.props["delay"] != undefined) {
        setTimeout(function () {
          self.performNavigation(url)
        }, parseInt(self.props["delay"]));
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
