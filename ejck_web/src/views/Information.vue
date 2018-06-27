<template>
  <div>
  <my-navbar></my-navbar>
  <div class="container">
    <body>
    <h1 align="left">信息完善</h1>
    <hr>
    <div v-if="form.stuId=='' || form.stuId == undefined">
      <b-alert show variant="warning">你在开玩笑吗？你还没有登陆！！！</b-alert>
      <hr>
      jAccount入口：<b-button @click="getUserInformation" variant="primary">点击登陆</b-button>

    </div>
    <div v-else>
      <div v-if="submitted">提交成功!</div>
      <b-form @submit="onSubmit" @reset="onReset" v-if="show">
      
        <b-form-group id="nameInputGroup"
                      label="姓名:"
                      label-for="nameInput">
          <b-form-input id="nameInput"
                        type="text"
                        v-model="form.name"
                        required
                        disabled
                        >
          </b-form-input>
        </b-form-group>

        <b-form-group id="studentIdInputGroup"
                      label="学号:"
                      label-for="studentIdInput">
          <b-form-input id="studentIdInput"
                        type="text"
                        v-model="form.stuId"
                        required
                        disabled
                        >
          </b-form-input>
        </b-form-group>

        <!--
        <b-form-group id="academyInputGroup"
                      label="学院:"
                      label-for="academyInput">
          <b-form-select id="academyInput"
                        :options="academies"
                        required
                        v-model="form.academy">
          </b-form-select>
        </b-form-group>
      -->

        <b-form-group id="classInputGroup"
                      label="班级:"
                      label-for="classInput">
          <b-form-input id="classInput"
                        type="text"
                        v-model="form.class"
                        required
                        placeholder="班级,如F1603022">
          </b-form-input>
        </b-form-group>

        <b-button type="submit">提交信息</b-button>
        <b-button type="reset" variant="danger">重置表格</b-button>
      </b-form>
        <b-modal id="submitInfo" hide-footer title="提交信息">
        <div class="d-block text-center">
        提交成功!
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

export default {
  name: 'information',
  components: {'my-navbar': Navbar},
  data () {
    return {
      form: {
        class: this.$cookies.get('class'),
        name: '',
        stuId: '',
        academy: null,
        checked: []
      },
      academies: [
        { text: '选择一个学院', value: null },
        '电子信息与电气工程学院', '机械与动力工程学院', '船舶海洋与建筑工程学院', '致远学院'
      ],
      show: true,
      submitted: false
    }
  },
  created(){
    this.showCookie();
  },
  methods: {
    getUserInformation(){
      window.location.href='/api';
    },
    onSubmit (evt) {
      var submitted = {
        name: this.form.name,
        stuId: this.form.stuId,
        class: this.form.class
      };
      this.$cookies.set("class",submitted.class);
      ajax.ajaxPost('/api/update_student_information',submitted);
      evt.preventDefault();
      alert('成功提交!');
    },
    onReset (evt) {
      evt.preventDefault();
      /* Reset our form values */
      this.$cookies.set('class','');
      this.form.class = '';
      //this.form.name = '';
      //this.form.stuId = '';
      this.form.academy = null;
      this.form.checked = [];
      /* Trick to reset/clear native browser form validation state */
      this.show = false;
      this.$nextTick(() => { this.show = true });
    },
    showCookie(){
      //console.log(this.$cookies.keys());
      this.form.stuId = this.$cookies.get("stuId");
      var name = this.$cookies.get("name");
      this.form.name = new Buffer(name, 'base64').toString('UTF8');
    }
  }
}
</script>

<style>
.container{
  padding-top: 60px;
}
</style>
