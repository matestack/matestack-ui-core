import formRadioMixin from "./radio_mixin";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin, formRadioMixin],
  template: componentHelpers.inlineTemplate,
  data() {
    return {};
  }
}

export default componentDef;
