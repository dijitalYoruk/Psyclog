<template>
    <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card outlined class="pa-4 mt-5 elevation-3">
        <div v-for="msg in messages" :key="msg.id">
            <strong>Author: </strong>{{ msg.author.username }}
            <div><strong>Message:</strong> {{ msg.message }}</div>
            <div><strong>Date:</strong> {{ msg.createdAtFormat }}</div>
            <div v-if="msg.author._id == currentUser._id">
                <strong>Contact Seen:</strong> {{ msg.isSeen }}
            </div>
            <v-divider></v-divider>
        </div>
        <div v-if="contact.isActive">Online</div>
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

        this.socket.on('message', message => {
            this.skip++
            message.createdAtFormat = this.formatDate(message.createdAt)
            this.messages.push(message)
            this.selectedChat.lastMessage = message 
            this.signalLastMessageSeen(message)
        })

        this.socket.on('previousMessages', messages => {
            this.skip += messages.length
            messages = this.updateAllDates(messages)
            this.messages.unshift(...messages.reverse())
        })

        // determining the contact. 
        const role = this.currentUser.role
        this.contact = role == 'user' ? this.selectedChat.psychologist :
                                        this.selectedChat.patient

        this.socket.on(this.contact._id, status => {
            this.contact.isActive = status
        })

        this.socket.on(`message-seen-chat-${this.contact._id}`, seenMessageIds => {
            for (let message of this.messages) {
                if (message.isSeen) continue
                message.isSeen = seenMessageIds.includes(message._id)
            }
        })

        this.retrievePreviousMessages()
        const lastMessage = this.selectedChat.lastMessage
        this.signalLastMessageSeen(lastMessage)    
        this.setTimeIntervals()
    },
    data() {
        return {
            message: '',
            skip: 0,
            messages: [],
            contact: '',
            formattedDates: new Map()
        }
    },
    computed: {
        ...mapGetters({
            socket: 'getSocket',
            currentUser: 'getCurrentUser',
            accessToken: 'getAccessToken',
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
        updateAllDates(messages) {
            for (let message of messages) 
                message.createdAtFormat = this.formatDate(message.createdAt)
            return messages
        },
        updateDates() {
            for (let message of this.messages) 
                message.createdAtFormat = this.formatDate(message.createdAt)
        },
        setTimeIntervals() {
            setInterval(() => {
                this.updateDates()
            }, 20 * 1000)
        }
    }
}
</script>

<style>
</style>