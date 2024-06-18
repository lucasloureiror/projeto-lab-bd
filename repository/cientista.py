import oracledb
from models import Usuario, Estrela
from repository.connection import get_connection

NOVO_LOG = "PROC_INSERIR_LOG"
PACOTE_FUNC = "PAC_FUNC_CIENTISTA"

# Funcionalidades de gerenciamento para usuários do tipo "Cientista"

# Criar estrela
def criar_estrela(estrela:Estrela, usuario:Usuario):
    print(f"CRIAR ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE_FUNC + ".CRIAR_ESTRELA", [estrela.id, estrela.nome, estrela.classificacao, estrela.massa, estrela.x, estrela.y, estrela.z])

            mensagem_log = f"Estrela '{estrela.id}' criada"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(f"Estrela criada: [{estrela.id}, {estrela.nome}, {estrela.classificacao}, {estrela.massa}, {estrela.x}, {estrela.y}, {estrela.z}]")

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20003 and ("altere o ID" in error.message):
                mensagem = "Estrela já existe, altere o ID e tente novamente."
            elif error.code == 20003:
                mensagem = "Estrela já existe, altere as coordenadas e tente novamente."
            elif error.code == 20004:
                mensagem = "Os atributos 'ID_ESTRELA', 'X', 'Y' e 'Z' não podem ser nulos."
            else:
                mensagem = f"{error.code}: {error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de criar a estrela '{estrela.id}' --> ERRO: '{mensagem}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Buscar estrela por id
def buscar_estrela(id_estrela:str, usuario:Usuario):
    print(f"BUSCAR ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            estrela_rowtype = connection.gettype('ESTRELA%ROWTYPE')
            retorno = cursor.callfunc(PACOTE_FUNC + ".BUSCAR_ESTRELA", estrela_rowtype, [id_estrela])
            estrela = Estrela(
                retorno.ID_ESTRELA,
                retorno.NOME,
                retorno.CLASSIFICACAO,
                retorno.MASSA,
                retorno.X,
                retorno.Y,
                retorno.Z
            )

            mensagem_log = f"Estrela '{estrela.id}' encontrada"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(f"Estrela encontrada: [{estrela.id}, {estrela.nome}, {estrela.classificacao}, {estrela.massa}, {estrela.x}, {estrela.y}, {estrela.z}]")
            return estrela

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "Estrela não encontrada."
            else:
                mensagem = f"{error.code}: {error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de buscar a estrela '{id_estrela}' --> ERRO: '{mensagem}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Atualizar estrela por id


# Remover estrela por id
def remover_estrela(id_estrela:str, usuario:Usuario):
    print(f"REMOVER ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE_FUNC + ".REMOVER_ESTRELA", [id_estrela])

            mensagem_log = f"Estrela '{id_estrela}' removida"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            error, = e.args
            if error.code == 20001:
                mensagem = "Estrela não encontrada."
            else:
                mensagem = f"{error.code}: {error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de remover estrela '{id_estrela}' --> ERRO: '{mensagem}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
