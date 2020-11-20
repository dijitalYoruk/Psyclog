import axios, { URL } from '@/utils/AxiosConfig.js';

const state = {}

const mutations = {}

const actions = {
    banUserAsAdmin({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.post(URL.BAN_AS_ADMIN, payload, {
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }
            })
            .then(response => {
                resolve(response.data.data)
            })
            .catch(error => {
                reject(error.response.message)
                //window.console.log("error: " + error.message);
            });
        })
        
    },    
    removeBanFromPatient({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.delete(URL.REMOVE_BAN_FROM_PATIENT, {
                headers: {
                    'Authorization': `Bearer ${rootState.auth.accessToken}`,
                }, 
                data: payload
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
    updatePsychologistPenalty({ rootState }, payload) {
        return new Promise((resolve, reject) => {
            axios.post(URL.UPDATE_BAN_PENALTY, payload, {
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