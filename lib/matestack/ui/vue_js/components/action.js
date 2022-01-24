import { inject } from 'vue'

import axios from 'axios'
import matestackEventHub from '../event_hub'
import componentMixin from './mixin'
import componentHelpers from './helpers'

import transitionHandlingMixin from './transition_handling_mixin'

const componentDef = {
  mixins: [componentMixin, transitionHandlingMixin],
  template: componentHelpers.inlineTemplate,
  data: function(){
    return {}
  },
  setup() {
    // conditionally inject appNavigateTo
    // action component has to work in context without wrapping app as well!
    const appNavigateTo = inject('appNavigateTo', undefined)
    return {
      appNavigateTo
    }
  },
  methods: {
    perform: function(){
      const self = this
      if (
        (self.props["confirm"] == undefined) || confirm(self.props["confirm_text"])
      )
      {
        if (self.props["emit"] != undefined) {
          matestackEventHub.$emit(self.props["emit"]);
        }
        if (self.props["delay"] != undefined) {
          setTimeout(function () {
            self.sendRequest()
          }, parseInt(self.props["delay"]));
        } else {
          this.sendRequest()
        }
      }
    },
    sendRequest: function(){
      const self = this
      axios({
          method: self.props["method"],
          url: self.props["action_path"],
          data: self.props["data"],
          headers: {
            'X-CSRF-Token': self.getXcsrfToken()
          }
        }
      )
      .then(function(response){
        if (self.props["success"] != undefined && self.props["success"]["emit"] != undefined) {
          matestackEventHub.$emit(self.props["success"]["emit"], response.data);
        }
        self.successTransitionHandling(response)
      })
      .catch(function(error){
        if (self.props["failure"] != undefined && self.props["failure"]["emit"] != undefined) {
          matestackEventHub.$emit(self.props["failure"]["emit"], error.response.data);
        }
        self.failureTransitionHandling(error)
      })
    }
  }
}

export default componentDef
