import axios from "axios"

// constants
const BASE_URL = 'http://localhost:8080'
const CONTENT_TYPE = 'application/json'
const ACCEPTS = 'application/json'

const axiosInstance = axios.create({
    baseURL: `${BASE_URL}/api/v1`,
})

axiosInstance.defaults.headers.post['Content-Type'] = CONTENT_TYPE;
axiosInstance.defaults.headers.post['Accepts'] = ACCEPTS;


export default axiosInstance;