<template>
  <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card class="pa-4 mt-5">
        <v-list rounded>
          <v-list-item-group color="primary">
            <v-list-item v-for="(chat, i) in chats" @click="goToChat(chat)" :key="i">
              <v-row v-if="currentUser.role == 'user'">
                <v-col class="col-7">
                  <div class="font-weight-bold">{{ chat.psychologist.username }}</div>
                  <div>{{ chat.lastMessage.message }}</div>
                </v-col>
                <v-col class="col-2">
                  <v-chip
                    v-if='isSeen(chat)'
                    small
                    color="primary"
                  ></v-chip>
                </v-col>
                <v-col class="col-2">
                  <v-btn fab x-small :color="chat.psychologist.isActive ? 'red': 'grey'"></v-btn>
                </v-col>
              </v-row>

              <v-row v-if="currentUser.role == 'role_psychologist'">
                <v-col class="col-7">
                  <div class="font-weight-bold">{{ chat.patient.username }}</div>
                  <div>{{ chat.lastMessage.message }}</div>
                </v-col>
                <v-col class="col-2">
                  <v-chip
                    v-if='isSeen(chat)'
                    small
                    color="primary"
                  ></v-chip>
                </v-col>
                <v-col class="col-2">
                  <v-btn fab x-small :color="chat.patient.isActive ? 'red': 'grey'"></v-btn>
                </v-col>
              </v-row>
            </v-list-item>
          </v-list-item-group>
        </v-list>
      </v-card>
    </v-col>
    <v-col>
      <v-btn @click="logOut()">Log Out</v-btn>
    </v-col>
  </v-row>
</template>


<script>
import { mapGetters } from "vuex";

export default {
  created() {
    if (this.socket == undefined) {
      this.$store.commit("connectSocket")
    }

    this.socket.off()
    this.activateUser()

    this.socket.on("chats", (chats) => {
      this.$store.commit("setChats", chats)
      this.listenUsers();
    })

    this.socket.on('message', message => {
      const chat = this.chats.find(chat => chat._id === message.chat)
      chat.isLastMessageSeen = false
      chat.lastMessage = message
    })
  },
  computed: {
    ...mapGetters({
      currentUser: "getCurrentUser",
      accessToken: "getAccessToken",
      socket: "getSocket",
      chats: "getChats",
    }),
  },
  methods: {
    activateUser() {
      const accessToken = this.accessToken
      this.socket.emit("activateUser", { accessToken })
    },
    retrieveContacts() {
      const accessToken = this.accessToken
      this.socket.emit("retrieveContacts", { accessToken })
    },
    goToChat(chat) {
      this.disableListeners()
      this.$store.commit("setSelectedChat", chat)
      this.$router.push({ name: "chat" })
    },
    logOut() {
      this.disableListeners()
      this.$store.commit("logOut")
      this.socket.disconnect()
      this.$router.push({ name: "SignIn" })
    },
    listenUsers() {
      this.socket.off("chats")
      const role = this.currentUser.role

      for (let chat of this.chats) {
        if (role === "user") {
          console.log('>>>' + chat.psychologist._id + '<<<')
          this.socket.on(chat.psychologist._id, (status) => {
            chat.psychologist.isActive = status
            console.log('status')
          })
        } 
        else if (role === "role_psychologist") {
          console.log('>>>' + chat.patient._id + '<<<')
          this.socket.on(chat.patient._id, (status) => {
            chat.patient.isActive = status
            console.log('status')
          })
        }
      }
    },
    disableListeners() {
      this.socket.off('message')
      if (this.currentUser.role == "user") {
        for (let chat of this.chats) { this.socket.off(chat.psychologist._id) }
      } else if (this.currentUser.role == "role_psychologist") {
        for (let chat of this.chats) { this.socket.off(chat.patient._id) }
      }
    },
    isSeen(chat) {
      console.log(chat.lastMessage.author)
      console.log(this.currentUser._id)
      console.log(chat.isLastMessageSeen)
      console.log(typeof(chat.isLastMessageSeen))
      return chat.lastMessage.author !== this.currentUser._id && !chat.isLastMessageSeen
    },
  }
}
</script>

<style>
</style>