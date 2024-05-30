from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import repository.connection

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/submit/")
async def handle_form(request: Request, username: str = Form(...), password: str = Form(...)):
    
    resultado = await repository.connection.check_credentials(username, password)
    if resultado:
        return templates.TemplateResponse("index.html", {"request": request, "message": "Login realizado com sucesso"})
    else:
        return templates.TemplateResponse("index.html", {"request": request, "message": "Login não foi realizado"})