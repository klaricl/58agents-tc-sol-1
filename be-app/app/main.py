import psycopg2
import datetime

from psycopg2.extras import RealDictCursor
from typing import Union
from pydantic import BaseModel
from fastapi import FastAPI

app = FastAPI(root_path="/api")

class Msg(BaseModel):
    name: str
    email: str
    msg: str

@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}

@app.get("/healthcheck")
def healthcheck():
    return {"msg": "App API is up and running!!!!!"}

@app.post("/messages/send")
async def post_msg(msg: Msg):
    print("{} STARTING SEND".format(datetime.datetime.now().strftime("[%H:%M:%S-%d%m%Y]")))
    print(msg)
    try:
        conn = psycopg2.connect("dbname='tc' user='postgres' host='svc-db' password='postgres'")
        conn.autocommit = True
    except:
        return {"err": "Database connection error"}
    
    with conn.cursor() as dbtest_curs:
        try:
            dbtest_curs.execute("INSERT INTO messages (name, email, msg) VALUES ('{}', '{}', '{}')".format(msg.name, msg.email, msg.msg))
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            return {"err": error}

    return {
        "note": "Your message was sent!",
        "msg": msg
        }

@app.get("/messages/get")
async def get_msg():
    try:
        conn = psycopg2.connect("dbname='tc' user='postgres' host='svc-db' password='postgres'")
    except:
        return {"err": "Database connection error"}
    
    with conn.cursor(cursor_factory=RealDictCursor) as dbtest_curs:
        try:
            dbtest_curs.execute("SELECT * FROM messages")
            dbtest_rows = dbtest_curs.fetchall()
        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
            return {"err": error}
    return dbtest_rows
