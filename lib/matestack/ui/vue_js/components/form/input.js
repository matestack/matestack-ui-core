import Vue from "vue/dist/vue.esm";

import formInputMixin from "./input_mixin";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin, formInputMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-input", componentDef);

export default componentDef;
