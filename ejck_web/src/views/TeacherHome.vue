<template>
  <div>
  <my-navbar></my-navbar>
  <div class="container">
    <body>
    <h1 align="left">课程书籍设置</h1>
    <hr>
    <div v-if="teacherId=='' || teacherId == undefined">
      <b-alert show variant="warning">您还未登陆，请登录！</b-alert>
      <hr>
      jAccount入口：<b-button @click="getUserInformation" variant="primary">点击登陆</b-button>

    </div>
    <div v-else-if="stuId!='516030910534' && (teacherId == '*')">
      <b-alert show variant="danger">你根本不是老师！！！</b-alert>
    </div>
    <div v-else>
      <b-alert show variant="success">{{name}}老师（工号：{{teacherId}}），欢迎回来！</b-alert>
      <!--
      <b-btn v-b-popover.hover="'I am popover content!'" title="Popover Title">aaa</b-btn>
      -->
      <div role="tablist">
      <b-card v-for="item in items" no-body class="mb-1">
        <b-card-header header-tag="header" class="p-1" role="tab">
          <!--NOTE: no ':' before v-b-toggle-->
          <b-btn block href="#" v-b-toggle="'panel_'+item['bsid']">{{item['name']}}</b-btn>
        </b-card-header>
        <b-collapse :id="'panel_'+item['bsid']" role="tabpanel">
          <b-card-body>
            <p>课程bsid:&nbsp;{{item['bsid']}}</p>
            <p>课号:&nbsp;{{item['code']}}</p>
            <p>已分配教材:
              <b-col sm="4" v-for="(book,i) in item.books">
                <b-btn v-b-modal="'BK_'+i" variant="outline-success">{{book['name']}}</b-btn>
                <b-modal :id="'BK_'+i" title="书籍修改">
                  <b-form-group id="booknameInputGroup"
                                label="书名:"
                                label-for="booknameInput">
                    <b-form-input id="booknameInput"
                                  type="text"
                                  v-model="book['name']"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookEditionInputGroup"
                                label="版次:"
                                label-for="bookEditionInput">
                    <b-form-input id="bookEditionInput"
                                  type="text"
                                  v-model="book['edition']"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookAuthorInputGroup"
                                label="作者:"
                                label-for="bookAuthorInput">
                    <b-form-input id="bookAuthorInput"
                                  type="text"
                                  v-model="book['authors']"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookPublisherInputGroup"
                                label="出版社:"
                                label-for="bookPublisherInput">
                    <b-form-input id="bookPublisherInput"
                                  type="text"
                                  v-model="book['publisher']"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="detailInformationInputGroup"
                                label="详细信息:"
                                label-for="detailInformationInput">
                    <b-form-input id="detailInformationInput"
                                  type="text"
                                  v-model="detailInformation"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>
            <div slot="modal-footer">
            <b-btn @click="updateBook(book);hideModal('BK_'+i);">提交</b-btn>
            <b-btn @click="deleteBook(book.id)" variant="danger">删除</b-btn>
            </div>       
          </b-modal>

              </b-col>
            </p>
            <!--Note: the ':' before v-b-modal cannot be omitted-->
            <b-btn v-b-modal="item['bsid']" variant="info">添加教材</b-btn>
            
            <b-modal :id="item['bsid']" title="书籍添加">
              <p class="my-4">当前为《{{item['name']}}》添加教材：</p>
                  <b-form-group id="booknameInputGroup"
                                label="书名:"
                                label-for="booknameInput">
                    <b-form-input id="booknameInput"
                                  type="text"
                                  v-model="bookname"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookEditionInputGroup"
                                label="版次:"
                                label-for="bookEditionInput">
                    <b-form-input id="bookEditionInput"
                                  type="text"
                                  v-model="bookedition"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookAuthorInputGroup"
                                label="作者:"
                                label-for="bookAuthorInput">
                    <b-form-input id="bookAuthorInput"
                                  type="text"
                                  v-model="bookauthor"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="bookPublisherInputGroup"
                                label="出版社:"
                                label-for="bookPublisherInput">
                    <b-form-input id="bookPublisherInput"
                                  type="text"
                                  v-model="bookpublisher"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>

                  <b-form-group id="detailInformationInputGroup"
                                label="详细信息:"
                                label-for="detailInformationInput">
                    <b-form-input id="detailInformationInput"
                                  type="text"
                                  v-model="detailInformation"
                                  required
                                  >
                    </b-form-input>
                  </b-form-group>
            <div slot="modal-footer">
            <b-btn variant="primary" @click="addBook(item);hideModal(item['bsid']);">添加</b-btn>
            </div>
            </b-modal>

          </b-card-body>
        </b-collapse>
      </b-card>
      </div>

      </p>
    </div>
    </body>
  </div>
</div>
</template>

<script>
import Navbar from './Navbar.vue'
import ajax from '../ajax'
export default {
  name: 'selectbook',
  components: {'my-navbar': Navbar},
  data () {
    return {
      text: 'hello!',
      items:  [
        //{name:'电路与电子学', bsid:'1', code:'EI234', books:[]},
        //{name:'计算机组成', bsid:'2', code:'EI332', books:[]}
      ],
      nums: [0,0],
      teacherId: '',
      stuId: '',
      name: '',
      bookname: '',
      bookpublisher: '',
      bookedition: '',
      bookauthor: '',
      detailInformation: ''
    }
  },
  created(){
    this.showCookie();
    this.fetchTeacherInformation();
  },
  methods:{
    getUserInformation(){
      window.location.href='/api';
    },
    showCookie(){
      //console.log(this.$cookies.keys());
      this.teacherId = this.$cookies.get("teacherId");
      this.stuId = this.$cookies.get("stuId");
      this.name = this.$cookies.get("name");
      this.name = new Buffer(this.name, 'base64').toString('UTF8');
    },
    fetchTeacherInformation(){
      ajax.ajaxGetWithParam('/api/get_teacher_information', {params:{teacherId:'516030910534'}}, res=>{
        this.items = res.data;
      });
    },
    onSubmit(){},
    onReset(){},
    addBook(courseItem){
      var curbook = {};
      curbook['name'] = this.bookname;
      curbook['authors'] = this.bookauthor;
      curbook['edition'] = this.bookedition;
      curbook['publisher'] = this.bookpublisher;
      curbook['detailInformation'] = this.detailInformation;
      courseItem.books.push(curbook);
      this.name = '';
      this.authors = '';
      this.edition = '';
      this.publisher = '';
      var book_to_add = {book: curbook, courseid:courseItem.bsid};
      ajax.ajaxPost('/api/save_course_books', book_to_add, res=>{
        var len = courseItem.books.length;
        courseItem.books[len-1]['id'] = res.data.id;
      });
      alert('成功添加!');
    },
    updateBook(book){
      ajax.ajaxPost('/api/update_course_books', book);
      alert('成功提交!');
    },
    deleteBook(bookid){
      ajax.ajaxPost('/api/delete_course_books',{bookid:bookid});
      window.location.href='/teacher';
      alert('成功提交!');
    },
    hideModal(id){
      this.$root.$emit('bv::hide::modal',id);
    }
  }
}
</script>

<style>
.container{
  padding-top: 60px;
}
</style>
