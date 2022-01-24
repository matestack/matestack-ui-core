import matestackEventHub from '../event_hub'

const transitionHandlingMixin = {
  methods: {
    successTransitionHandling: function(response){
      const self = this
      if (self.props["success"] != undefined
        && self.props["success"]["transition"] != undefined
        && (
          self.props["success"]["transition"]["follow_response"] == undefined
          ||
          self.props["success"]["transition"]["follow_response"] === false
        )
        && self.appNavigateTo != undefined
      ) {
        let path = self.props["success"]["transition"]["path"]
        self.appNavigateTo({url: path, backwards: false})
        return;
      }
      if (self.props["success"] != undefined
        && self.props["success"]["transition"] != undefined
        && self.props["success"]["transition"]["follow_response"] === true
        && self.appNavigateTo != undefined
      ) {
        let path = response.data["transition_to"] || response.request.responseURL
        self.appNavigateTo({url: path, backwards: false})
        return;
      }
      // redirect handling
      if (self.props["success"] != undefined
        && self.props["success"]["redirect"] != undefined
        && (
          self.props["success"]["redirect"]["follow_response"] == undefined
          ||
          self.props["success"]["redirect"]["follow_response"] === false
        )
      ) {
        let path = self.props["success"]["redirect"]["path"]
        window.location.href = path
        return;
      }
      if (self.props["success"] != undefined
        && self.props["success"]["redirect"] != undefined
        && self.props["success"]["redirect"]["follow_response"] === true
      ) {
        let path = response.data["redirect_to"] || response.request.responseURL
        window.location.href = path
        return;
      }
    },
    failureTransitionHandling: function(error){
      const self = this
      if (self.props["failure"] != undefined
        && self.props["failure"]["transition"] != undefined
        && (
          self.props["failure"]["transition"]["follow_response"] == undefined
          ||
          self.props["failure"]["transition"]["follow_response"] === false
        )
        && self.appNavigateTo != undefined
      ) {
        let path = self.props["failure"]["transition"]["path"]
        self.appNavigateTo({url: path, backwards: false})
        return;
      }
      if (self.props["failure"] != undefined
        && self.props["failure"]["transition"] != undefined
        && self.props["failure"]["transition"]["follow_response"] === true
        && self.appNavigateTo != undefined
      ) {
        let path = error.response.data["transition_to"] || response.request.responseURL
        self.appNavigateTo({url: path, backwards: false})
        return;
      }
      // redirect handling
      if (self.props["failure"] != undefined
        && self.props["failure"]["redirect"] != undefined
        && (
          self.props["failure"]["redirect"]["follow_response"] == undefined
          ||
          self.props["failure"]["redirect"]["follow_response"] === false
        )
      ) {
        let path = self.props["failure"]["redirect"]["path"]
        window.location.href = path
        return;
      }
      if (self.props["failure"] != undefined
        && self.props["failure"]["redirect"] != undefined
        && self.props["failure"]["redirect"]["follow_response"] === true
      ) {
        let path = error.response.data["redirect_to"] || response.request.responseURL
        window.location.href = path
        return;
      }
    }
  }
}

export default transitionHandlingMixin
