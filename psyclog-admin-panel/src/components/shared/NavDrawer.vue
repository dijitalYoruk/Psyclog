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

<script>
import { mapGetters } from "vuex";

export default {
   data() {
      return {
         profileImg:  this.$iconURL,
         currentDrawerItem: 4,
         drawerItems: [
            { text: this.$t("users"), icon: "mdi-account-group" },
            { text: this.$t("pending_verifications"), icon: "mdi-shield-account" },
            { text: this.$t("support"), icon: "mdi-face-agent" },
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
      getPath(item) {
         if (item === this.$t("pending_verifications")) {
            return { name: "pending.index" };
         } else if (item === this.$t("support")) {
            return { name: "support.index" };
         } else if (item === this.$t("users")) {
            return { name: "user.index.patients" };
         } 
      },
   },
};
</script>


<style scoped>
.border {
   border-right: 2px rgb(68, 67, 67);
}
</style>
