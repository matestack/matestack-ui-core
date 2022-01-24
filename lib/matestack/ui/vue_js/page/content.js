import componentMixin from '../components/mixin'
import componentHelpers from '../components/helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function(){
    return {}
  },
  inject: [
    'pageTemplate',
    'pageLoading'
  ],
  computed: {
    asyncPageTemplate: function(){
      return this.pageTemplate
    },
    loading: function(){
      return this.pageLoading
    }
  }
}

export default componentDef
