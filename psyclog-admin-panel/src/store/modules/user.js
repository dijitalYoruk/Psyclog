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
    updateUser({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.patch(URL.UPDATE_USER, payload, {
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
    verifyUser({ rootState }, payload) {
        console.log(payload)
        return new Promise((resolve, reject) => {
            axios.post(URL.VERIFY_USER, payload, {
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
    }
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