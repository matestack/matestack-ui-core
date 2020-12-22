import Vue from "vue/dist/vue.esm";

import formTextareaMixin from "./mixin";
import componentMixin from "../../component/component";

const componentDef = {
  mixins: [componentMixin, formTextareaMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-textarea", componentDef);

export default componentDef;
