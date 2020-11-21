<template>
  <form class="mx-2">
    <div>
      <div class="font-weight-bold headline">{{ $t('login') }}</div>
      <v-text-field
        @blur="$v.usernameOrEmail.$touch()"
        :error-messages="usernameOrEmailErrors"
        v-model="usernameOrEmail"
        :label="$t('email_username')"
      ></v-text-field>
      <v-text-field
        @blur="$v.password.$touch()"
        :error-messages="passwordErrors"
        v-model="password"
        :label="$t('password')"
        type="password"
        class="mb-2"
      ></v-text-field>
    </div>
    <v-btn @click="signIn" class="font-weight-bold primary px-10">{{ $t('login') }}</v-btn>
    <a @click="goToForgotPassword()" style="color: grey" class="ml-2 caption nobr">{{ $t('forgot_password') }}?</a>
  </form>
</template>

<script>
import { required } from "vuelidate/lib/validators";

export default {
  data() {
    return {
      usernameOrEmail: "",
      password: ""
    };
  },
  validations: {
    usernameOrEmail: { required },
    password: { required }
  },
  computed: {
    usernameOrEmailErrors() {
      const errors = [];
      if (!this.$v.usernameOrEmail.$dirty) return errors;
      !this.$v.usernameOrEmail.required && errors.push( 
        this.$t('validation_required', { item: 'Email' }) );
      return errors;
    },
    passwordErrors() {
      const errors = [];
      if (!this.$v.password.$dirty) return errors;
      !this.$v.password.required && errors.push( 
        this.$t('validation_required', { item: 'Password' }) );
      return errors;
    }
  },
  methods: {
    goToForgotPassword() {
      this.$emit("forgotPassword");
    },
    async signIn() {
      this.$v.$touch();
      if (
        this.usernameOrEmailErrors.length != 0 ||
        this.passwordErrors.length != 0
      ) {
        return
      }

      try {
        await this.$store.dispatch("signInUser", {
          usernameOrEmail: this.usernameOrEmail,
          password: this.password,
        })
   
        this.$router.push({ name: "user.index.patients"})
        this.$toast.success(this.$t('alert_success_auth'))
      } catch (exception) {
        this.$toast.error(exception)
      } 
    }
  }
}
</script>

<style scoped>
.nobr {
  white-space: nowrap;
}
</style>