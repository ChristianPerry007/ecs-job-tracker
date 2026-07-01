from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Optional
from datetime import date
import uuid

app = FastAPI(title="Job Application Tracker")

# In-memory storage for now
applications = {}

class Application(BaseModel):
    company: str
    role: str
    status: str = "applied"
    date_applied: date

@app.get("/health")
def health_check():
    return {"status": "ok"}

@app.get("/applications")
def list_applications():
    return list(applications.values())

@app.post("/applications")
def add_application(app_data: Application):
    app_id = str(uuid.uuid4())
    applications[app_id] = {"id": app_id, **app_data.dict()}
    return applications[app_id]

@app.get("/applications/{app_id}")
def get_application(app_id: str):
    if app_id not in applications:
        raise HTTPException(status_code=404, detail="Application not found")
    return applications[app_id]

@app.patch("/applications/{app_id}")
def update_status(app_id: str, status: str):
    if app_id not in applications:
        raise HTTPException(status_code=404, detail="Application not found")
    applications[app_id]["status"] = status
    return applications[app_id]
