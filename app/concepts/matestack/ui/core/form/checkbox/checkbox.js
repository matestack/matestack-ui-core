import Vue from "vue/dist/vue.esm";

import formCheckboxMixin from "./mixin";
import componentMixin from "../../component/component";

const componentDef = {
  mixins: [componentMixin, formCheckboxMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-checkbox", componentDef);

export default componentDef;
