import axios from "axios"

// constants
const BASE_URL = 'localhost:8080/'
const CONTENT_TYPE = 'application/json'
const CONTEXT_PATH = "api/v1"
const ACCEPTS = 'application/json'

const axiosInstance = axios.create({
    baseURL: `${BASE_URL}/${CONTEXT_PATH}/`,
})

axiosInstance.defaults.headers.post['Content-Type'] = CONTENT_TYPE;
axiosInstance.defaults.headers.post['Accepts'] = ACCEPTS;


export default axiosInstance;

export const URL = {
    SIGN_IN: 'auth/signIn',
    RESET_PASSWORD: 'auth/reset-password'
}