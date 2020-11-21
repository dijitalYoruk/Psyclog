<template>
  <div>
    <v-card class="elevation-1" outlined>
      <div class="px-4 custom-border">
        <v-row>
          <v-col class="mt-auto">
            <h2 class="font-weight-bold">Patients</h2>
          </v-col>
          <v-col>
            <v-text-field
              class="pt-0 pr-5"
              hide-details
              :placeholder="$t('search')"
              v-model="search"
              @keyup="(search.length >= 3 || search.length == 0) && retrieveAllUsersBySearch()"
              @click="changeSearchColor('primary')"
              @blur="changeSearchColor('grey')"
            >
              <v-icon slot="append" :color="searchColor">mdi-magnify</v-icon>
            </v-text-field>
          </v-col>
        </v-row>
      </div>
      <v-divider></v-divider>
      <div>
        <div>
          <div class="custom-border" v-for="user of users" :key="user._id">
            <v-row class="px-2 elevation-0">
              <v-col class="col-md-2">
                <div class="caption text--secondary">Username</div>
                <div class="text-subtitle-2">{{ user.username }}</div>
              </v-col>

              <v-col class="col-md-2">
                <div class="caption text--secondary">Email</div>
                <div class="text-subtitle-2">{{ user.email }}</div>
              </v-col>

              <v-col class="col-md-2">
                <div class="caption text--secondary">Phone</div>
                <div class="text-subtitle-2">{{ user.phone }}</div>
              </v-col>

              <v-col class="col-md-2">
                <div class="caption text--secondary">Verified</div>
                <div>
                  <v-btn class="elevation-0" color="success" fab x-small>
                    <v-icon small> mdi-swap-horizontal-bold </v-icon>
                  </v-btn>
                </div>
              </v-col>

              <v-col class="col-md-2">
                <div class="caption text--secondary">Ban</div>
                {{ showDate(user.banTerminationDate) }}
              </v-col>

              <v-col class="col-md-2">
                <div class="caption text--secondary">Operations</div>
                <div>
                  <v-btn @click="deleteUser(user)" x-small class="elevation-0 mx-1" color="error" dark fab>
                    <v-icon> mdi-delete</v-icon>
                  </v-btn>
                  <v-btn @click="banUser(user)" x-small class="elevation-0" color="warning" dark fab>
                    <v-icon> mdi-lock </v-icon>
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
    <v-dialog v-model="dialog" width="60%">
      <UserBanDialog @closeDialog='dialog=false' :user="selectedUser"></UserBanDialog>
    </v-dialog>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import UserBanDialog from "@/components/user/UserBanDialog";

export default {
  components: { UserBanDialog },
  created() {
    this.page = 1;
    this.retrieveAllUsers();
  },
  data() {
    return {
      page: 1,
      search: "",
      searchColor: "grey",
      role: "role_user",
      selectedUser: {},
      dialog: false,
    };
  },
  methods: {
    changeSearchColor(color) {
      this.searchColor = color;
    },
    getRemainingBanDays(banDate) {
      if (banDate == undefined) return 0;
    },
    retrieveAllUsersBySearch() {
      this.page = 1
      this.retrieveAllUsers()
    },
    retrieveAllUsers() {
      this.$store.dispatch("retrieveAllUsers", {
        page: this.page,
        role: this.role,
        search: this.search,
      });
    },
    banUser(user) {
        this.selectedUser = user
        this.dialog = true 
    },
    showDate(dateStr) {
      if (dateStr == undefined) return "-"
      const date = new Date(dateStr)
      return date == undefined || Date.parse(date) < Date.now() ? 
            '-' : date.toUTCString()
    },
    deleteUser(user) {
      this.$store.dispatch("deleteUser", {
        userId: user._id
      })
      .then(response => {
        this.$toast.success(response.message);
        this.refreshUsers()
      }) 
      .catch(error => {
        this.$toast.error(error)
      })
    },
    refreshUsers() {
      if (this.users.length == 1) { 
        alert('passes')
      this.page--
      }
      this.retrieveAllUsers()
    }
  },
  computed: {
    ...mapGetters({
      users: "getAllUsers",
      totalPageCount: "getAllUsersTotalPage",
      currentUser: "getCurrentUser",
    }),
  },
  watch : {
    page() {
      this.retrieveAllUsers()
    }
  }
};
</script>

<style>
.custom-border {
  border-left: solid 5px #3F51B5;
  border-radius: 1%;
}
</style>