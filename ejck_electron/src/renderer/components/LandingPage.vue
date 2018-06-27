<template>
  <div>
  <my-navbar></my-navbar>
  <div class="container">
    <body>
    <h1 align="left">确认生成书单</h1>
    <hr>
    <b-alert variant="success" show>你好，管理员大人！</b-alert>
     <b-card no-body>
      <b-tabs small card v-model="tabIndex" no-key-nav>
        <b-tab title="设置筛选条件">
            <b-form-group id="academyInputGroup"
                    label="学院:"
                    label-for="academyInput">
                <b-form-select id="academyInput"
                      :options="academies"
                      required
                      v-model="form.academy">
                </b-form-select>
             </b-form-group>

            <b-form-group id="classInputGroup"
                    label="年级:"
                    label-for="GradeInput">
                <b-form-input id="GradeInput"
                      type="text"
                      v-model="form.class"
                      required
                      placeholder="如F16">
                </b-form-input>
            </b-form-group>
            <p align="right">
            	<b-button @click="tabIndex++" variant="info">确认</b-button>
            </p>
        </b-tab>
        <b-tab title="查看班级列表">
          <b-table striped hover :items="items" :fields="fields">
            <template slot="show_details" slot-scope="row">

                <b-button size="sm"  @click.stop="jumpclass(row.item.id)" class="mr-2" variant="info">
                {{ row.detailsShowing ? '隐藏' : '展示' }}书单
                </b-button>

            </template>
          </b-table>
        </b-tab>
        <b-tab title="查看书单">

            <b-card>

                <b-table striped hover :items="classitems" :fields="bookfields">
                    <template slot="action" slot-scope="row">
                        <!--b-button size="sm" @click.stop="row.toggleDetails" class="mr-2" variant="info">
                        添加教材
                        </b-button-->
                       <b-btn size="sm" v-b-modal="'CS_'+row.index" variant="primary">添加</b-btn>
                       <b-modal :id="'CS_'+row.index" title="书籍添加">
                            <p class="my-4">{{classitems[row.index].course}}添加教材：</p>
                                <b-form-group id="booknameInputGroup"
                                            label="书名:"
                                            label-for="booknameInput">
                                <input id="booknameInput" type="text" v-model="bookname" size="50">
                                </b-form-group>

                                <b-form-group id="bookEditionInputGroup"
                                            label="版次:"
                                            label-for="bookEditionInput">
                                <input id="booknameInput" type="text" v-model="bookedition" size="50">

                                </b-form-group>

                                <b-form-group id="bookAuthorInputGroup"
                                            label="作者:"
                                            label-for="bookAuthorInput">
                                <input id="booknameInput" type="text" v-model="bookauthor" size="50">

                                </b-form-group>

                                <b-form-group id="bookPublisherInputGroup"
                                            label="出版社:"
                                            label-for="bookPublisherInput">
                                <input id="booknameInput" type="text" v-model="bookpublisher" size="50">

                                </b-form-group>

                                <b-form-group id="detailInformationInputGroup"
                                            label="详细信息:"
                                            label-for="detailInformationInput">
                                <input id="booknameInput" type="text" v-model="bookdetailInformation" size="50">

                                </b-form-group>

                                <b-form-group id="bookpriceInputGroup"
                                            label="价格:"
                                            label-for="bookPriceInput">
                                <input id="booknameInput" type="text" v-model="bookprice" size="50">

                                </b-form-group>
                        <div slot="modal-footer">
                        <b-btn variant="primary" @click="addBook(row.index,'CS_'+row.index)">添加</b-btn>
                        </div>
                        </b-modal>
                                        
                    </template>
                    <template slot="show_details" slot-scope="row">
                        <b-button size="sm" @click.stop="row.toggleDetails" class="mr-2" variant="info">
                        {{ row.detailsShowing ? '隐藏' : '展示' }}
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
                        </b-card>
                    </template>


                    <template slot="deletaction" slot-scope="row">
                        <!--b-btn v-b-modal="'BK_'+i" variant="outline-success">{{book['name']}}</b-btn-->
                        <b-btn size="sm" v-b-modal="'BK_'+row.index" variant="warning">修改</b-btn>
                            <b-modal :id="'BK_'+row.index" title="书籍修改">
                                <b-form-group id="booknameInputGroup"
                                            label="书名:"
                                            label-for="booknameInput">
                                                          

                                <input id="booknameInput" type="text" v-model="classitems[row.index]['name']" size="50">
                                </b-form-group>


                                <b-form-group id="bookEditionInputGroup"
                                            label="版次:"
                                            label-for="bookEditionInput">
                                <input id="booknameInput" type="text" v-model="classitems[row.index]['edition']" size="50">       
                                </b-form-group>

                                <b-form-group id="bookAuthorInputGroup"
                                            label="作者:"
                                            label-for="bookAuthorInput">
                                <input id="booknameInput" type="text" v-model="classitems[row.index]['authors']" size="50">
                                </b-form-group>

                                <b-form-group id="bookPublisherInputGroup"
                                            label="出版社:"
                                            label-for="bookPublisherInput">
                                <input id="booknameInput" type="text" v-model="classitems[row.index]['publisher']" size="50">
                                </b-form-group>

                                <b-form-group id="detailInformationInputGroup"
                                            label="详细信息:"
                                            label-for="detailInformationInput">
                                <input id="booknameInput" type="text" v-model="classitems[row.index]['detailinformation']" size="50">       
                            	</b-form-group>

                                <b-form-group id="detailInformationInputGroup"
                                            label="价格:"
                                            label-for="detailInformationInput">
                                <input id="booknameInput" type="text" v-model="classitems[row.index]['price']" size="50">
                                </b-form-group>

                        <div slot="modal-footer">
                        <b-btn @click="updateBook(classitems[row.index],'BK_'+row.index)">提交</b-btn>
                        </div>       
                        </b-modal>

                    </template>

                    <template slot="delete" slot-scope="row">
                        <b-button size="sm" @click="deleteBook(row.index)" class="mr-2" variant="danger">
                        删除
                        </b-button>
                    </template>
                </b-table>

            <p align="right">
              <b-button @click="tabIndex--" variant="warning">返回</b-button>
              <b-button @click="submitBookInformation" class="mr-2" variant="success">
              确认 <!--!!!!TODO,改动作链接-->
              </b-button>       
            </p>
            </b-card>
        
           
        </b-tab>
      </b-tabs>
    </b-card>

   
    
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
      tabIndex: 0,
      form: {
        academy: null,
        checked: []
      },
      academies: [
        { text: '选择一个学院', value: null },
        '电子信息与电气工程学院', '机械与动力工程学院', '船舶海洋与建筑工程学院', '致远学院'
      ],
      fields: [{key:'id',label:'班号'},
                 {key:'show_details',label:'展示书单'}
      ],
      
      items:  [],
      bookfields: [{key:'course',label:'课名'},
              {key:'name',label:'书名'},
              {key:'author',label:'第一作者'},
              {key:'publisher',label:'出版社'},
              {key:'price',label:'价格'},
              {key:'show_details',label:'详细信息'},
              {key:'action',label:'添加'},
              {key:'deletaction',label:'修改'},
              {key:'delete',label:'删除'}
              ],
      classitems:  [ //一个班级
      ],
      nums: [1,2],
      stuId: '',
      name: '',
      class: '',
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! add book
      bookname: '',
      bookpublisher: '',
      bookedition: '',
      bookauthor: '',
      bookdetailInformation: '',
      bookprice: '',
      //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    }
  },
  created(){
    this.showCookie();
    this.fetchBookInformation();
  },
  methods:{
    showCookie(){
      //console.log(this.$cookies.keys());
    },
    fetchBookInformation(){
      ajax.ajaxGet('http://101.132.153.104:8888/api/get_classes', res=>{
        this.items = res.data;
      });
    },
    addBook(index, modal_index){
      var curbook = {};
      curbook['name'] = this.bookname;
      curbook['authors'] = this.bookauthor;
      curbook['edition'] = this.bookedition;
      curbook['publisher'] = this.bookpublisher;
      curbook['detailInformation'] = this.bookdetailInformation;
      //curbook['bsid'] = courseitem.bsid
      curbook['course'] = this.classitems[index].course;
      curbook['price'] = this.bookprice;
      this.classitems.push(curbook);
      this.name = '';
      this.authors = '';
      this.edition = '';
      this.publisher = '';
      var book_to_add = {book: curbook, 'courseid':this.classitems[index].bsid};
      console.log(this.classitems[index]);
      ajax.ajaxPost('http://101.132.153.104:8888/api/save_course_books', book_to_add, res=>{
        var len = this.classitems[index].books.length;
        this.classitems[index].books[len-1]['bookid'] = res.data.id;
        this.hideModal(modal_index);
      });
    },
    updateBook(book, modal_index){
      book['id'] = book['bid'];
      ajax.ajaxPost('http://101.132.153.104:8888/api/update_course_books', book, res=>{
      	this.hideModal(modal_index);
      }); ///!!!!!!!!!!!!!!这里多了bsid
    },
    submitBookInformation(){
      var books = this.classitems.map(x=>{return {bookid:x.bid, class:this.class};});
      ajax.ajaxPost('http://101.132.153.104:8888/api/save_class_books', books);
      alert('成功提交！');
    },
    jumpclass(id){
        this.class = id;
        ajax.ajaxGetWithParam('http://101.132.153.104:8888/api/get_class_candidate_books', {params:{'class':id}}, res=>{
        this.classitems = res.data;
        //this.nums = res.data.map(x=>x.num);
        this.tabIndex++;
      });
    },
    hideModal(id){
      this.$root.$emit('bv::hide::modal',id);  //发消息关掉模态框
    },
    deleteBook(index){
      var bookid = this.classitems[index].bid;
      ajax.ajaxPost('http://101.132.153.104:8888/api/delete_course_books',{bookid:bookid}, res=>{
        this.classitems.splice(index,1);
        alert(bookid+'!');
      });
      
    },

  }
}
</script>

<style>
.container{
  padding-top: 60px;
}
</style>