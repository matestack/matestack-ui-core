import formTextareaMixin from "./textarea_mixin";
import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin, formTextareaMixin],
  template: componentHelpers.inlineTemplate,
  data() {
    return {};
  }
}

export default componentDef;
