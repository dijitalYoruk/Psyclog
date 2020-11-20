/* eslint-disable no-unused-vars */
import axios, { URL }  from '@/utils/AxiosConfig.js';

const state = {
    accessToken: localStorage.getItem('accessToken') || null,
    user: localStorage.getItem('user') || null,
}

const mutations = {
    setAccessToken(state, payload) {
        state.accessToken = payload;
    }, 
    signOut(state) {
        state.user = null
        state.accessToken = null
        localStorage.removeItem('user')
        localStorage.removeItem('accessToken')
    },
    setCurrentUser(state, payload) {
        state.user = payload;
        localStorage.setItem('user', JSON.stringify(state.user));
    },
    initialiseAuth(state) {
        if (state.user) {
            state.user = JSON.parse(state.user);
        }
    }
}

const actions = {
    signInUser({ commit }, payload) {
        return new Promise((resolve, reject) => {
            axios.post(URL.SIGN_IN, { 
                emailOrUsername: payload.usernameOrEmail, 
                password: payload.password
            })
            .then(response => {
                const data = response.data.data.user
                const accessToken = response.data.data.token
                const user = {
                    id: data._id,
                    name: data.name,
                    surname: data.surname,
                    username: data.username,
                    email: data.email,
                }
                
                localStorage.setItem('accessToken', accessToken);
                localStorage.setItem('user', JSON.stringify(user));
                commit('setAccessToken', accessToken);
                commit('setCurrentUser', user);
                resolve(response);
            })
            .catch(error => {
                if (error.response) {
                    reject(error.response.data.message);
                } else {
                    reject(this.$t('alert_error_server'));
                }
            });
        });
    },
    sendResetPasswordEmail({ commit }, payload) {
        return new Promise((resolve, reject) => {
            axios.post(URL.FORGOT_PASSWORD, payload)
            .then(response => {
                resolve(response);           
            })
            .catch(error => {
                if (error.response) {
                    reject(error.response.data.message);
                } else {
                    reject(this.$t('alert_error_server'));
                }        
            })  
        });
    }
}

const getters = {
    isUserSignedIn(state) {
        return state.accessToken !== null;
    },
    getCurrentUser(state) {
        return state.user;
    }
}

export default {
    state,
    mutations,
    actions,
    getters
}