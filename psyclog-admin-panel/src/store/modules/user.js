import axios, { URL } from '@/utils/AxiosConfig.js';

const state = {
    allUsers: [],
    allUsersCurrentPage: 1,
    allUsersTotalPage: 0
}

const mutations = {
    retrieveAllUsers(state, payload) {
        state.allUsers = payload.docs;
        state.allUsersCurrentPage = payload.page;
        state.allUsersTotalPage = payload.totalPages;
    },
    clearAllUsers(state) {
        state.allUsers = [];
        state.allUsersCurrentPage = 1;
        state.allUsersTotalPage = 0;
    },
    deleteUser(state, payload) {
        state.allUsers.splice(payload, 1);
    }
}

const actions = {
    retrieveAllUsers({ commit, rootState }, payload) {
        axios.get(URL.RETRIEVE_USERS, {
            headers: {
                'Authorization': `Bearer ${rootState.auth.accessToken}`,
            },
            params: {
                page: payload.page, 
                role: payload.role,
                search: payload.search
            }
        })
        .then(response => {
            commit('retrieveAllUsers', response.data.data.users);
        })
        .catch(error => {
            if (error.response) {
                this.$toast.error(error.response.data.message);
            } else {
                this.$toast.error(this.$t('alert_error_server'));
            }
        });
    },
    retrieveAllUnverifiedPsychologists({ commit, rootState }, payload) {
        axios.get(URL.RETRIEVE_UNVERIFIED_PSYCHOLOGISTS, {
            headers: {
                'Authorization': `Bearer ${rootState.auth.accessToken}`,
            },
            params: {
                page: payload.page, 
                search: payload.search
            }
        })
        .then(response => {
            commit('retrieveAllUsers', response.data.data.psychologists);
        })
        .catch(error => {
            if (error.response) {
                this.$toast.error(error.response.data.message);
            } else {
                this.$toast.error(this.$t('alert_error_server'));
            }
        });
    },
    deleteUser({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.delete(URL.DELETE_USER, {
                data: payload, 
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }
            })
            .then(response => {
                resolve(response.data.data)
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







/*
    retrieveUser({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.get(URL.SHOW_USER_DETAIL, {
                data: payload,
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }
            })
            .then(response => {
                resolve(response.data.data);
            })
            .catch(error => {
                reject(error.response.data);
            });
        });
    },
    updateUser({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.put(URL.UPDATE_USER, payload, {
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }
            })
            .then(response => {
                resolve(response.data)
            })
            .catch(error => {
                reject(error.response.data)
            });
        });
    },*/
  /*  deleteUser({ rootState, dispatch, commit }, payload) {
        const data = {'uuid' :payload.uuid}

        return new Promise((resolve, reject) => {
            axios.delete(URL.DELETE_USER, {
                data, 
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }
            })
            .then(response => {
                let page = payload.page;

                if (page == state.allUsersTotalPage && state.allUsers.length == 1 && page > 1) { 
                    payload.page--
                    dispatch('retrieveAllUsers', payload)
                }
                else if (page == state.allUsersTotalPage && state.allUsers.length == 1 && page == 1) { 
                    commit('clearAllUsers') 
                }
                else {
                    dispatch('retrieveAllUsers', payload)
                } 

                resolve(response.data)
            })
            .catch(error => {
                reject(error.response.data)
            });
        });
    }*/
}

const getters = {
    getAllUsers(state) {
        return state.allUsers;
    },
    getAllUsersCurrentPage(state) {
        return state.allUsersCurrentPage;
    },
    getAllUsersTotalPage(state) {
        return state.allUsersTotalPage;
    }
}

export default {
    state,
    mutations,
    actions,
    getters
}