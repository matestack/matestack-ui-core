import Vue from "vue/dist/vue.esm";

import formRadioMixin from "./mixin";
import componentMixin from "../../component/component";

const componentDef = {
  mixins: [componentMixin, formRadioMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-radio", componentDef);

export default componentDef;
