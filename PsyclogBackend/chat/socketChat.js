const { io } = require('../index')
const {seeMessage, activateUser, retrievePreviousMessages, sendMessage, disconnect} = require('./helperChat')

const initChatSocket = () => {
    io.on('connection', socket => {
        console.log('New Socket Connection')
        socket.on('retrievePreviousMessages', retrievePreviousMessages(socket))
        socket.on('activateUser', activateUser(socket))
        socket.on('sendMessage', sendMessage(socket))
        socket.on('messageSeen', seeMessage(socket))   
        socket.on('disconnect', disconnect(socket))
    })
}

module.exports = {
    initChatSocket
}
