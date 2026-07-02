from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import date
import uuid
import psycopg2
import psycopg2.extras
import os

app = FastAPI(title="Job Application Tracker")

def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        port=os.environ.get("DB_PORT", "5432")
    )

def init_db():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS applications (
            id UUID PRIMARY KEY,
            company VARCHAR(255) NOT NULL,
            role VARCHAR(255) NOT NULL,
            status VARCHAR(50) DEFAULT 'applied',
            date_applied DATE NOT NULL
        )
    """)
    conn.commit()
    cur.close()
    conn.close()

class Application(BaseModel):
    company: str
    role: str
    status: str = "applied"
    date_applied: date

@app.on_event("startup")
async def startup_event():
    init_db()

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/applications")
def list_applications():
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT * FROM applications")
    applications = cur.fetchall()
    cur.close()
    conn.close()
    return list(applications)

@app.post("/applications")
def add_application(app_data: Application):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    app_id = str(uuid.uuid4())
    cur.execute(
        "INSERT INTO applications (id, company, role, status, date_applied) VALUES (%s, %s, %s, %s, %s) RETURNING *",
        (app_id, app_data.company, app_data.role, app_data.status, app_data.date_applied)
    )
    new_app = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    return new_app

@app.get("/applications/{app_id}")
def get_application(app_id: str):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute("SELECT * FROM applications WHERE id = %s", (app_id,))
    application = cur.fetchone()
    cur.close()
    conn.close()
    if not application:
        raise HTTPException(status_code=404, detail="Application not found")
    return application

@app.patch("/applications/{app_id}")
def update_status(app_id: str, status: str):
    conn = get_db_connection()
    cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    cur.execute(
        "UPDATE applications SET status = %s WHERE id = %s RETURNING *",
        (status, app_id)
    )
    updated = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()
    if not updated:
        raise HTTPException(status_code=404, detail="Application not found")
    return updated