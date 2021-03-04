import Vue from "vue/dist/vue.esm";

import formTextareaMixin from "./textarea_mixin";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin, formTextareaMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-textarea", componentDef);

export default componentDef;
