import formInputMixin from "./input_mixin";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin, formInputMixin],
  template: componentHelpers.inlineTemplate,
  data() {
    return {};
  }
}

export default componentDef;
