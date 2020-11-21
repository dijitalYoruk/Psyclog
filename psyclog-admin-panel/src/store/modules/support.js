import axios, { URL } from '@/utils/AxiosConfig.js';

const state = {
    allMessages: [],
    allMessagesCurrentPage: 1,
    allMessagesTotalPage: 0
}

const mutations = {
    retrieveAllMessages(state, payload) {
        state.allMessages = payload.docs;
        state.allMessagesCurrentPage = payload.page;
        state.allMessagesTotalPage = payload.totalPages;
    },
    clearAllMessages(state) {
        state.allMessages = [];
        state.allMessagesCurrentPage = 1;
        state.allMessagesTotalPage = 0;
    },
    deleteMessage(state, payload) {
        state.allMessages.splice(payload, 1);
    }
}

const actions = {
    retrieveAllSupportMessages({ commit, rootState }, payload) {
        axios.get(URL.RETRIEVE_SUPPORT_MESSAGES, {
            headers: {
                'Authorization': `Bearer ${rootState.auth.accessToken}`,
            },
            params: {
                page: payload.page, 
                status: payload.status,
                isHandled: payload.isHandled
            }
        })
        .then(response => {
            commit('retrieveAllMessages', response.data.data.supportMessages);
        })
        .catch(error => {
            if (error.response) {
                this.$toast.error(error.response.data.message);
            } else {
                this.$toast.error(this.$t('alert_error_server'));
            }
        });
    },
    deleteSupportMessage({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.delete(URL.DELETE_SUPPORT_MESSAGE, {
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
    handleSupportMessage({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.post(URL.HANDLE_SUPPORT_MESSAGE, payload, {
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
        })
        
    },   


    /*retrieveAllUnverifiedPsychologists({ commit, rootState }, payload) {
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
    }*/
}

const getters = {
    getAllSupportMessages(state) {
        return state.allMessages;
    },
    getAllSupportMessagesCurrentPage(state) {
        return state.allMessagesCurrentPage;
    },
    getAllSupportMessagesTotalPageCount(state) {
        return state.allMessagesTotalPage;
    }
}

export default {
    state,
    mutations,
    actions,
    getters
}