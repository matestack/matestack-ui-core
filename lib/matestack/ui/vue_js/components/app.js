import { computed } from 'vue'
import axios from 'axios'

import matestackEventHub from '../event_hub'

import componentMixin from './mixin'
import componentHelpers from './helpers'

const componentDef = {
  mixins: [componentMixin],
  template: componentHelpers.inlineTemplate,
  props: ['appConfig', 'params'],
  data: function(){
    return {
      pageTemplate: null,
      pageLoading: false,
      currentPathName: document.location.pathname,
      currentSearch: document.location.search,
      currentOrigin: document.location.origin
    }
  },
  provide: function() {
    return {
      pageTemplate: computed(() => this.pageTemplate),
      pageLoading: computed(() => this.pageLoading),
      currentPathName: computed(() => this.currentPathName),
      currentSearch: computed(() => this.currentSearch),
      currentOrigin: computed(() => this.currentOrigin),
      appNavigateTo: this.navigateTo,
      setPageLoading: this.setPageLoading,
    }
  },
  mounted: function(){
    const self = this;
    window.addEventListener("popstate", (event) => {
      if (this.isNavigatingToAnotherPage({
          origin: self.currentOrigin,
          pathName: self.currentPathName,
          search: self.currentSearch
        }, document.location)){
          matestackEventHub.$emit("page_loading_triggered", document.location.pathname + document.location.search);
          self.pageLoading = true
          self.navigateTo({ url: document.location.pathname + document.location.search, backwards: true });
      }
    })
  },
  methods: {
    navigateTo ({url, backwards}) {
      const self = this
      self.pageLoading = true
      matestackEventHub.$emit("page_loading", url);
      if (!window.history.pushState) {
        document.location.href = url;
        return;
      }
      return new Promise((resolve, reject) => {
        axios({
          method: "get",
          url: url,
          headers: {
            'X-CSRF-Token': self.getXcsrfToken()
          },
          params: {"only_page": true}
        })
        .then(function(response){
          if (backwards){
            window.history.replaceState({matestackApp: true, url: url}, null, url);
          } else {
            window.history.pushState({matestackApp: true, url: url}, null, url);
          }
          setTimeout(function () {
            resolve(response["data"]);
            self.pageTemplate = response["data"]
            self.setCurrentLocation({ path: url.split("?")[0], search: document.location.search, origin: document.location.origin })
            self.pageLoading = false
            self.pageScrollTop()
            matestackEventHub.$emit("page_loaded", url);
          }, 5);
        })
        .catch(function(error){
          setTimeout(function () {
            resolve(error)
            matestackEventHub.$emit("page_loading_error", error);
          }, 5);
        })
      })
    },
    setPageLoading(bool){
      this.pageLoading = bool
    },
    setCurrentLocation (current){
      this.currentPathName = current.path
      this.currentSearch = current.search
      this.currentOrigin = current.origin
    },
    pageScrollTop () {
      //https://stackoverflow.com/a/35940276/13886137
      const getScrollParent = function(node) {
        if (node == null) {
          return null
        }
        if (node.scrollHeight > node.clientHeight) {
          return node
        } else {
          return getScrollParent(node.parentNode)
        }
      }
      var scrollParent = getScrollParent(document.getElementsByClassName("matestack-page-root")[0])
      if(scrollParent){
        scrollParent.scrollTop = 0;
      }
    },
    isNavigatingToAnotherPage(currentLocation, targetLocation) {
      // omits hash by design
      return currentLocation.pathName !== targetLocation.pathname ||
        currentLocation.origin !== targetLocation.origin ||
        currentLocation.search !== targetLocation.search
    }
  }
}

export default componentDef
