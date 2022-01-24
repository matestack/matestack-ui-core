import formCheckboxMixin from "./checkbox_mixin";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin, formCheckboxMixin],
  template: componentHelpers.inlineTemplate,
  data() {
    return {};
  }
}

export default componentDef;
