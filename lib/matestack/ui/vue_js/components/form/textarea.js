import Vue from "vue/dist/vue.esm";

import formTextareaMixin from "./textarea_mixin";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin, formTextareaMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-textarea", componentDef);

export default componentDef;
