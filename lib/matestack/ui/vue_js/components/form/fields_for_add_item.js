import componentMixin from "../mixin";
import componentHelpers from "../helpers";

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  data: function () {
    return {};
  },
  inject: [
    'parentNestedFormRuntimeTemplates',
    'parentNestedFormRuntimeTemplateDomElements',
    'parentNestedForms'
  ],
  methods: {
    addItem: function(key){
      var templateString = JSON.parse(this.getElement().querySelector('#prototype-template-for-'+key).dataset[":template"])
      var tmp_dom_elem = document.createElement('div')
      tmp_dom_elem.innerHTML = templateString
      var static_prototype_template_uid = tmp_dom_elem.querySelector('matestack-component-template').id.replace("uid-", "")
      var dynamic_prototype_template_uid = Math.floor(Math.random() * 1000000000);
      var templateString = templateString.replaceAll(static_prototype_template_uid, dynamic_prototype_template_uid);
      if (this.parentNestedFormRuntimeTemplateDomElements[key] == null){
        var dom_elem = document.createElement('div')
        dom_elem.innerHTML = templateString
        var existingItemsCount;
        if (this.parentNestedForms[key] == undefined){
          existingItemsCount = 0
        }else{
          existingItemsCount = this.parentNestedForms[key].length
        }
        dom_elem.querySelector('.matestack-form-fields-for').id = key+"_child_"+existingItemsCount
        this.parentNestedFormRuntimeTemplateDomElements[key] = dom_elem
        this.parentNestedFormRuntimeTemplates[key] = this.parentNestedFormRuntimeTemplateDomElements[key].outerHTML
      }else{
        var dom_elem = document.createElement('div')
        dom_elem.innerHTML = templateString
        var existingItemsCount = this.parentNestedForms[key].length
        dom_elem.querySelector('.matestack-form-fields-for').id = key+"_child_"+existingItemsCount
        this.parentNestedFormRuntimeTemplateDomElements[key].insertAdjacentHTML(
          'beforeend',
          dom_elem.innerHTML
        )
        this.parentNestedFormRuntimeTemplates[key] = this.parentNestedFormRuntimeTemplateDomElements[key].outerHTML
      }
    }
  }
};

export default componentDef;
