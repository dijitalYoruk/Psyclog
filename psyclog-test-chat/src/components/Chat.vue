<template>
    <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card class="pa-4 mt-5">
        <div v-if="contactStatus">Online</div>
        <v-text-field outlined v-model="message"></v-text-field>
        <v-btn color="red" @click="sendMessage()">Send</v-btn>
        <v-btn color="blue" @click="retrievePreviousMessages()">Retrieve Prev Message</v-btn>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { mapGetters } from "vuex";

export default {
    created() {
        if (this.selectedChat === undefined) {
            this.$router.push({ name: 'UserList' })
        } 

        this.socket.off()
        this.socket.on('message', message => {
            window.console.log(message)
            this.signalLastMessageSeen(message)
        })

        this.socket.on('previousMessages', messages => {
            window.console.log(messages)
        })

        const role = this.currentUser.role

        if (role == 'user') {
            this.contactStatus = this.selectedChat.psychologist.isActive
            this.socket.on(this.selectedChat.psychologist._id, status => {
                this.selectedChat.psychologist.isActive = status
                this.contactStatus = status
            })
        } 
        else if (role == 'role_psychologist') {
            this.contactStatus = this.selectedChat.patient.isActive
            this.socket.on(this.selectedChat.patient._id, status => {
                this.selectedChat.patient.isActive = status 
                this.contactStatus = status
            })
        }


        this.retrievePreviousMessages()
        const lastMessage = this.selectedChat.lastMessage
        this.signalLastMessageSeen(lastMessage)        
    },
    data() {
        return {
            message: '',
            page: 1,
            contactStatus: false
        }
    },
    computed: {
        ...mapGetters({
            currentUser: 'getCurrentUser',
            accessToken: 'getAccessToken',
            socket: 'getSocket',
            selectedChat: 'getSelectedChat'
        })
    },
    methods: {
        sendMessage() {
            const accessToken = this.accessToken
            const message = this.message
            const chat = this.selectedChat._id
            this.socket.emit('sendMessage', { accessToken, message, chat })
            this.message = ''
        },
        retrievePreviousMessages() {
            const accessToken = this.accessToken
            const chat = this.selectedChat._id
            const page = this.page
            this.page++

            this.socket.emit('retrievePreviousMessages', {
                accessToken, chat, page
            })
        },
        signalLastMessageSeen(message) {
            if (this.selectedChat.lastMessage.author === this.currentUser._id) return
            console.log('passes')
            const accessToken = this.accessToken
            const chat = this.selectedChat._id
            this.selectedChat.lastMessage = message
            this.selectedChat.isLastMessageSeen = true
            this.socket.emit('messageSeen', { chat, accessToken })    
        }
    }
}
</script>

<style>

</style>