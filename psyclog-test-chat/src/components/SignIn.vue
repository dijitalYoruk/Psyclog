<template>
  <v-row>
    <v-col class="col-md-4 offset-md-4">
      <v-card class="pa-4 mt-5">
        <v-text-field outlined v-model="emailOrUsername"></v-text-field>
        <v-text-field outlined v-model="password"></v-text-field>
        <v-btn @click="signIn()" color="red">Sign In</v-btn>
      </v-card>
    </v-col>
  </v-row>
</template>

<script>
export default {
  data() {
    return {
      emailOrUsername: '',
      password: ''
    }
  },
  methods: {
    signIn() {
     
      this.$store
        .dispatch("signInUser", {
          emailOrUsername: this.emailOrUsername,
          password: this.password
        })
        .then(data => {
          this.$router.push({
            name: "UserList",
          });

          window.console.log('success')
          window.console.log(data)
        })
        .catch(error => {
          window.console.log(error)  
        });

    }
  }
};
</script>

<style>
</style>