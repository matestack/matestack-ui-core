// import componentMixin from './mixin'

const componentDef = {
  template: `<component :is="dynamicComponent" :vc="vc" :vue-component="vueComponent" :template="template" />`,
  props: ['vc', 'vueComponent', 'template'],
  computed: {
    dynamicComponent: function() {
      return {
        // mixins: [componentMixin],
        props: ['vc', 'vueComponent', 'template'],
        template: `${this.template || '<div></div>'}`,
      }
    }
  }
}

export default componentDef
