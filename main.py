from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import RedirectResponse
from starlette.status import HTTP_303_SEE_OTHER
import repository.connection
import data
from models import Usuario

app = FastAPI()

usuario:Usuario


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
        print(f"Usuario logado: [{resultado.user_id}, {resultado.username}, {resultado.nome}, {resultado.cargo}, {resultado.eh_lider_faccao}]")
        global usuario
        usuario = resultado
        
        return RedirectResponse("/overview", status_code=HTTP_303_SEE_OTHER)
    else:
        return templates.TemplateResponse("index.html", {"request": request, "message": resultado})

@app.get("/overview")
async def read_overview(request: Request):
    return templates.TemplateResponse("overview.html", {"request": request, "usuario": usuario})

@app.get("/selecionar_acao/{cargo}")
async def selecionar_action(request: Request, cargo: str):
    cargo_upper = cargo.upper()
    acoes_disponiveis = data.ACOES.get(cargo_upper, {})
    return templates.TemplateResponse("selecionar_acoes.html", {"request": request, "usuario": usuario, "cargo": cargo, "acoes": acoes_disponiveis})


@app.get("/acoes/{acao}")
async def acoes(acao: str):
    return {"message": f"Ação executada para o relatório: {acao}"}


@app.get("/selecionar_relatorio")
async def selecionar_relatorio(request: Request):
    return templates.TemplateResponse("selecionar_relatorio.html", {"request": request, "usuario": usuario, "relatorios": data.RELATORIOS })

@app.get("/relatorios/{relatorio}")
async def relatorios(relatorio: int):
    return {"message": f"Ação executada para o relatório: {relatorio}"}

