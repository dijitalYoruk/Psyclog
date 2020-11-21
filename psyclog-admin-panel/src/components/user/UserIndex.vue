<template>
  <div>
    <v-tabs>
      <v-tab :to='{ name: "user.index.patients"}'>Patients</v-tab>
      <v-tab :to='{ name: "user.index.psychologists"}'>Psycologists</v-tab>
    </v-tabs>
    <v-divider></v-divider>
    <v-row>
      <v-col class="col-md-12">
        <div class="px-4">
          <transition name="slide" type="transition" mode="out-in">
            <router-view></router-view>
          </transition>
        </div>
      </v-col>
    </v-row>
  </div>
</template>

<script>
export default {};
</script>

<style>
</style>