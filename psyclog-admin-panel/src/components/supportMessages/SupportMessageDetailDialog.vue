<template>
  <div>
    <v-card class="px-3">
      <h3 class="font-weight-bold text-center py-2">Support Message</h3>
      <v-divider></v-divider>

      <div class="pa-2">
        <div class="text-center">
          <v-avatar size="100" style="border: solid 2px black">
            <img :src="loadImage(message.author.profileImage)" alt="John" />
          </v-avatar>
        </div>
        <div class="font-weight-bold text-decoration-underline text-center">
          Author
        </div>
      </div>
      <v-divider></v-divider>

      <v-row justify="center">
        <v-col class="col-auto">
          <div class="caption text--secondary">Username</div>
          <div class="text-subtitle-2">{{ message.author.username }}</div>
        </v-col>

        <v-col class="col-auto">
          <div class="caption text--secondary">Email</div>
          <div class="text-subtitle-2">{{ message.author.email }}</div>
        </v-col>

        <v-col class="col-auto">
          <div class="caption text--secondary">Phone</div>
          <div class="text-subtitle-2">{{ message.author.phone }}</div>
        </v-col>
      </v-row>

      <v-divider></v-divider>

      <div v-if="message.complaint">
        <div class="pa-2">
          <div class="text-center">
            <v-avatar size="100" style="border: solid 2px black">
              <v-img
                :src="loadImage(message.complaint.profileImage)"
                alt="John"
              />
            </v-avatar>
          </div>
          <div class="font-weight-bold text-decoration-underline text-center">
            Complaint
          </div>
        </div>

        <v-divider></v-divider>
        <v-row justify="center">
          <v-col class="col-auto">
            <div class="caption text--secondary">Username</div>
            <div class="text-subtitle-2">{{ message.complaint.username }}</div>
          </v-col>

          <v-col class="col-auto">
            <div class="caption text--secondary">Email</div>
            <div class="text-subtitle-2">{{ message.complaint.email }}</div>
          </v-col>

          <v-col class="col-auto">
            <div class="caption text--secondary">Phone</div>
            <div class="text-subtitle-2">{{ message.complaint.phone }}</div>
          </v-col>
        </v-row>
        <v-divider></v-divider>
      </div>

      <div class="pa-2">
        <div class="font-weight-bold text-decoration-underline text-center">
          Message
        </div>
        <div class="text-subtitle-2">
          {{ message.message }}
        </div>
      </div>
      <v-divider></v-divider>
      <v-row class="pa-0">
        <v-col class="pa-0">
          <v-btn
            tile
            width="100%"
            @click="handleMessage()"
            :color="message.isHandled ? 'warning' : 'success'"
            >{{ message.isHandled ? "Unhandle" : "Handle" }}</v-btn
          >
        </v-col>
        <v-col class="pa-0">
          <v-btn tile width="100%" @click="closeDialog()" color="error"
            >Cancel</v-btn
          >
        </v-col>
      </v-row>
    </v-card>
  </div>
</template>

<script>
export default {
  props: ["message"],
  methods: {
    loadImage(image) {
      return image == undefined || image == ""
        ? "data:image/png;base64,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"
        : image;
    },
    closeDialog() {
      this.$emit("closeDialog");
    },
    handleMessage() {
      this.$store
        .dispatch("handleSupportMessage", {
          isHandled: !this.message.isHandled,
          supportMessage: this.message._id,
        })
        .then((response) => {
          this.$toast.success(response.message);
          this.closeDialog();
          this.$emit("refresh");
        })
        .catch((error) => {
          this.$toast.error(error);
        });
    },
  },
};
</script>

<style>
</style>