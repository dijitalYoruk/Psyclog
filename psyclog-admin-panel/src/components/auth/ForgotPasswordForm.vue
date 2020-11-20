<template>
   <form>
      <v-btn class="px-0 mx-0 mb-3" text icon @click="goToSigIn()">
         <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <div class="mx-2">
         <div class="font-weight-bold headline">{{ $t('forgot_password') }}</div>
         <div class="caption grey--text lighten-1--text">{{ $t('request_email') }}</div>
         <v-text-field
            @blur="$v.email.$touch()"
            :error-messages="mailErrors"
            v-model="email"
            :label="$t('email')"
            class="mt-2"
         ></v-text-field>
         <v-btn
            class="font-weight-bold primary px-10 mt-2"
            width="100%"
            @click="sendResetPasswordEmail"
         >{{ $t('send_password_reset') }}</v-btn>
      </div>
   </form>
</template>

<style scoped>
</style>

<script>
import { required, email } from "vuelidate/lib/validators";

export default {
   data() {
      return {
         email: ""
      };
   },
   validations: {
      email: {
         required,
         email
      }
   },
   computed: {
      mailErrors() {
         const errors = [];
         if (!this.$v.email.$dirty) return errors;
         !this.$v.email.required && errors.push( 
            this.$t("validation_required", { item: 'Email' }) );
         !this.$v.email.email && errors.push( 
            this.$t("validation_valid", { item: 'Email' }) );
         return errors;
      }
   },
   methods: {
      goToSigIn() { this.$emit("goToSignIn") },
      sendResetPasswordEmail() {
         this.$v.$touch();
         if (this.mailErrors.length != 0) {
            return;
         }

         this.$store
            .dispatch("sendResetPasswordEmail", {
               email: this.email
            })
            .then(result => {
               if (result.data.success == false) {
                  this.$toast.error(this.$t("alert_error_send_password_email"));
               } else {
                  this.$toast.success(this.$t("alert_success_send_password_email"));
                  this.goToSigIn();
               }
            })
            .catch(exception => {
                  this.$toast.error(exception)
            });
      }
   }
};
</script>