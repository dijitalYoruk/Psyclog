// packages
import Vue from 'vue'
import VueRouter from 'vue-router'
import store from '@/store/store.js'

// *****************************************
// components
// *****************************************

// auth
import Auth from '@/components/auth/Auth.vue'
import AuthSignIn from '@/components/auth/SignIn.vue'

import Error404 from '@/components/404.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'root',
    component: AuthSignIn,
    meta: {
      requiresVisitor: true
    }
  },
  {
    path: "/auth",
    component: Auth,
    children: [{
        path: "signIn",
        name: "auth.signIn",
        component: AuthSignIn,
      },
      {
        path: "forgotPassword",
        name: "auth.forgotPassword",
        component: AuthSignIn,
      }
    ],
    meta: {
      requiresVisitor: true
    }
  },
  {
    path: "*",
    name: "404",
    component: Error404
  }

]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

router.beforeEach((to, from, next) => {
	const requiresAuth 	  = to.matched.some(record => record.meta.requiresAuth);
	const requiresVisitor = to.matched.some(record => record.meta.requiresVisitor);

	if (requiresAuth && !store.getters.isUserSignedIn) {
		next('/auth/signIn');
	} 
	else if (requiresVisitor && store.getters.isUserSignedIn) {
		next({
      name: "post.index",
      params: { tag: "news" },
      query: { page: 1 }
    });
	} 
	else {
		next();
	}
})

export default router