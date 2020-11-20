<template>
   <div>
      <v-list>
         <v-list-item>
            <v-row>
               <v-col class="col-12 text-center font-weight-bold body-1">{{ currentUser.username }}</v-col>
            </v-row>
         </v-list-item>
      </v-list>
      <v-divider></v-divider>

      <v-list shaped>
         <v-list-item-group v-model="currentDrawerItem" color="primary">
            <v-list-item v-for="(item, i) in drawerItems" :to="getPath(item.text)" :key="i">
               <v-list-item-icon>
                  <v-icon v-text="item.icon"></v-icon>
               </v-list-item-icon>
               <v-list-item-content>
                  <v-list-item-title v-text="item.text"></v-list-item-title>
               </v-list-item-content>
            </v-list-item>
         </v-list-item-group>
      </v-list>
   </div>
</template>


<style scoped>
.border {
   border-right: 1px grey;
}
</style>

<script>
import { mapGetters } from "vuex";

export default {
   data() {
      return {
         profileImg:  this.$iconURL,
         currentDrawerItem: 4,
         drawerItems: [
            { text: this.$t("bans"), icon: "mdi-account" },
            { text: this.$t("users"), icon: "mdi-account-group" },
            { text: this.$t("pending_verifications"), icon: "mdi-shield-account" },
            { text: this.$t("support"), icon: "mdi-align-horizontal-left" },
         ],
      };
   },
   computed: {
      icon() {
         return this.$iconURL
      },
      ...mapGetters({
      currentUser: "getCurrentUser"
    }),
   },
   methods: {
      navigate(item) {
         if (item === this.$t("profile")) {
            this.$router.push({ name: "adminProfile" });
         } else if (item === this.$t("users")) {
            this.$router.push({ name: "user.index", query: { page: 1 } });
         } else if (item === this.$t("roles")) {
            this.$router.push({ name: "role.index" });
         } else if (item === this.$t("survey")) {
            this.$router.push({
               name: "poll.index",
               query: { page: 1 },
            });
         } else if (item === this.$t("events")) {
            this.$router.push({
               name: "post.index",
               params: { tag: "event" },
               query: { page: 1 },
            });
         } else if (item === this.$t("news")) {
            this.$router.push({
               name: "post.index",
               params: { tag: "news" },
               query: { page: 1 },
            });
         } else if (item === this.$t("announcements")) {
            this.$router.push({
               name: "post.index",
               params: { tag: "announcement" },
               query: { page: 1 },
            });
         } else if (item === this.$t("notifications")) {
            this.$router.push({
               name: "notification.index",
               query: { page: 1 },
            });
         }
      },
      getPath(item) {
         if (item === this.$t("profile")) {
            return { name: "adminProfile" };
         } else if (item === this.$t("users")) {
            return { name: "user.index", query: { page: 1 } };
         } else if (item === this.$t("roles")) {
            return { name: "role.index" };
         } else if (item === this.$t("survey")) {
            return { name: "poll.index" };
         } else if (item === this.$t("events")) {
            return { name: "post.index", params: { tag: "event" } };
         } else if (item === this.$t("news")) {
            return { name: "post.index", params: { tag: "news" } };
         } else if (item === this.$t("announcements")) {
            return { name: "post.index", params: { tag: "announcement" } };
         } else if (item === this.$t("notifications")) {
            return { name: "notification.index", query: { page: 1 } };
         }
      },
   },
};
</script>
