import Vue from 'vue'
import Vuex from 'vuex'
import axios from '@/AxiosConfig.js'
import io from "socket.io-client"

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    accessToken: localStorage.getItem('accessToken') || null,
    user: JSON.parse(localStorage.getItem('user')) || null,
    socket: undefined,
    chats: [],
    selectedChat: undefined
  },
  mutations: {
    setCurrentUser(state, payload) {
      state.user = payload.user
      state.accessToken = payload.token
      state.socket = io.connect("http://localhost:8080")
      localStorage.setItem('user', JSON.stringify(state.user));
      localStorage.setItem('accessToken', state.accessToken);
    },
    setChats(state, payload) {
      state.chats = payload
    },
    setSelectedChat(state, payload) {
      state.selectedChat = payload
    },
    connectSocket(state) {
      state.socket = io.connect("http://localhost:8080")
    },
    logOut(state) {
      state.user = undefined
      state.accessToken = undefined
      localStorage.removeItem('user')
      localStorage.removeItem('accessToken')
    }
  },
  actions: {
    signInUser({ commit }, payload) {
      return new Promise((resolve, reject) => {
          axios.post('auth/signIn', payload)
          .then(response => {
              const data = response.data.data
              commit('setCurrentUser', data)
              resolve(data)
          })
          .catch(error => {
              reject(error.response.data);
          });
      });
    }
  },
  getters: {
    getCurrentUser(state) {
      return state.user
    }, 
    getAccessToken(state) {
      return state.accessToken
    },
    getSocket(state) {
      return state.socket
    },
    getChats(state) {
      return state.chats
    },
    getSelectedChat(state) {
      return state.selectedChat
    },
    isAuthenticated(state) {
      return state.accessToken != undefined
    }
  },
  modules: {
  }
})
