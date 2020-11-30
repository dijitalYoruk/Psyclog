<template>
<div>
  <v-row>
    <v-col class="col-md-6 offset-md-3">
      <v-card outlined class="pa-4 mt-5 mx-10 elevation-2">
        <v-list rounded>
          <v-list-item-group color="primary">
            <v-list-item v-for="(contact, i) in contacts" @click="goToChat(chats[i])" :key="i">
              <v-row>
                <v-col class="col-10">
                  <div class="font-weight-bold">{{ contact.username }}</div>
                  <div v-if="chats[i].lastMessage">
                    <div v-if="chats[i].lastMessage.author == currentUser._id">
                      <v-icon v-if="chats[i].lastMessage.isSeen">mdi-check-bold</v-icon>
                      <v-icon v-else>mdi-check</v-icon>
                    </div>
                    {{ chats[i].lastMessage.message }}
                  </div>
                </v-col>
                <v-col class="col-1">
                  <v-chip v-if="isSeen(chats[i])" small color="primary"></v-chip>
                </v-col>
                <v-col class="col-1">
                  <v-btn fab x-small :color="contact.isActive ? 'red': 'grey'"></v-btn>
                </v-col>
              </v-row>
            </v-list-item>
          </v-list-item-group>
        </v-list>
      </v-card>
    </v-col>
  </v-row>
  <v-row>
    <v-col class="text-center">
      <v-btn color="primary" @click="logOut()">Log Out</v-btn>
    </v-col>
  </v-row>
</div>
</template>


<script>
import { mapGetters } from "vuex";

export default {
  created() {
    if (this.socket == undefined) {
      this.$store.commit("connectSocket");
    }

    this.activateUser();
    this.socket.off();

    this.socket.on("chats", (chats) => {
      this.$store.commit("setChats", chats);
      this.listenUsers();
    });

    this.socket.on(`message-seen-list`, (lastMessage) => {
      const chatId = lastMessage.chat;
      const chat = this.chats.find((chat) => chat._id === chatId);
      chat.lastMessage = lastMessage;
    });

    this.socket.on("message", (message) => {
      const chat = this.chats.find((chat) => chat._id === message.chat);
      chat.lastMessage = message;
    });
  },
  data() {
    return {
      contacts: [],
    };
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
      const accessToken = this.accessToken;
      this.socket.emit("activateUser", { accessToken }, (error) => {
        console.log(error.message);
      });
    },
    goToChat(chat) {
      this.$store.commit("setSelectedChat", chat);
      this.$router.push({ name: "chat" });
    },
    logOut() {
      this.socket.off();
      this.$store.commit("logOut");
      this.socket.disconnect();
      this.$router.push({ name: "SignIn" });
    },
    listenUsers() {
      this.socket.off("chats");
      const role = this.currentUser.role;
      this.contacts = this.chats.map((chat) =>
        role == "role_user" ? chat.psychologist : chat.patient
      );

      for (let contact of this.contacts) {
        this.socket.on(contact._id, (status) => {
          contact.isActive = status;
        });
      }
    },
    isSeen(chat) {
      return (
        chat.lastMessage != undefined &&
        chat.lastMessage.author !== this.currentUser._id &&
        !chat.lastMessage.isSeen
      );
    },
  },
};
</script>

<style>
</style>