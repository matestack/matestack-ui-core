import Vue from 'vue'
import Vuex from 'vuex'
import axios from 'axios'
import matestackEventHub from '../event_hub'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    pageTemplate: null,
    pageLoading: false,
    currentPathName: document.location.pathname,
    currentSearch: document.location.search,
    currentOrigin: document.location.origin
  },
  mutations: {
    setPageTemplate (state, serverResponse){
      state.pageTemplate = serverResponse
    },
    setPageLoading (state, boolean){
      state.pageLoading = boolean
    },
    setCurrentLocation (state, current){
      state.currentPathName = current.path
      state.currentSearch = current.search
      state.currentOrigin = current.origin
    },
    resetPageTemplate (state) {
      state.pageTemplate = null;
    },
    pageScrollTop (state) {
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
      // getScrollParent(document.getElementsByClassName("matestack-page-root")[0]).scrollTop = 0
    }
  },
  actions: {
    navigateTo ({ commit, state }, { url, backwards }) {
      const self = this
      commit('setPageLoading', true)
      matestackEventHub.$emit("page_loading", url);
      if (typeof matestackUiCoreTransitionStart !== 'undefined') {
        matestackUiCoreTransitionStart(url);
      }
      if (!window.history.pushState) {
        document.location.href = url;
        return;
      }
      return new Promise((resolve, reject) => {
        axios({
          method: "get",
          url: url,
          headers: {
            'X-CSRF-Token': document.getElementsByName("csrf-token")[0].getAttribute('content')
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
            commit('setPageTemplate', response["data"])
            commit('setCurrentLocation', { path: url.split("?")[0], search: document.location.search, origin: document.location.origin })
            commit('setPageLoading', false)
            commit('pageScrollTop')
            matestackEventHub.$emit("page_loaded", url);
            if (typeof matestackUiCoreTransitionSuccess !== 'undefined') {
              matestackUiCoreTransitionSuccess(url);
            }
          }, 5);
        })
        .catch(function(error){
          setTimeout(function () {
            resolve(error)
            matestackEventHub.$emit("page_loading_error", error);
            if (typeof matestackUiCoreTransitionError !== 'undefined') {
              matestackUiCoreTransitionError(url);
            }
          }, 5);
        })
      })
    }
  }
})

export default store
