import Vue from 'vue/dist/vue.esm'
import axios from 'axios'
import VRuntimeTemplate from "v-runtime-template"

import basemateEventHub from 'core/js/event-hub'

const componentMixin = {
  props: ['componentConfig', 'params'],
  data: function(){
    return {
      asyncTemplate: null
    }
  },
  methods: {
    onRerender: function(event){
      if (this.$el.id === event+"__wrapper"){
        this.rerender()
      }
    },
    onBasemateUiCoreChannel: function(event){
      if (this.componentConfig["rerender_on"] == event.message){
        this.rerender()
      }
    },
    rerender: function(){
      var self = this;
      self.params["component_key"] = self.componentConfig["component_key"]
      axios({
        method: "get",
        url: self.componentConfig["origin_url"],
        headers: {
          'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
        },
        params: self.params
      })
      .then(function(response){
        self.asyncTemplate = response["data"];
      })
    },
    rerenderWith: function(newParams){
      Object.assign(this.params, newParams);
      this.rerender()
    }
  },
  created: function () {
    const self = this
    basemateEventHub.$on('rerender', self.onRerender)
    basemateEventHub.$on('BasemateUiCoreChannel', self.onBasemateUiCoreChannel)
  },
  beforeDestroy: function() {
    const self = this
    basemateEventHub.$off('rerender', self.onRerender);
    basemateEventHub.$off('BasemateUiCoreChannel', self.onBasemateUiCoreChannel)
  },
  components: {
    VRuntimeTemplate: VRuntimeTemplate
  }
}

export default componentMixin
