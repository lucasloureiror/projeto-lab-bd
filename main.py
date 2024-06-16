from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import RedirectResponse
import repository.connection
from models import Usuario

app = FastAPI()

usuario:Usuario

origins = [
    "http://localhost",
    "http://localhost:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

templates = Jinja2Templates(directory="templates")

@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/submit/")
async def handle_form(request: Request, response: Response, username: str = Form(...), password: str = Form(...)):
    
    resultado = await repository.connection.check_credentials(username, password)

    # Login bem-sucedido se a função retornar um ID válido
    if isinstance(resultado, Usuario):
        print("Usuario logado: {", resultado.user_id, ",", resultado.username, ",", resultado.cargo, ",", resultado.eh_lider_faccao, "}")
        global usuario
        usuario = resultado
        
        return RedirectResponse("/overview")
    else:
        return templates.TemplateResponse("index.html", {"request": request, "message": resultado})

@app.post("/overview")
async def read_overview(request: Request, response: Response):
    return templates.TemplateResponse("overview.html", {"request": request, "usuario": usuario})

@app.get("/action")
async def action():
    return {"message": "Ação executada!"}