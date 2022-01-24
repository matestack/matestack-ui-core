import formSelectMixin from "./select_mixin";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin, formSelectMixin],
  template: componentHelpers.inlineTemplate,
  data() {
    return {};
  }
}

export default componentDef;
