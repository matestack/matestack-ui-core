import matestackEventHub from '../event_hub'

const componentMixin = {
  props: ['props', 'params', 'matestack-ui-core-ref'],
  computed: {
    vc: function(){
      return this;
    }
  },
  methods: {
    getRefs: function(){
      // while working with vue.js 2.x, we used inline templates. $refs was working fine
      // from vue.js 3.x on, we cannot use inline tempates anymore but must use default slot instead
      // $refs is empty due to this migration
      // that's the reason for the following workaround
      var componentScopedRefs = {};
      var scopeId = this.props['component_uid'];
      var componentRelativeRefs = this.getElement().querySelectorAll("[matestack-ui-core-ref]")
      // var defaultSlot = this.$slots.default({ vc: this.vc })[0]
      // var globalRefs = defaultSlot.context.$refs
      for (let i in componentRelativeRefs) {
        let node = componentRelativeRefs[i]
        if (node.getAttribute){
          let nodeRef = node.getAttribute("matestack-ui-core-ref")
          if(nodeRef.startsWith(scopeId)){
            componentScopedRefs[nodeRef.replace(scopeId+"-", "")] = node
          }
        }

      }
      return componentScopedRefs;
    },
    getElement: function(){
      return document.getElementById("uid-"+this.props['component_uid']);
    },
    registerEvents: function(events, callback){
      if(events != undefined){
        var event_names = events.split(",")
        event_names.forEach(event_name => matestackEventHub.$on(event_name.trim(), callback));
      }
    },
    removeEvents: function(events, callback){
      if(events != undefined){
        var event_names = events.split(",")
        event_names.forEach(event_name => matestackEventHub.$off(event_name.trim(), callback));
      }
    },
    emitScopedEvent: function(name, data={}){
      matestackEventHub.$emit(this.props['component_uid']+"_"+name, data)
    },
    registerScopedEvent: function(name, callback, scopeId=this.props['component_uid']){
      matestackEventHub.$on(scopeId+"_"+name, callback)
    },
    removeScopedEvent: function(name, callback, scopeId=this.props['component_uid']){
      matestackEventHub.$off(scopeId+"_"+name, callback)
    },
    getXcsrfToken: function(){
      if(document.getElementsByName("csrf-token")[0]){
        return document.getElementsByName("csrf-token")[0].getAttribute("content")
      }
    }
  }

}

export default componentMixin
