// import componentMixin from './mixin'

const componentDef = {
  template: `<component :is="dynamicComponent" :vc="vc" :template="template" />`,
  props: ['vc', 'template'],
  computed: {
    dynamicComponent: function() {
      return {
        // mixins: [componentMixin],
        props: ['vc', 'template'],
        template: `${this.template || '<div></div>'}`,
      }
    }
  }
}

export default componentDef
