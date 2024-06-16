from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import repository.connection
import json
from models import Usuario

app = FastAPI()

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

        # Serializar o objeto resultado para JSON
        resultado_json = json.dumps({
            "user_id": resultado.user_id,
            "username": resultado.username,
            "cargo": resultado.cargo,
            "eh_lider_faccao": resultado.eh_lider_faccao
        })

        # Definir o cookie
        response.set_cookie(key="user_data", value=resultado_json, path="/")

        
        return templates.TemplateResponse("index.html", {"request": request, "message": "Login realizado com sucesso"})
    else:
        return templates.TemplateResponse("index.html", {"request": request, "message": resultado})

