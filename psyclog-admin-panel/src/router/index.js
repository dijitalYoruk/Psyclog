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

// user
import User from '@/components/user/User.vue'
import UserIndex from '@/components/user/UserIndex.vue'
import UserPatients from '@/components/user/UserPatients.vue'
import UserPsychologists from '@/components/user/UserPsychologists.vue'

// pending psychologists
import PendingPsychologists from '@/components/pendingPsychologists/PendingPsychologists.vue'
import PendingPsychologistsIndex from '@/components/pendingPsychologists/PendingPsychologistsIndex.vue'

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
    path: '/home',
    name: 'home',
    component: UserIndex,
    meta: {
      requiresAuth: true
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
    path: "/user",
    component: User,
    children: [{
        path: "",
        name: "user.index",
        component: UserIndex,
        children: [
          {
            path: "patients",
            name: "user.index.patients",
            component: UserPatients
          },
          {
            path: "psychologists",
            name: "user.index.psychologists",
            component: UserPsychologists
          } 
        ]
      }
    ],
    meta: {
      requiresAuth: true
    }
  },
  {
    path: "/pendingPsychologists",
    component: PendingPsychologists,
    children: [{
        path: "",
        name: "PendingPsychologistsIndex.index",
        component: PendingPsychologistsIndex
      }
    ],
    meta: {
      requiresAuth: true
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