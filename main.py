from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI()

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/submit/")
async def handle_form(request: Request, username: str = Form(...), password: str = Form(...)):
    # Aqui você pode processar os dados do formulário

    print(f"Username: {username}, Password: {password}")
    if username == "admin" and password == "admin":
        return templates.TemplateResponse("result.html", {"request": request, "username": username, "password": password})
    
    error_message = "Credenciais incorretas. Tente novamente."
    return templates.TemplateResponse("index.html", {"request": request, "error_message": error_message})    
