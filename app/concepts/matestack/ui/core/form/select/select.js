import Vue from "vue/dist/vue.esm";

import formSelectMixin from "./mixin";
import componentMixin from "../../component/component";

const componentDef = {
  mixins: [componentMixin, formSelectMixin],
  data() {
    return {};
  }
}

let component = Vue.component("matestack-ui-core-form-select", componentDef);

export default componentDef;
