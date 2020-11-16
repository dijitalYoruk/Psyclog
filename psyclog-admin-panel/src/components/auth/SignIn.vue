<template>
    <v-row class="mt-8" no-gutters>
        <v-col class="pa-6" xl="6" offset-xl="3" lg="8" offset-lg="2" md="10" offset-md="1">
            <v-container class="mx-0 px-0">
                <v-card class="mx-auto mt-6 elevation-5">
                    <v-row no-gutters>
                        <v-col class="pa-10" md="6">
                            <v-row md="12" no-gutters>
                                <v-col md="12">
                                    <transition name="slide" type="transition" mode="out-in">
                                        <component
                                            @goToSignIn="goToSignIn()"
                                            @forgotPassword="gotoForgotPassword()"
                                            :is="componentId"
                                        ></component>
                                    </transition>
                                </v-col>
                            </v-row>
                        </v-col>
                        <v-col class="border hidden-sm-and-down" md="6">
                            <img
                                class="pa-5"
                                src="https://s3.us-east-2.amazonaws.com/upload-icon/uploads/icons/png/667997461557996999-512.png"
                                width="100%"
                                height="500px"
                            >
                        </v-col>
                    </v-row>
                </v-card>
            </v-container>
        </v-col>
    </v-row>
</template>

<script>
import ForgotPasswordForm from "@/components/auth/ForgotPasswordForm";
import SignInForm from "@/components/auth/SignInForm";

export default {
    created() {
        this.componentId = this.$router.currentRoute.name == 
            "auth.signIn" ? "SignInForm" : "ForgotPasswordForm";
    },
    data() {
        return {
            componentId: ""
        };
    },
    components: { ForgotPasswordForm, SignInForm },
    methods: {
        gotoForgotPassword() {
            this.componentId = "ForgotPasswordForm";
        },
        goToSignIn() {
            this.componentId = "SignInForm";
        }
    }
};
</script>

<style scoped>
.border {
    border-left: 1px solid  #BDBDBD
}
</style>