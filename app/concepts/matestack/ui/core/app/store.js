import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'
import matestackEventHub from '../js/event-hub'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    pageTemplate: null,
    currentPathName: document.location.pathname,
    currentSearch: document.location.search,
    currentOrigin: document.location.origin
  },
  mutations: {
    setPageTemplate (state, serverResponse){
      state.pageTemplate = serverResponse
    },
    setCurrentLocation (state, current){
      state.currentPathName = current.path
      state.currentSearch = current.search
      state.currentOrigin = current.origin
    },
    resetPageTemplate (state) {
      state.pageTemplate = null;
    }
  },
  actions: {
    navigateTo ({ commit, state }, { url, backwards }) {
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
            resolve(response["data"])
            commit('setPageTemplate', response["data"])
            commit('setCurrentLocation', { path: url, search: document.location.search, origin: document.location.origin })
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
