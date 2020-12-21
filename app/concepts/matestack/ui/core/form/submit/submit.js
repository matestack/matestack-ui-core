import Vue from "vue/dist/vue.esm";

import componentMixin from "../../component/component";

const componentDef = {
  mixins: [componentMixin],
  data() {
    return {};
  },
  methods: {
    loading: function(){
      return this.$parent.loading;
    }
  }
}

let component = Vue.component("matestack-ui-core-form-submit", componentDef);

export default componentDef;
