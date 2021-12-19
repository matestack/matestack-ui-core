import Vue from "vue";

import formSelectMixin from "./select_mixin";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin, formSelectMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-select", componentDef);

export default componentDef;
