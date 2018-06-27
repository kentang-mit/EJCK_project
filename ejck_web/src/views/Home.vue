<template>
  <div>
  <my-navbar></my-navbar>
  <div class="container">
  	<body>
  	<h1 align="left">欢迎来到上海交通大学信息化教材科管理系统！</h1>
  	<hr>
  	<b-card>
	  <li v-if="stuId=='' || stuId == undefined">登陆系统后请完善个人信息～</li>
	  <li v-if="stuId=='' || stuId == undefined">jAccount入口：<b-button @click="getUserInformation" variant="primary">点击登陆</b-button></li>
    <div v-else>
      <b-alert show variant="success">欢迎回来，{{name}}(学号：{{stuId}}）同学！</b-alert>
    </div>
    </b-card>
  	</body>
  </div>
  </div>
</template>


<script>
import Navbar from './Navbar.vue'
import ajax from '../ajax'
const iconv = require('iconv-lite');
export default {
  name: 'home',
  components: {'my-navbar': Navbar},
  data(){
    return{
      name: '',
      stuId: ''
    }
  },
  created(){
    this.showCookie();
  },
  methods:{
  	getUserInformation(){
      window.location.href='/api';
    },
    showCookie(){
      //console.log(this.$cookies.keys());
      this.stuId = this.$cookies.get("stuId");
      this.name = this.$cookies.get("name");
      this.name = new Buffer(this.name, 'base64').toString('UTF8');
      //this.name = iconv.decode(this.name, 'UTF8');
    }
  }
}
</script>

<style>
.container{
  padding-top: 60px;
}
</style>