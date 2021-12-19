import Vue from "vue";

import formInputMixin from "./input_mixin";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin, formInputMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-input", componentDef);

export default componentDef;
