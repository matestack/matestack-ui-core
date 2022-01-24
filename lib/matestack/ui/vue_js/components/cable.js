import matestackEventHub from '../event_hub'
import componentMixin from './mixin'
import componentHelpers from './helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  props: {
    initialTemplate: String,
  },
  data: function(){
    return {
      cableTemplate: null,
      cableTemplateDomElement: null,
      loading: false,
      event: {
        data: {}
      }
    }
  },
  methods: {
    append: function(payload){
      var html = this.formatPayload(payload)
      this.cableTemplateDomElement.insertAdjacentHTML(
        'beforeend',
        html.join('')
      )
      this.updateCableTemplate()
    },
    prepend: function(payload){
      var html = this.formatPayload(payload)
      this.cableTemplateDomElement.insertAdjacentHTML(
        'afterbegin',
        html.join('')
      )
      this.updateCableTemplate()
    },
    delete: function(payload){
      var ids = this.formatPayload(payload)
      ids.forEach(id =>
        this.cableTemplateDomElement.querySelector('#' + id).remove()
      )
      this.updateCableTemplate()
    },
    update: function(payload){
      const self = this
      var html = this.formatPayload(payload)
      html.forEach(function(elem){
        var dom_elem = document.createElement('div')
        dom_elem.innerHTML = elem.replace(/^\s+|\s+$/g, '')
        var id = dom_elem.firstChild.id
        var old_elem = self.cableTemplateDomElement.querySelector('#' + id)
        old_elem.parentNode.replaceChild(dom_elem.firstChild, old_elem)
      })
      this.updateCableTemplate()
    },
    replace: function(payload){
      var html = this.formatPayload(payload)
      this.cableTemplateDomElement.innerHTML = html.join('')
      this.updateCableTemplate()
    },
    updateCableTemplate: function(){
      this.cableTemplate = this.cableTemplateDomElement.outerHTML
    },
    formatPayload: function(payload){
      if(!Array.isArray(payload.data)){
        return [payload.data]
      }
      return payload.data
    },
  },
  mounted: function() {
    const self = this
    var dom_elem = document.createElement('div')
    dom_elem.innerHTML = this.initialTemplate
    this.cableTemplateDomElement = dom_elem.querySelector("#" + this.props["id"])
    this.cableTemplate = this.cableTemplateDomElement.outerHTML
    this.registerEvents(this.props['append_on'], self.append)
    this.registerEvents(this.props['prepend_on'], self.prepend)
    this.registerEvents(this.props['delete_on'], self.delete)
    this.registerEvents(this.props['update_on'], self.update)
    this.registerEvents(this.props['replace_on'], self.replace)
  },
  beforeUnmount: function() {
    const self = this
    this.cableTemplate = null
    this.removeEvents(this.props['append_on'], self.append)
    this.removeEvents(this.props['prepend_on'], self.prepend)
    this.removeEvents(this.props['delete_on'], self.delete)
    this.removeEvents(this.props['update_on'], self.update)
    this.removeEvents(this.props['replace_on'], self.replace)
  }
}


export default componentDef
