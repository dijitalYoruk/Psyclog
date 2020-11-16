<template>
   <div>
      <nav class="mb-12">
         <v-app-bar class="darken-2 primary elevation-0" fixed dark dense>
            <v-app-bar-nav-icon v-if="isUserSignedIn" @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
            <div class="white--text font-weight-light">
               <span class="font-weight-bold">{{ $t('company_name') }}</span>
               {{ $t('panel') }}
            </div>
            <v-spacer></v-spacer>
            <router-link
               v-if="isUserSignedIn"
               active-class="active"
               exact
               :to="{name: 'auth.signIn'}"
            >
               <v-btn class="primary darken-2 elevation-0 white--text" @click="signOut">
                  {{ $t('sign_out') }}
                  <v-icon class="ml-2">mdi-login-variant</v-icon>
               </v-btn>
            </router-link>
         </v-app-bar>

         <v-navigation-drawer
            v-if="isUserSignedIn"
            v-model="drawer"
            app
            stateless
            class="mt-12"
            hide-overlay
         >
            <NavDrawer></NavDrawer>
         </v-navigation-drawer>
      </nav>
   </div>
</template>

<style scoped>
a {
   text-decoration: none;
}
</style>

<script>
import { mapGetters, mapMutations } from "vuex";
import NavDrawer from "@/components/shared/NavDrawer";

export default {
   data() {
      return {
         drawer: true,
      };
   },
   components: { NavDrawer },
   computed: { ...mapGetters(["isUserSignedIn"]) },
   methods: { ...mapMutations(["signOut"]) },
};
</script>