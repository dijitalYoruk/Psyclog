import store from '@/store/index.js'

import Vue from 'vue'
import VueRouter from 'vue-router'
import SignIn from '@/components/SignIn.vue'
import UserList from '@/components/UserList.vue'
import Chat from '@/components/Chat.vue'

Vue.use(VueRouter)

  const routes = [
  {
    path: '/',
    name: 'SignIn',
    component: SignIn,
    meta: {
      requiresVisitor: true
    }
  },
  {
    path: '/userList',
    name: 'UserList',
    component: UserList,
    meta: {
      requiresAuth: true
    }
  },
  {
    path: '/chat',
    name: 'chat',
    component: Chat,
    meta: {
      requiresAuth: true
    }
  },
]

const router = new VueRouter({ routes })

router.beforeEach((to, from, next) => {
	const requiresAuth 	  = to.matched.some(record => record.meta.requiresAuth);
	const requiresVisitor = to.matched.some(record => record.meta.requiresVisitor);

	if (requiresAuth && !store.getters.isAuthenticated) {
		next({ name: 'SignIn' });
	} 
	else if (requiresVisitor && store.getters.isAuthenticated) {
		next({ name: "UserList" })
	} 
	else {
		next();
	}
})

export default router
