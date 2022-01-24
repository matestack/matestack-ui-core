import matestackEventHub from '../event_hub'
import componentMixin from './mixin'
import componentHelpers from './helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function(){
    return { }
  },
  methods: {
    perform: function(){
      matestackEventHub.$emit(this.props["emit"], this.props["data"])
    }
  }
}

export default componentDef
