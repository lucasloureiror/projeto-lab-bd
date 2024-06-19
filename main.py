from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from starlette.responses import RedirectResponse
from starlette.status import HTTP_303_SEE_OTHER
import datetime
import data
import models
from models import Usuario
import repository.connection
import repository.funcionalidades.lider_faccao, repository.funcionalidades.cientista, repository.funcionalidades.comandante
import repository.relatorios.cientista
import repository.relatorios.comandante
import repository.relatorios.lider_faccao
import repository.relatorios.oficial

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

    #FUNCIONALIDADES DE LÍDER DA FACCAO
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


    #FUNCIONALIDADES DE COMANDANTE
    elif acao == 5:
        form_fields = [
        {"id": "nome_federacao", 
         "name": "Nome da federação", 
         "description": "Nome da federação", 
         "value": ""},
         
    ]
        acao = "incluir sua nação em federação existente"

    elif acao == 6:
        form_fields = [
        {"id": "nome_federacao", 
         "name": "Nome da federação", 
         "description": "Nome da federação", 
         "value": ""},
         
    ]
        acao = "excluir sua nação de uma federação"
    
    elif acao == 7:
        form_fields = [
        {"id": "nome_federacao", 
         "name": "Nome da federação", 
         "description": "Nome da federação", 
         "value": ""},

         {"id": "dia", 
         "name": "Dia de fundação", 
         "description": "Dia de fundação", 
         "value": ""},

         {"id": "mes", 
         "name": "Mês (em número) de fundação", 
         "description": "Mês (em número) de fundação, exemplo: 1, 2, 3....", 
         "value": ""},

         {"id": "ano", 
         "name": "Ano de fundação", 
         "description": "Ano de fundação", 
         "value": ""},        
    ]
        acao = "criar uma nova federação com sua nação"

    elif acao == 8:
        form_fields = [
        {"id": "id_planeta", 
         "name": "ID do planeta", 
         "description": "ID do planeta", 
         "value": ""},

        {"id": "dia", 
         "name": "Dia inicial", 
         "description": "Dia inicial", 
         "value": ""},

         {"id": "mes", 
         "name": "Mês (em número) inicial", 
         "description": "Mês (em número) inicial, exemplo: 1, 2, 3....", 
         "value": ""},

         {"id": "ano", 
         "name": "Ano de início", 
         "description": "Ano de início", 
         "value": ""},
         
    ]
        acao = "inserir uma nova dominância em um planeta"


    #FUNCIONALIDADES DE CIENTISTA
    elif acao == 9:
        form_fields = [
        {"id": "id_estrela", 
         "name": "ID da estrela", 
         "description": "Id da Estrela", 
         "value": ""},

         {"id": "nome_estrela", 
         "name": "Nome da estrela", 
         "description": "Nome da estrela", 
         "value": ""},

         {"id": "classificacao_estrela",
         "name": "Classificação da estrela",
         "description": "Classificação da estrela",
         "value": ""},

         {"id": "massa_estrela", 
         "name": "Massa da estrela", 
         "description": "Massa da estrela", 
         "value": ""},

         {"id": "x_estrela", 
         "name": "Posição X da estrela", 
         "description": "Posição X da estrela", 
         "value": ""},

         {"id": "y_estrela", 
         "name": "Posição Y da estrela", 
         "description": "Posição Y da estrela", 
         "value": ""},

         {"id": "z_estrela", 
         "name": "Posição Z da estrela", 
         "description": "Posição Z da estrela", 
         "value": ""},
         
    ]
        acao = "cadastrar estrela"

    elif acao == 10:
        form_fields = [
        {"id": "id_estrela", 
         "name": "buscar uma estrela por ID", 
         "description": "Id da Estrela", 
         "value": ""},
         
    ]
        acao = "buscar estrela por id"

    elif acao == 11:
        form_fields = [
        {"id": "id_estrela", 
         "name": "ID da estrela", 
         "description": "Id da Estrela", 
         "value": ""},

         {"id": "nome_estrela", 
         "name": "Nome da estrela", 
         "description": "Nome da estrela", 
         "value": ""},

         {"id": "classificacao_estrela",
         "name": "Classificação da estrela",
         "description": "Classificação da estrela",
         "value": ""},

         {"id": "massa_estrela", 
         "name": "Massa da estrela", 
         "description": "Massa da estrela", 
         "value": 0},

         {"id": "x_estrela", 
         "name": "Posição X da estrela", 
         "description": "Posição X da estrela", 
         "value": 0},

         {"id": "y_estrela", 
         "name": "Posição Y da estrela", 
         "description": "Posição Y da estrela", 
         "value": 0},

         {"id": "z_estrela", 
         "name": "Posição Z da estrela", 
         "description": "Posição Z da estrela", 
         "value": 0},
         
    ]
        acao = "atualizar estrela"

    elif acao == 12:
        form_fields = [
        {"id": "id_estrela", 
         "name": "remover uma estrela por ID", 
         "description": "Id da Estrela", 
         "value": ""},
         
    ]
        acao = "remover estrela por id"


    return templates.TemplateResponse("acoes.html", {"request": request, "acao": acao, "form_fields": form_fields, "usuario": usuario})

@app.post("/acoes/{acao}")
async def processar_acao(request: Request, acao: str):
    form_data = await request.form()
    form_dict = {key: value for key, value in form_data.items()}
    result: str = None

    #FUNCIONALIDADES DE LÍDER
    if acao == "alterar nome da facção":
         result = repository.funcionalidades.lider_faccao.alterar_nome_faccao(form_dict["nome_faccao"], usuario)
    
    elif acao == "indicar novo líder":
        result = repository.funcionalidades.lider_faccao.indicar_novo_lider(form_dict["id_novo_lider"], usuario)

    elif acao == "credenciar nova comunidade":
        result = repository.funcionalidades.lider_faccao.credenciar_nova_comunidade(form_dict["nome_especie"], form_dict["nome_comunidade"], usuario)

    elif acao == "remover facção de uma nação":
        result = repository.funcionalidades.lider_faccao.remover_faccao_de_nacao(form_dict["nome_faccao"], form_dict["nome_nacao"], usuario)


    #FUNCIONALIDADES DE COMANDANTE
    elif acao == "incluir sua nação em federação existente":
        result = repository.funcionalidades.comandante.incluir_propria_nacao(form_dict["nome_federacao"], usuario)
    
    elif acao == "excluir sua nação de uma federação":
        result = repository.funcionalidades.comandante.excluir_propria_nacao(form_dict["nome_federacao"], usuario)
    
    elif acao == "criar uma nova federação com sua nação":
        result = repository.funcionalidades.comandante.criar_federacao(form_dict["nome_federacao"], datetime.date(int(form_dict["ano"]), int(form_dict["mes"]), int(form_dict["dia"])), usuario)
    
    elif acao == "inserir uma nova dominância em um planeta":
        result = repository.funcionalidades.comandante.inserir_dominancia(form_dict["id_planeta"], datetime.date(int(form_dict["ano"]), int(form_dict["mes"]), int(form_dict["dia"])), usuario)


    #FUNCIONALIDADES DE CIENTISTA
    elif acao == "cadastrar estrela":
        Estrela = models.Estrela(
            id = form_dict["id_estrela"],
            nome = form_dict["nome_estrela"],
            classificacao = form_dict["classificacao_estrela"],
            massa = float(form_dict["massa_estrela"]),
            x = float(form_dict["x_estrela"]),
            y = float(form_dict["y_estrela"]),
            z = float(form_dict["z_estrela"])
        )
        result = repository.funcionalidades.cientista.criar_estrela(Estrela, usuario)

    elif acao == "atualizar estrela":
        Estrela = models.Estrela(
            id = form_dict["id_estrela"],
            nome = form_dict["nome_estrela"],
            classificacao = form_dict["classificacao_estrela"],
            massa = float(form_dict["massa_estrela"]),
            x = float(form_dict["x_estrela"]),
            y = float(form_dict["y_estrela"]),
            z = float(form_dict["z_estrela"])
        )
        result = repository.funcionalidades.cientista.atualizar_estrela(Estrela, usuario)
        
    elif acao == "buscar estrela por id":
        result = repository.funcionalidades.cientista.buscar_estrela(form_dict["id_estrela"], usuario)

    elif acao == "remover estrela por id":
        result = repository.funcionalidades.cientista.remover_estrela(form_dict["id_estrela"], usuario)
    

    else: 
        result = "Operação não catalogada"


    if result == None:
        result = "Operação realizada com sucesso"
    return templates.TemplateResponse("acoes_resultado.html", {"request": request,  "usuario": usuario, "resultado": result})

@app.get("/selecionar_relatorio")
async def selecionar_relatorio(request: Request):
    return templates.TemplateResponse("selecionar_relatorio.html", {"request": request, "usuario": usuario, "relatorios": data.RELATORIOS })

@app.get("/relatorios/{relatorio}")
async def relatorios(relatorio: int, request: Request):

    show_next = False
    show_previous = False
    titulo_relatorio = ""

    #RELATÓRIOS LÍDER DA FACÇÃO
    if relatorio == 1:
        relatorios, titulo_relatorio = repository.relatorios.lider_faccao.get_relatorio_lider(usuario)

    #RELATÓRIOS DO OFICIAL
    elif relatorio == 2: #Geral
        relatorios, titulo_relatorio  = repository.relatorios.oficial.get_relatorio_habitantes_geral(usuario)
        show_next = True

    elif relatorio == 3: #Facção
        relatorios, titulo_relatorio  = repository.relatorios.oficial.get_relatorio_habitantes_faccao(usuario)
        show_previous = True
        show_next = True

    elif relatorio == 4: #Sistema
        relatorios, titulo_relatorio  = repository.relatorios.oficial.get_relatorio_habitantes_sistemas(usuario)
        show_previous = True
        show_next = True

    elif relatorio == 5: #Planeta
        relatorios, titulo_relatorio  = repository.relatorios.oficial.get_relatorio_habitantes_planetas(usuario)
        show_previous = True
        show_next = True
    
    elif relatorio == 6: #Espécie 
        relatorios, titulo_relatorio  = repository.relatorios.oficial.get_relatorio_habitantes_especies(usuario)
        show_previous = True

    #RELATÓRIOS COMANDANTE
    elif relatorio == 7:
        relatorios, titulo_relatorio  = repository.relatorios.comandante.get_relatorio_dominacao(usuario)

    elif relatorio == 8:
        relatorios, titulo_relatorio  = repository.relatorios.comandante.get_relatorio_potencial_expansao(usuario, 100000)
    
    elif relatorio == 9:
        relatorios, titulo_relatorio  = repository.relatorios.cientista.get_relatorio_estrela()
        show_next = True
    
    elif relatorio == 10:
        relatorios, titulo_relatorio  = repository.relatorios.cientista.get_relatorio_planeta()
        show_previous = True
        show_next = True

    elif relatorio == 11:
        relatorios, titulo_relatorio  = repository.relatorios.cientista.get_relatorio_sistema()
        show_previous = True



    return templates.TemplateResponse("relatorios_resultado.html", {
        "request" : request, 
        "relatorios": relatorios, 
        "usuario": usuario, 
        "relatorio": relatorio,
        "show_next": show_next,
        "show_previous": show_previous,
        "titulo_relatorio": titulo_relatorio
        })

