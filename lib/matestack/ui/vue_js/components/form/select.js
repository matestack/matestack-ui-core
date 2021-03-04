import Vue from "vue/dist/vue.esm";

import formSelectMixin from "./select_mixin";
import componentMixin from "../../../../../../app/concepts/matestack/ui/core/component/component";

const componentDef = {
  mixins: [componentMixin, formSelectMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-select", componentDef);

export default componentDef;
