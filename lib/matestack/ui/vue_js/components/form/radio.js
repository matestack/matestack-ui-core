import Vue from "vue";

import formRadioMixin from "./radio_mixin";
import componentMixin from "../mixin";

const componentDef = {
  mixins: [componentMixin, formRadioMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-radio", componentDef);

export default componentDef;
