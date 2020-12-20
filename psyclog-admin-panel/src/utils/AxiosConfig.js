import axios from "axios"

// constants
const BASE_URL = 'http://localhost:8080'
const CONTENT_TYPE = 'application/json'
const CONTEXT_PATH = "api/v1"
const ACCEPTS = 'application/json'

const axiosInstance = axios.create({
    baseURL: `${BASE_URL}/${CONTEXT_PATH}/`,
    responseType: 'json'
})

axiosInstance.defaults.headers.post['Content-Type'] = CONTENT_TYPE;
axiosInstance.defaults.headers.post['Accepts'] = ACCEPTS;

export default axiosInstance;

export const URL = {
    SIGN_IN: 'auth/signIn',
    FORGOT_PASSWORD: 'auth/forgotPassword',
    RETRIEVE_USERS: 'user',
    BAN_AS_ADMIN: "ban/as-admin",
    REMOVE_BAN_FROM_PATIENT: "ban",
    DELETE_USER: 'user',
    UPDATE_BAN_PENALTY: 'ban/penalty',
    RETRIEVE_UNVERIFIED_PSYCHOLOGISTS: 'user/psychologists/unverified',
    UPDATE_USER: 'user',
    RETRIEVE_SUPPORT_MESSAGES: 'support',
    DELETE_SUPPORT_MESSAGE: 'support',
    HANDLE_SUPPORT_MESSAGE: 'support/handle',
    VERIFY_USER: 'auth/verifyAsAdmin'
}