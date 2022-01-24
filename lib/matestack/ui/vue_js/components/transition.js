import matestackEventHub from '../event_hub'
import componentMixin from './mixin'
import componentHelpers from './helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function(){
    return {}
  },
  inject: [
    'appNavigateTo',
    'currentPathName',
    'setPageLoading',
    'pageLoading'
  ],
  computed: {
    isActive () {
      return (this.props["link_path"].split("?")[0]) === this.currentPathName
    },
    isChildActive () {
      return ((this.props["link_path"].split("?")[0]) !== this.currentPathName) && (this.currentPathName.indexOf(this.props["link_path"].split("?")[0]) !== -1)
    }
  },
  methods: {
    navigateTo: function(url){
      const self = this
      matestackEventHub.$emit("page_loading_triggered", url);
      this.setPageLoading(true)
      if (self.props["delay"] != undefined) {
        setTimeout(function () {
          self.performNavigation(url)
        }, parseInt(self.props["delay"]));
      } else {
        this.performNavigation(url)
      }
    },
    performNavigation: function(url){
      this.appNavigateTo({url: url, backwards: false})
    }
  }
}

export default componentDef
