import componentMixin from './mixin'
import componentHelpers from './helpers'

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
