<template>
  <div class="pa-5">
    <v-card class="elevation-1" outlined>
      <div class="px-4 custom-border">
        <v-row>
          <v-col class="col-md-4 col-sm-5 col-12 mt-auto">
            <h2 class="font-weight-bold">Support Messages</h2>
          </v-col>

          <v-col class="col-md-2 col-sm-2 col-12">
            <v-switch hide-details v-model="isHandled" inset label="Handled"></v-switch>
          </v-col>

          <v-col class="col-md-6 col-md-5 col-12 mt-auto">
            <v-select
              class="mt-3 pr-5"
              hide-details
              :items="statusItems"
              v-model="status"
              label="Status"
              dense
            ></v-select>
          </v-col>
        </v-row>
      </div>
      <v-divider></v-divider>
      <div>
        <div>
          <div
            class="custom-border"
            v-for="message of messages"
            :key="message._id"
          >
            <v-row class="px-2 elevation-0">
              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Author</div>
                <div class="text-subtitle-2">{{ message.author.username }}</div>
              </v-col>

              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Email</div>
                <div class="text-subtitle-2">{{ message.author.email }}</div>
              </v-col>

              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Phone</div>
                <div class="text-subtitle-2">{{ message.author.phone }}</div>
              </v-col>

              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Date</div>
                <div class="text-subtitle-2">
                  {{ showDate(message.createdAt) }}
                </div>
              </v-col>

              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Message</div>

                <div>
                  <v-btn
                    @click="showSupportMessage(message)"
                    x-small
                    class="elevation-0 mx-1"
                    color="info"
                    dark
                    fab
                  >
                    <v-icon> mdi-eye</v-icon>
                  </v-btn>
                </div>
              </v-col>

              <v-col class="col-lg-2 col-md-4 col-sm-6 col-12">
                <div class="caption text--secondary">Operations</div>
                <div>
                  <v-btn
                    @click="deleteMessage(message)"
                    x-small
                    class="elevation-0 mx-1"
                    color="error"
                    dark
                    fab
                  >
                    <v-icon> mdi-delete</v-icon>
                  </v-btn>
                </div>
              </v-col>
            </v-row>
            <v-divider></v-divider>
          </div>
        </div>
      </div>
      <v-card-actions class="pa-0 custom-border">
        <v-container class="max-width">
          <v-pagination
            circle
            v-model="page"
            :length="totalPageCount"
          ></v-pagination>
        </v-container>
      </v-card-actions>
    </v-card>
    <v-dialog v-model="dialog" width="40%">
      <MessageDetailDialog
        @closeDialog="dialog = false"
        @refresh="refreshMessages()"
        :message="selectedMessage"
      ></MessageDetailDialog>
    </v-dialog>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import MessageDetailDialog from "@/components/supportMessages/SupportMessageDetailDialog";

export default {
  components: { MessageDetailDialog },
  created() {
    this.page = 1;
    this.retrieveAllMessages();
  },
  data() {
    return {
      page: 1,
      selectedMessage: {},
      dialog: false,
      statusItems: ["Info", "Problem", "Complaint"],
      status: "Info",
      isHandled: false,
    };
  },
  methods: {
    changeSearchColor(color) {
      this.searchColor = color;
    },
    retrieveAllMessagesBySearch() {
      this.page = 1;
      this.retrieveAllMessages();
    },
    retrieveAllMessages() {
      this.$store.dispatch("retrieveAllSupportMessages", {
        page: this.page,
        status: this.status,
        isHandled: this.isHandled,
      });
    },
    showSupportMessage(message) {
      this.selectedMessage = message;
      this.dialog = true;
    },
    showDate(dateStr) {
      const date = new Date(dateStr);
      return date.toUTCString();
    },
    deleteMessage(message) {
      this.$store
        .dispatch("deleteSupportMessage", {
          supportMessage: message._id,
        })
        .then((response) => {
          this.$toast.success(response.message);
          this.refreshMessages();
        })
        .catch((error) => {
          this.$toast.error(error);
        });
    },
    refreshMessages() {
      if (this.messages.length == 1) this.page--;
      this.retrieveAllMessages();
    },
  },
  computed: {
    ...mapGetters({
      messages: "getAllSupportMessages",
      totalPageCount: "getAllSupportMessagesTotalPageCount",
    }),
  },
  watch: {
    page() {
      this.retrieveAllMessages();
    },
    status() {
      this.retrieveAllMessages();
    },
    isHandled() {
      this.retrieveAllMessages();
    },
  },
};
</script>

<style>
.custom-border {
  border-left: solid 5px #3F51B5;
  border-radius: 1%;
}
</style>



