<template>
  <div>
  <my-navbar></my-navbar>
  <div class="container">
    <body>
    <h1 align="left">班级选书</h1>
    <hr>
    <div v-if="stuId=='' || stuId == undefined">
    	<b-alert show variant="warning">你在开玩笑吗？你还没有登陆！！！</b-alert>
    	<hr>
    	jAccount入口：<b-button @click="getUserInformation" variant="primary">点击登陆</b-button>

    </div>
    <div v-else>
	    <b-alert show variant="success">{{name}}班长（学号：{{stuId}}），欢迎选书！</b-alert>
	    <!--
	    <b-btn v-b-popover.hover="'I am popover content!'" title="Popover Title">aaa</b-btn>
	    -->
	    <b-table striped hover :items="items" :fields="fields">
	      <template slot="show_details" slot-scope="row">
	        <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2" variant="info">
	          {{ row.detailsShowing ? '隐藏' : '展示' }}信息
	        </b-button>
	      </template>

	      <template slot="row-details" slot-scope="row">
	        <b-card>
	          <b-row class="mb-2">
	            <b-col sm="3" class="text-sm-right"><b>全部作者:</b></b-col>
	            <b-col>{{ row.item.authors }}</b-col>
	          </b-row>
	          <b-row class="mb-2">
	            <b-col sm="3" class="text-sm-right"><b>其他描述:</b></b-col>
	            <b-col>{{ row.item.detailInformation }}</b-col>
	          </b-row>
	          <b-row class="mb-2">
	            <b-col sm="3" class="text-sm-right"><b>已选同学:</b></b-col>
	            <b-col>{{ row.item.selected }}</b-col>
	          </b-row> 
	        </b-card>
	      </template>
	      <template slot="action" slot-scope="row">
	        <b-form-input size="sm" v-model="nums[row.index]"
	          type="text"
	          placeholder="0"
	          style="width:45px"></b-form-input>
	      </template>
	    </b-table>
	    <p align="right">
	    <b-button v-b-modal="'submitBook'">提交书单</b-button>
	    <b-button v-b-modal="'cache'" variant="warning">暂存书单</b-button>
	    </p>
      <b-modal id="submitBook" hide-footer title="提交信息">
      <div class="d-block text-center">
      提交成功!
    </div>
  </b-modal>
      
      <b-modal id="cache" hide-footer title="提交信息">
      <div class="d-block text-center">
      暂存成功!
    </div>
    </b-modal>
	</div>
    </body>
  </div>
</div>
</template>

<script>
import Navbar from './Navbar.vue'
import ajax from '../ajax'
import ip from '../../ip'
/*
const items = [
  { name: '信号与系统', author: '奥本海姆', authors: 'Alan V. Oppenheim, S.Wilsky', selected: '柳旭东', publisher: '机械工业出版社', price: '99', detailInformation:'Hello world.' },
  { name: '计算机组成', author: '戴维·帕特森', authors: 'David Patterson, John Hennesey', selected: '柳旭东', publisher: '电子工业出版社', price: '80', detailInformation:'Hello world.' }
]
*/
export default {
  name: 'selectbook',
  components: {'my-navbar': Navbar},
  data () {
    return {
      fields: [{key:'name',label:'书名'},
              {key:'author',label:'第一作者'},
              {key:'publisher',label:'出版社'},
              {key:'price',label:'价格'},
              {key:'show_details',label:'详细信息'},
              {key:'action',label:'数量'}],
      items: [],
      nums: [],
      stuId: '',
      name: '',
      class: ''
    }
  },
  created(){
    this.showCookie();
    this.getClassBooks();
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
      this.class = this.$cookies.get("class");
    },
    getClassBooks(){
      ajax.ajaxGetWithParam('/api/get_class_books', {params:{'class':this.class}}, res=>{
        this.items = res.data;
        this.nums = res.data.map(x=>x.num);
      });
    }
  }
}
</script>

<style>
/*
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
},
*/
.container{
  padding-top: 60px;
}
</style>
