import Vue from "vue/dist/vue.esm";

import formCheckboxMixin from "./checkbox_mixin";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin, formCheckboxMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-checkbox", componentDef);

export default componentDef;
