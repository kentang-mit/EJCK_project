import Vue from 'vue'
import BootstrapVue from "bootstrap-vue"
import App from './app.vue'
import "bootstrap/dist/css/bootstrap.min.css"
import "bootstrap-vue/dist/bootstrap-vue.css"
import VueRouter from 'vue-router'
import Routes from './router';
import VueCookies from 'vue-cookies'

Vue.use(BootstrapVue);
Vue.use(VueRouter);
Vue.use(VueCookies);

const RouterConfig = {
    mode: 'history',
    routes: Routes
};
const router = new VueRouter(RouterConfig);

new Vue({
  el: '#app',
  router: router,
  render: h => h(App)
})
