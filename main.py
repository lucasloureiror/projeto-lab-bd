from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import RedirectResponse
from starlette.status import HTTP_303_SEE_OTHER
import repository.connection
import data
from models import Usuario
import repository.lider_faccao, repository.cientista

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
async def acoes(acao: int, request: Request):


    if acao == 1:
        form_fields = [
        {"id": "nome_faccao", 
        "name": "Alterar o nome da própria facção", 
        "description": "novo nome da facção", 
        "value": ""},
        
    ]
        acao = "alterar nome da facção"
    
    elif acao == 2:
        form_fields = [
        {"id": "id_novo_lider", 
         "name": "ID do novo líder da facção", 
         "description": "ID do novo líder", 
         "value": ""},
         
    ]
        acao = "indicar novo líder"

    elif acao == 3:
        form_fields = [
        {"id": "nome_especie", 
         "name": "Nome da espécie", 
         "description": "Nome da espécie", 
         "value": ""},

         {"id": "nome_comunidade", 
         "name": "Nome da comunidade que será credenciada", 
         "description": "Nome da comunidade", 
         "value": ""},
         
    ]
        acao = "credenciar nova comunidade"

    elif acao == 4:
        form_fields = [
        {"id": "nome_faccao", 
         "name": "Nome da facção", 
         "description": "Nome da facção", 
         "value": ""},

         {"id": "nome_nacao", 
         "name": "Nome da nação", 
         "description": "Nome da nação", 
         "value": ""},
         
    ]
        acao = "remover facção de uma nação"

    elif acao == 10:
        form_fields = [
        {"id": "id_estrela", 
         "name": "buscar uma estrela por ID", 
         "description": "Id da Estrela", 
         "value": ""},
         
    ]
        acao = "buscar estrela por id"
    return templates.TemplateResponse("acoes.html", {"request": request, "acao": acao, "form_fields": form_fields, "usuario": usuario})

@app.post("/acoes/{acao}")
async def processar_acao(request: Request, acao: str):
    form_data = await request.form()
    form_dict = {key: value for key, value in form_data.items()}
    result: str = None

    #FUNCIONALIDADES DE LÍDER
    if acao == "alterar nome da facção":
         result = repository.lider_faccao.alterar_nome_faccao(form_dict["nome_faccao"], usuario)
    
    elif acao == "indicar novo líder":
        result = repository.lider_faccao.indicar_novo_lider(form_dict["id_novo_lider"], usuario)

    elif acao == "credenciar nova comunidade":
        result = repository.lider_faccao.credenciar_nova_comunidade(form_dict["nome_especie"], form_dict["nome_comunidade"], usuario)


    elif acao == "remover facção de uma nação":
        result = repository.lider_faccao.remover_faccao_de_nacao(form_dict["nome_faccao"], form_dict["nome_nacao"], usuario)



    #FUNCIONALIDADES DE CIENTISTA
    elif acao == "buscar estrela por id":
        result = repository.cientista.buscar_estrela(form_dict["id_estrela"], usuario)
    

    else: 
        result = "Operação não catalogada"


    if result == None:
        result = "Operação realizada com sucesso"
    return templates.TemplateResponse("acoes_resultado.html", {"request": request,  "usuario": usuario, "resultado": result})

@app.get("/selecionar_relatorio")
async def selecionar_relatorio(request: Request):
    return templates.TemplateResponse("selecionar_relatorio.html", {"request": request, "usuario": usuario, "relatorios": data.RELATORIOS })

@app.get("/relatorios/{relatorio}")
async def relatorios(relatorio: int):
    return {"message": f"Ação executada para o relatório: {relatorio}"}

