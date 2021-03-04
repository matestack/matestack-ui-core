import Vue from "vue/dist/vue.esm";

import formRadioMixin from "./radio_mixin";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin, formRadioMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-radio", componentDef);

export default componentDef;
