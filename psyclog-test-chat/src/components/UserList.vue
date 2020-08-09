<template>
  <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card class="pa-4 mt-5">
        <v-list rounded>
          <v-list-item-group color="primary">
            <v-list-item v-for="(chat, i) in chats" @click="goToChat(chat)" :key="i">
              <v-row>
                <v-col class="col-7">
                  <div class="font-weight-bold">{{ contacts[i].username }}</div>
                  <div v-if="chat.lastMessage">
                    <div v-if="chat.lastMessage.author == currentUser._id">
                      <v-icon v-if="chat.lastMessage.isSeen">mdi-check-bold</v-icon>
                      <v-icon v-else>mdi-check</v-icon>
                    </div>
                    {{ chat.lastMessage.message }}
                  </div>
                </v-col>
                <v-col class="col-2">
                  <v-chip v-if="isSeen(chat)" small color="primary"></v-chip>
                </v-col>
                <v-col class="col-2">
                  <v-btn fab x-small :color="chat.psychologist.isActive ? 'red': 'grey'"></v-btn>
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
        role == "user" ? chat.psychologist : chat.patient
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