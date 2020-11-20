<template>
  <v-card class="pa-4">
    <div>
      <v-row>
        <v-col class="text-center font-weight-bold">
          {{ user.username }}
        </v-col>
      </v-row>
      <v-divider></v-divider>
      <v-row>
        <v-col class="offset-1 col-5">
          <v-menu
            ref="menu1"
            v-model="menu1"
            :close-on-content-click="false"
            transition="scale-transition"
            offset-y
            max-width="290px"
            min-width="290px"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="dateFormatted"
                persistent-hint
                label="Date"
                prepend-icon="mdi-calendar"
                v-bind="attrs"
                :error-messages="dateErrors"
                @blur="date = parseDate(dateFormatted)"
                v-on="on"
              ></v-text-field>
            </template>
            <v-date-picker
              v-model="date"
              no-title
              @input="menu1 = false"
            ></v-date-picker>
          </v-menu>
        </v-col>
        <v-col class="col-5">
          <v-menu
            ref="menu"
            v-model="menu2"
            :close-on-content-click="false"
            :nudge-right="40"
            :return-value.sync="time"
            transition="scale-transition"
            offset-y
            max-width="290px"
            min-width="290px"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-text-field
                v-model="time"
                label="Time"
                :error-messages="timeErrors"
                prepend-icon="mdi-clock-time-four-outline"
                readonly
                v-bind="attrs"
                v-on="on"
              ></v-text-field>
            </template>
            <v-time-picker
              v-if="menu2"
              v-model="time"
              full-width
              @click:minute="$refs.menu.save(time)"
            ></v-time-picker>
          </v-menu>
        </v-col>
      </v-row>
      <div class="text-center">
        <v-btn @click="constructDateAndBan()" class="mx-1" color="error">Ban</v-btn>
        <v-btn @click="removeBan()" class="mx-1" color="warning">Remove Ban</v-btn>
      </div>
    </div>
  </v-card>
</template>

<script>
import { required } from "vuelidate/lib/validators";

export default {
  props: ["user"],
  data: () => ({
    date: null,
    dateFormatted: null,
    menu1: false,
    menu2: false,
    time: null,
  }),
  validations: {
    date: { required },
    time: { required }
  },
  computed: {
    dateErrors() {
      const errors = [];
      if (!this.$v.date.$dirty) return errors;
      !this.$v.date.required && errors.push( 
        this.$t('validation_required', { item: 'Date' }) );
      return errors;
    },
    timeErrors() {
      const errors = [];
      if (!this.$v.time.$dirty) return errors;
      !this.$v.time.required && errors.push( 
        this.$t('validation_required', { item: 'Time' }) );
      return errors;
    },
    computedDateFormatted() {
      return this.formatDate(this.date);
    },
  },

  watch: {
    date() {
      this.dateFormatted = this.formatDate(this.date);
    },
  },

  methods: {
    formatDate(date) {
      if (!date) return null;

      const [year, month, day] = date.split("-");
      return `${month}/${day}/${year}`;
    },
    parseDate(date) {
      if (!date) return null;

      const [month, day, year] = date.split("/");
      return `${year}-${month.padStart(2, "0")}-${day.padStart(2, "0")}`;
    },
    constructDateAndBan() {
      this.$v.$touch()
      if (this.$v.$anyError) {
        return
      }

      const [hour, minute] = this.time.split(":");
      const [year, month, day] = this.date.split("-");
      const banTermination = new Date(year, month-1, day, hour, minute);
      const patientId = this.user._id

      if (Date.parse(banTermination) < Date.now()) {
        this.$toast.error(this.$t('alert_error_invalid_date'))
        return
      } 

      this.$store.dispatch('banUserAsAdmin', {
        banTermination, patientId
      })
      .then(response => {
        this.user.banTerminationDate = banTermination;
        this.$emit('closeDialog')
       // this.$toast.success(this.$t('alert_success_ban'))
        this.$toast.success(response.message)
      })
      .catch((error) => {
        this.$toast.error(error)
      })
    },
    removeBan() {
      if (this.user.banTerminationDate == undefined) {
        this.$toast.error(this.$t('alert_error_not_banned'))
        return 
      }

      const patientId = this.user._id
      this.$store.dispatch('removeBanFromPatient', { 
        patientId 
      })
      .then(response => {
        this.user.banTerminationDate = undefined;
        this.$emit('closeDialog')
        this.$toast.success(response.message)
      })
      .catch((error) => {
        this.$toast.error(error)
      })
    }
  },
};
</script>

<style>
</style>