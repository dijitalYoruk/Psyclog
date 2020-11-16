<template>
   <div>
      <v-list>
         <v-list-item>
            <v-avatar style="border: 1px solid grey" size="100%">
               <v-img :src="icon" rounded aspect-ratio="1"></v-img>
            </v-avatar>
         </v-list-item>
         <v-list-item>
            <v-row>
               <v-col class="col-12 text-center font-weight-bold body-1">{{ profileName }}</v-col>
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
export default {
   data() {
      return {
         profileName: "Fatih Uyanik",
         profileImg:  this.$iconURL,
         currentDrawerItem: 4,
         drawerItems: [
            { text: this.$t("profile"), icon: "mdi-account" },
            { text: this.$t("users"), icon: "mdi-account-group" },
            { text: this.$t("roles"), icon: "mdi-shield-account" },
            { text: this.$t("survey"), icon: "mdi-align-horizontal-left" },
            { text: this.$t("events"), icon: "mdi-calendar-clock" },
            { text: this.$t("news"), icon: "mdi-newspaper-variant-outline" },
            { text: this.$t("announcements"), icon: "mdi-message-alert" },
            { text: this.$t("notifications"), icon: "mdi-bell" },
         ],
      };
   },
   computed: {
      icon() {
         return this.$iconURL
      }
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
