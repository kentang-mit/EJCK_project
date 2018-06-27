import pymysql

def dbHandle():
    config = {
    'host':'127.0.0.1',
    'port':3306,
    'user':'root',
    'password':'2016JCKsql',
    'db':'EJCK',
    'charset':'utf8mb4',
    'cursorclass':pymysql.cursors.DictCursor,
    }
    conn = pymysql.connect(**config)
    return conn
