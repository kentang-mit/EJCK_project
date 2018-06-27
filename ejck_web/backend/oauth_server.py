from flask import Flask, redirect, url_for, session, request, jsonify
from flask_oauthlib.client import OAuth
from flask_cors import *
from functools import wraps
from flask import make_response
import base64
from dbconnection import *
import json

app = Flask(__name__)
CORS(app, supports_credentials=True)
app.debug = True
app.secret_key = 'development'
oauth = OAuth(app)

backend_ip = 'http://101.132.153.104'
#backend_ip = 'http://0.0.0.0:88'  #local test

sjtu = oauth.remote_app(
    'sjtu',
    consumer_key='863rEoGllxma33KvSnjP',
    consumer_secret='1FBFC8AE7091FB38082F7C7A0DA83743FD103875791A4989',
    request_token_params={'scope': ['essential','lessons']},
    base_url='https://jaccount.sjtu.edu.cn/',
    request_token_url=None,
    access_token_method='POST',
    access_token_url='/oauth2/token',
    authorize_url='/oauth2/authorize'
)

dbObject = dbHandle()
#cursor = dbObject.cursor()

class JSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o,'Decimal'):
            return str(o)
        return json.JSONEncoder.default(self,o)

app.json_encoder = JSONEncoder
@app.route('/api')
def index():
    if 'token' in session:
        me = sjtu.get('https://api.sjtu.edu.cn/v1/me/profile')
        data = jsonify(me.data)
        response = make_response(redirect(backend_ip))
        response.set_cookie('data', data)
        return response
    return redirect(url_for('login'))


@app.route('/api/login')
def login():
    print("login")
    #modified
    return sjtu.authorize(callback=url_for('authorized', _external=True))


@app.route('/api/logout')
def logout():
    session.pop('sjtu_token', None)
    return redirect(url_for('index'))


@app.route('/api/login/authorized')
def authorized():
    cursor = dbObject.cursor()
    resp = sjtu.authorized_response()
    if resp is None or resp.get('access_token') is None:
        return 'Access denied: reason=%s error=%s resp=%s' % (
            request.args['error'],
            request.args['error_description'],
            resp
        )
    session['sjtu_token'] = (resp['access_token'], '')
    me = sjtu.get('https://api.sjtu.edu.cn/v1/me/profile')
    #data = jsonify(me.data)
    data = me.data
    response = make_response(redirect(backend_ip))
    curname = data['entities'][0]['name']
    curname_array = bytes(curname, encoding='utf8')
    curname_encoded = base64.b64encode(curname_array)
    curcode = data['entities'][0]['code']
    curacademy = data['entities'][0]['organize']['id']
    curJAccount = data['entities'][0]['account']
    curType = data['entities'][0]['userType']
    sql = 'INSERT IGNORE INTO Student(stuId, jAccount, name, schoolid) values(%s,%s,%s,%s)'    
    cursor.execute(sql,(curcode, curJAccount, curname, curacademy))
    dbObject.commit()
    response.set_cookie('name', curname_encoded)
    response.set_cookie('academy', curacademy)
    if curType == 'student':
        response.set_cookie('stuId', curcode)
        response.set_cookie('teacherId', '*')
    else:
        response.set_cookie('stuId', '*')
        response.set_cookie('teacherId', curcode)

    cursor.close()
    #response = make_response(jsonify(data))
    #response.set_cookie('name',data['entities'][0]['name'])
    return response

@sjtu.tokengetter
def get_github_oauth_token():
    return session.get('sjtu_token')


@app.route('/api/login/teacher_authorized')
def teacher_authorized():
    cursor = dbObject.cursor()
    resp = sjtu.authorized_response()
    if resp is None or resp.get('access_token') is None:
        return 'Access denied: reason=%s error=%s resp=%s' % (
            request.args['error'],
            request.args['error_description'],
            resp
        )

    session['sjtu_token'] = (resp['access_token'], '')
    me = sjtu.get('https://api.sjtu.edu.cn/v1/me/profile')
    #data = jsonify(me.data)
    data = me.data
    curname = data['entities'][0]['name']
    curname_array = bytes(curname, encoding='utf8')
    curname_encoded = base64.b64encode(curname_array)
    curcode = data['entities'][0]['code']
    curacademy = data['entities'][0]['organize']['id']
    sql = 'INSERT IGNORE INTO Teacher(workId, name, schoolid) values(%s,%s,%s)'    
    cursor.execute(sql,(curcode, curname, curacademy))
    dbObject.commit()


    me = sjtu.get('https://api.sjtu.edu.cn/v1/me/lessons?access_token='+resp['access_token'])
    data = me.data['entities']
    sql = 'INSERT IGNORE INTO Course(bsid,name,code) values'
    course_tup = []
    for x in data:
        sql += "(%s,%s,%s),"
        cur_bsid = x['bsid']
        cur_code = x['course']['code']
        cur_name = x['course']['name']
        course_tup.append(cur_bsid)
        course_tup.append(cur_name)
        course_tup.append(cur_code)
    sql = sql[:-1]
    cursor.execute(sql, course_tup)
    dbObject.commit()

    sql = 'SELECT * from CourseTeacher where teacherid=%s'
    cursor.execute(sql,curcode)
    dic = cursor.fetchall()
    if len(dic) != 0:
        sql = 'UPDATE CourseTeacher SET courseid=%s where teacherid=%s'
    else:
        sql = 'REPLACE INTO CourseTeacher(courseid, teacherid) values'    
        course_teacher_tup = []
        for x in data:
            sql += "(%s,%s),"
            cur_course = x['bsid']
            course_teacher_tup.append(cur_course)
            course_teacher_tup.append(curcode)
        sql = sql[:-1]  
        course_teacher_tup = tuple(course_teacher_tup)
        cursor.execute(sql, course_teacher_tup)
        dbObject.commit()
    cursor.close()
    return str(data)

@app.route('/api/get_classes')
def get_classes():
    cursor = dbObject.cursor()
    sql = 'SELECT name from Class'
    cursor.execute(sql)
    dic = cursor.fetchall()
    dic = list(map(lambda x: {'id':x['name']}, dic))
    cursor.close()
    return jsonify(dic)

@app.route('/api/get_student_books')
def get_student_books():
    cursor = dbObject.cursor()
    curStuId = request.args.get('stuId')
    curClass = request.cookies.get('class')
    if curClass is not None:
        sql = 'UPDATE Student SET classid=%s WHERE stuid=%s'
        cursor.execute(sql, (curClass, curStuId))
        dbObject.commit()
    
    sql = 'SELECT bc.bookid from BookClass as bc JOIN Student as s WHERE bc.classid=s.classid AND s.stuid=%s;'
    cursor.execute(sql,curStuId)
    dic = cursor.fetchall()
    if dic is  None:
        sql = 'SELECT bc.bookid,bc.num from BookClass as bc JOIN Student as s ON s.id=%s WHERE bc.classid=s.classid'
        cursor.execute(sql, curStuId)
        dic = cursor.fetchall()

    sql = 'SELECT bookid,num from StudentBook WHERE studentid=%s'
    cursor.execute(sql,curStuId)
    num_dic_ = cursor.fetchall()
    num_dic = {}
    for x in num_dic_:
        num_dic[x['bookid']] = x['num']


    sql = 'SELECT b.id as bid, b.name, b.edition, b.publisher, c.name as course, b.price, b.detailInformation,'+\
    'GROUP_CONCAT(ba.author) as authors '+\
    'from Book as b '+\
    'JOIN BookAuthor as ba '+\
    'JOIN CourseBook as cb '+\
    'JOIN Course as c on b.id=ba.bookid '+\
    'and b.id=cb.bookid and c.bsid=cb.courseid '+\
    'WHERE b.id in ('
    tup_bid = []
    for x in dic:
        sql += '%s,'
        tup_bid.append(x['bookid'])

    sql = sql[:-1]
    sql += ') GROUP BY bid,c.name;'

    f = open('log.txt','w')
    f.write(str(num_dic))
    f.close()

    tup_bid = tuple(tup_bid)
    cursor.execute(sql, tup_bid)

    inf_dic = cursor.fetchall()
    for i in range(len(inf_dic)):
        inf_dic[i]['price'] = str(inf_dic[i]['price'])
        inf_dic[i]['author'] = inf_dic[i]['authors'].split(',')[0]
        inf_dic[i]['num'] = int(num_dic.get(inf_dic[i]['bid'],0))
    cursor.close()
    return jsonify(inf_dic)

@app.route('/api/get_notification')
def get_notification():
    cursor = dbObject.cursor()
    sql = 'SELECT title,Content From Notification'
    cursor.execute(sql)
    dic = cursor.fetchall()
    cursor.close()
    return jsonify(dic)

@app.route('/api/get_class_books')
def get_class_books():
    cursor = dbObject.cursor()
    curclassId = request.args.get('class')
    sql = 'SELECT bookid, num from BookClass WHERE classid=%s;'

    #f = open('log.txt','w')
    #f.write(str(request.data))
    #f.close()

    cursor.execute(sql,curclassId)
    dic = cursor.fetchall()

    sql = 'SELECT b.id as bid, b.name, b.edition, b.publisher, c.name as course, b.price, b.detailInformation,'+\
    'GROUP_CONCAT(ba.author) as authors '+\
    'from Book as b '+\
    'JOIN BookAuthor as ba '+\
    'JOIN CourseBook as cb '+\
    'JOIN Course as c on b.id=ba.bookid '+\
    'and b.id=cb.bookid and c.bsid=cb.courseid '+\
    'WHERE b.id in ('
    tup_bid = []
    tup_num = []
    for x in dic:
        sql += '%s,'
        tup_bid.append(x['bookid'])
        tup_num.append(x['num'])
    sql = sql[:-1]
    sql += ') GROUP BY bid,c.name;'

    f = open('log.txt','w')
    f.write(sql)
    f.close()

    tup_bid = tuple(tup_bid)

    cursor.execute(sql, tup_bid)
    inf_dic = cursor.fetchall()
    for i in range(len(inf_dic)):
        inf_dic[i]['price'] = str(inf_dic[i]['price'])
        inf_dic[i]['author'] = inf_dic[i]['authors'].split(',')[0]
        inf_dic[i]['num'] = int(dic[i]['num'])
    cursor.close()
    return jsonify(inf_dic)

@app.route('/api/save_class_books', methods=['POST'])
def save_class_books():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    #f = open('log.txt','w')
    #f.write(str(data))
    #f.close()
    if len(data) == 0:
        return jsonify({'code':200})

    sql = 'DELETE from BookClass where classid=%s'
    cursor.execute(sql, data[0]['class'])
    dbObject.commit()

    sql = 'INSERT INTO BookClass(classid,bookid) VALUES'
    tup = []
    for x in data:
        sql += '(%s,%s),'
        tup.append(x['class'])
        tup.append(x['bookid'])
    tup = tuple(tup)
    sql = sql[:-1]
    cursor.execute(sql, tup)
    dbObject.commit()
    cursor.close()
    return jsonify({'code':'200'})

@app.route('/api/get_class_candidate_books')
def get_class_candidate_books():
    cursor = dbObject.cursor()
    curclassId = request.args.get('class')
    sql = 'SELECT cb.bookid from ClassCourse as cc JOIN CourseBook as cb on cc.courseid=cb.courseid WHERE cc.classid=%s;'

    #f = open('log.txt','w')
    #f.write(str(request.data))
    #f.close()

    cursor.execute(sql,curclassId)
    dic = cursor.fetchall()
    if len(dic) == 0:
        return jsonify([])

    sql = 'SELECT b.id as bid, cb.courseid as bsid, b.name, b.edition, b.publisher, c.name as course, b.price, b.detailInformation,'+\
    'GROUP_CONCAT(ba.author) as authors '+\
    'from Book as b '+\
    'JOIN BookAuthor as ba '+\
    'JOIN CourseBook as cb '+\
    'JOIN Course as c on b.id=ba.bookid '+\
    'and b.id=cb.bookid and c.bsid=cb.courseid '+\
    'WHERE b.id in ('
    tup_bid = []
    for x in dic:
        sql += '%s,'
        tup_bid.append(x['bookid'])
    sql = sql[:-1]
    sql += ') GROUP BY bid,c.name, bsid;'

    tup_bid = tuple(tup_bid)

    cursor.execute(sql, tup_bid)
    inf_dic = cursor.fetchall()
    for i in range(len(inf_dic)):
        inf_dic[i]['price'] = str(inf_dic[i]['price'])
        inf_dic[i]['author'] = inf_dic[i]['authors'].split(',')[0]
    cursor.close()
    return jsonify(inf_dic)


@app.route('/api/update_student_information',methods=['POST'])
def update_student_information():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    curstuId = data['stuId']
    curclassId = data['class']
    sql = 'SELECT * from StudentClass where studentid=%s'
    cursor.execute(sql,curstuId)
    dic = cursor.fetchall()
    if len(dic) != 0:
        sql = 'UPDATE StudentClass SET classid=%s where studentid=%s'
    else:
        sql = 'INSERT IGNORE INTO StudentClass(classid, studentid) values(%s,%s)'    
    cursor.execute(sql, (curclassId, curstuId))
    dbObject.commit()
    cursor.close()
    return jsonify({'code':200,'message':'success'})

@app.route('/api/save_student_books', methods=['POST'])
def save_student_books():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    if len(data) == 0:
        return
    sql = 'SELECT * from StudentBook where studentid=%s'
    cursor.execute(sql, data[0]['stuId'])
    dic = cursor.fetchall()

    if len(dic) > 0:
        sql = 'DELETE from StudentBook where studentid=%s'
        cursor.execute(sql, data[0]['stuId'])
        dbObject.commit()
    
    num_dic = {}
    for x in dic:
        num_dic[x['bookid']] = x['num']

    f=open('log.txt','w')
    f.write(str(num_dic))
    f.close()
    sql = 'INSERT INTO StudentBook(bookid,studentid,num,classid) values'
    tup = []
    for x in data:
        sql += '(%s,%s,%s,%s),'
        tup.append(x['bookid'])
        tup.append(x['stuId'])
        tup.append(x.get('num',0))
        tup.append(x['class'])
    sql = sql[:-1]
    tup = tuple(tup)

    cursor.execute(sql, tup)
    dbObject.commit()


    for i in range(len(data)):
        sql = 'UPDATE BookClass SET num=num+%s WHERE bookid=%s'
        delta = int(data[i].get('num',0)) - num_dic.get(data[i]['bookid'],0)
        bookid = data[i]['bookid']
        cursor.execute(sql,(delta,bookid))
        dbObject.commit()
    cursor.close()
    return jsonify({'code':200,'message':'success'})


@app.route('/api/save_course_books', methods=['POST'])
def save_course_books():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    book = data['book']
    courseid = data['courseid']

    if book['edition'] == '':
        book['edition'] = 1

    
    sql = 'INSERT INTO Book(name,publisher,edition,detailInformation) values(%s,%s,%s,%s)'
    cursor.execute(sql, (book['name'],book['publisher'],book['edition'],book['detailInformation']))
    dbObject.commit();
    
    #TBD: should be REPLACED for efficiency concerns.
    sql = 'SELECT id FROM Book where name=%s and publisher=%s and edition=%s';
    cursor.execute(sql,(book['name'],book['publisher'],book['edition']))
    ans = cursor.fetchone()
    bookid = ans['id']

    book['authors'] = book['authors'].split(',')
    sql = 'INSERT INTO BookAuthor(bookid,author) values'
    author_tup = []
    for author in book['authors']:
        sql += '(%s,%s),'
        author_tup.append(bookid)
        author_tup.append(author)
    author_tup = tuple(author_tup)
    sql = sql[:-1]
    cursor.execute(sql,author_tup)
    dbObject.commit()

    sql = 'INSERT INTO CourseBook(bookid,courseid) values(%s,%s)'
    cursor.execute(sql,(bookid, courseid))
    dbObject.commit()
    cursor.close()
    return jsonify(ans)

@app.route('/api/update_course_books', methods=['POST'])
def update_course_books():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    sql = 'UPDATE Book SET name=%s,publisher=%s,edition=%s,detailInformation=%s,price=%s WHERE id=%s;'
    book = data
    if book['edition'] == '':
        book['edition'] = 1
    book['price'] = book.get('price','0.00')
    cursor.execute(sql,(book['name'],book['publisher'],book['edition'],book['detailInformation'],book['price'],book['id']))
    dbObject.commit()

    sql = 'DELETE FROM BookAuthor WHERE bookid=%s;'
    cursor.execute(sql,book['id'])
    dbObject.commit()

    book['authors'] = book['authors'].split(',')
    sql = 'INSERT INTO BookAuthor(bookid,author) values'
    author_tup = []
    for author in book['authors']:
        sql += '(%s,%s),'
        author_tup.append(book['id'])
        author_tup.append(author)
    author_tup = tuple(author_tup)
    sql = sql[:-1]
    cursor.execute(sql,author_tup)
    dbObject.commit()
    cursor.close()
    return jsonify({'code':'200', 'msg': 'success'})

@app.route('/api/delete_course_books', methods=['POST'])
def delete_course_books():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    sql = 'DELETE FROM BookAuthor WHERE bookid=%s;'
    cursor.execute(sql,data['bookid'])
    dbObject.commit()
    sql = 'DELETE FROM CourseBook WHERE bookid=%s;'
    cursor.execute(sql,data['bookid'])
    dbObject.commit()
    sql = 'DELETE FROM BookClass WHERE bookid=%s;'
    cursor.execute(sql,data['bookid'])
    dbObject.commit()
    sql = 'DELETE FROM Book WHERE id=%s;'
    cursor.execute(sql,data['bookid'])
    dbObject.commit()
    cursor.close()
    return 'ok'

@app.route('/api/get_teacher_information')
def get_teacher_information():
    cursor = dbObject.cursor()
    curteacherId = request.args.get('teacherId')
    sql = 'SELECT c.bsid,c.code,c.name from CourseTeacher JOIN Course as c on c.bsid=courseid where teacherid=%s'
    cursor.execute(sql,curteacherId)
    dic = cursor.fetchall()
    for i in range(len(dic)):
        bsid = dic[i]['bsid']
        sql = 'SELECT b.id,b.name,b.publisher,b.edition,b.price,b.detailInformation,' + \
            'GROUP_CONCAT(ba.author) as authors from CourseBook as cb JOIN Book as b '+\
            'JOIN BookAuthor as ba on cb.bookid=b.id and ba.bookid=b.id and cb.courseid=%s '+\
            'GROUP BY b.id,b.name,b.publisher,b.edition,b.price,b.detailInformation'
        cursor.execute(sql,bsid)
        books = cursor.fetchall()
        for k in range(len(books)):
            books[k]['price'] = str(books[k]['price'])
        dic[i]['books'] = list(books)
    f = open('log.txt','w')
    f.write(str(dic))
    f.close()
    cursor.close()
    return jsonify(dic)

@app.route('/api/get_queue')
def get_queue():
    cursor = dbObject.cursor()
    curClass = request.args.get('class')
    sql = 'SELECT id from BookQueue WHERE classid=%s'
    cursor.execute(sql, curClass)
    dic = cursor.fetchone()
    if dic is None:
        dic = {}
    curId = dic.get('id',1)
    sql = 'SELECT classid from BookQueue WHERE id < %s ORDER BY id'
    cursor.execute(sql, curId)
    dic = cursor.fetchall()
    dic = list(map(lambda x:x['classid'],dic))
    ret = {'classes': dic, 'num': len(dic)+1}
    cursor.close()
    return jsonify(ret)

@app.route('/api/get_all_queue')
def get_all_queue():
    cursor = dbObject.cursor()
    sql = 'SELECT classid, id from BookQueue ORDER BY id'
    cursor.execute(sql)
    dic = cursor.fetchall()
    dic = list(map(lambda x:x['classid'],dic))
    ret = {'classes': dic, 'num': len(dic)}
    cursor.close()
    return jsonify(ret)

@app.route('/api/push_queue', methods=['POST'])
def push_queue():
    cursor = dbObject.cursor()
    data = json.loads(str(request.data,'utf8'))
    curClass = data['class']
    #curClass = request.args.get('class')
    sql = 'INSERT IGNORE INTO BookQueue(`classid`) values(%s)'
    cursor.execute(sql, curClass)
    dbObject.commit()
    cursor.close()
    return jsonify({'code':200})

@app.route('/api/pop_queue', methods=['POST'])
def pop_queue():
    cursor = dbObject.cursor()
    sql = 'SELECT * from BookQueue ORDER BY id'
    cursor.execute(sql)
    
    try:
        dic = cursor.fetchone()
        curId = dic['id']
    except:
        dic = {}
        curId = 0

    sql = 'DELETE from BookQueue where id=%s'
    cursor.execute(sql, curId)
    dbObject.commit()
    cursor.close()
    return jsonify(dic)

if __name__ == '__main__':
    app.run(host='0.0.0.0',port=8888)
