<template>
    <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card outlined class="pa-4 mt-5 elevation-3">

        <div v-for="msg in messages" :key="msg.id">
            <strong>Author: </strong>{{ msg.author.name }}
            <div>
                <strong>Message:</strong> {{ msg.message }}
            </div>
            <div>
                <strong>Date:</strong> {{ msg.createdAt }}
            </div>
            <div v-if="msg.author._id == currentUser._id">
                <strong>Contact Seen:</strong> {{ msg.isSeen }}
            </div>
            <v-divider></v-divider>
        </div>
        <div v-if="contactStatus">Online</div>
        <v-text-field outlined v-model="message"></v-text-field>
        <v-btn color="red" @click="sendMessage()">Send</v-btn>
        <v-btn color="blue" class="mx-2" @click="retrievePreviousMessages()">Retrieve Prev Message</v-btn>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
import { mapGetters } from "vuex";
import moment from 'moment';

export default {
    created() {
        if (this.selectedChat === undefined) {
            this.$router.push({ name: 'UserList' })
        } 

        this.socket.off()
        const role = this.currentUser.role

        this.socket.on('message', message => {
            this.skip++
            this.messages.push(message)
            this.selectedChat.lastMessage = message 
            this.signalLastMessageSeen(message)
        })

        this.socket.on('previousMessages', messages => {
            this.skip += messages.length
            this.messages.unshift(...messages.reverse())
        })

        if (role == 'user') {
            this.contactStatus = this.selectedChat.psychologist.isActive
            this.socket.on(this.selectedChat.psychologist._id, status => {
                this.selectedChat.psychologist.isActive = status
                this.contactStatus = status
            })

            this.socket.on(`message-seen-chat-${this.selectedChat.psychologist._id}`, seenMessageIds => {
                for (let message of this.messages) {
                    if (message.isSeen) continue
                    message.isSeen = seenMessageIds.includes(message._id)
                }
            })
        } 
        else if (role == 'role_psychologist') {
            this.contactStatus = this.selectedChat.patient.isActive
            this.socket.on(this.selectedChat.patient._id, status => {
                this.selectedChat.patient.isActive = status 
                this.contactStatus = status
            })

            this.socket.on(`message-seen-chat-${this.selectedChat.patient._id}`, seenMessageIds => {
                for (let message of this.messages) {
                    if (message.isSeen) continue
                    message.isSeen = seenMessageIds.includes(message._id)
                }
            })
        }

        this.retrievePreviousMessages()
        const lastMessage = this.selectedChat.lastMessage
        this.signalLastMessageSeen(lastMessage)        
    },
    data() {
        return {
            message: '',
            skip: 0,
            contactStatus: false,
            messages: []
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

            this.socket.emit('sendMessage', 
                { accessToken, message, chat }, 
                error => { console.log(error) })

            this.message = ''
        },
        retrievePreviousMessages() {
            const accessToken = this.accessToken
            const chat = this.selectedChat._id
            const skip = this.skip
            this.page++

            this.socket.emit('retrievePreviousMessages', 
                { accessToken, chat, skip },
                error => { console.log(error) })
        },
        signalLastMessageSeen(message) {
            if (message.author._id === this.currentUser._id) return
            const accessToken = this.accessToken
            const chat = this.selectedChat._id
            this.selectedChat.lastMessage = message
            this.socket.emit('messageSeen', 
                            { chat, accessToken },
                            error => { console.log(error) })    
        }, 
        formatDate(date) {
            return moment(date).fromNow()
        },
        updateAllDates() {
            for (let message of this.messages) {
                message.createdAt = this.formatDate(message.createdAt)
            }
        }
    }
}
</script>

<style>
</style>