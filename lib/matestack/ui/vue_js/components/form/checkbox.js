import Vue from "vue";

import formCheckboxMixin from "./checkbox_mixin";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin, formCheckboxMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-checkbox", componentDef);

export default componentDef;
