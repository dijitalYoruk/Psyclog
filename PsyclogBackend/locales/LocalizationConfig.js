const i18n = require("i18n");

const initLocalization = () => {
    i18n.configure({
        locales:['en'],
        directory: './locales',
        register: global
    })
}

module.exports = initLocalization