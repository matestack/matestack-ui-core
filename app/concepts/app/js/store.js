import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import axios from 'axios'

import basemateEventHub from 'core/js/event-hub'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    pageTemplate: null,
    currentPath: document.location.pathname
  },
  mutations: {
    setPageTemplate (state, serverResponse){
      state.pageTemplate = serverResponse
    },
    setCurrentPath (state, path){
      state.currentPath = path
    }
  },
  actions: {
    navigateTo ({ commit, state }, { url, backwards }) {
      basemateEventHub.$emit("page_loading", url);
      if (typeof basemateUiCoreTransitionStart !== 'undefined') {
        basemateUiCoreTransitionStart(url);
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
            window.history.replaceState({basemateApp: true, url: url}, null, url);
          } else {
            window.history.pushState({basemateApp: true, url: url}, null, url);
          }
          setTimeout(function () {
            resolve(response["data"])
            commit('setPageTemplate', response["data"])
            commit('setCurrentPath', url)
            basemateEventHub.$emit("page_loaded", url);
            if (typeof basemateUiCoreTransitionSuccess !== 'undefined') {
              basemateUiCoreTransitionSuccess(url);
            }
          }, 300);
        })
        .catch(function(error){
          setTimeout(function () {
            resolve(error)
            basemateEventHub.$emit("page_loading_error", error);
            if (typeof basemateUiCoreTransitionError !== 'undefined') {
              basemateUiCoreTransitionError(url);
            }
          }, 300);
        })
      })
    }
  }
})

export default store
