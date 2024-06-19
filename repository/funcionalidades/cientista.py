# Funcionalidades de gerenciamento para usuários do tipo "Cientista"
import oracledb
import utils
from models import Usuario, Estrela
from repository.connection import get_connection

NOVO_LOG = "PROC_INSERIR_LOG"
PACOTE = "PAC_FUNC_CIENTISTA"

# Criar estrela
def criar_estrela(estrela:Estrela, usuario:Usuario):
    print(f"CRIAR ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".CRIAR_ESTRELA", [estrela.id, estrela.nome, estrela.classificacao, estrela.massa, estrela.x, estrela.y, estrela.z])

            mensagem_log = f"Estrela '{estrela.id}' criada --> {estrela}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(f"Estrela criada: [{estrela.id}, {estrela.nome}, {estrela.classificacao}, {estrela.massa}, {estrela.x}, {estrela.y}, {estrela.z}]")

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20003 and ("altere o ID" in error.message):
                mensagem_erro = "ERRO: Estrela já existe, altere o ID e tente novamente."
            elif error.code == 20003:
                mensagem_erro = "ERRO: Estrela já existe, altere as coordenadas e tente novamente."
            elif error.code == 20004:
                mensagem_erro = "ERRO: Os atributos 'ID_ESTRELA', 'X', 'Y' e 'Z' não podem ser nulos."
            else:
                mensagem_erro = f"{error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de criar a estrela '{estrela.id}' --> {mensagem_erro}"
            mensagem_log = utils.ajustar_mensagem_log(mensagem_log)
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem_erro
        
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
            retorno = cursor.callfunc(PACOTE + ".BUSCAR_ESTRELA", estrela_rowtype, [id_estrela])
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
                mensagem_erro = "ERRO: Estrela não encontrada."
            else:
                mensagem_erro = f"{error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de buscar a estrela '{id_estrela}' --> {mensagem_erro}"
            mensagem_log = utils.ajustar_mensagem_log(mensagem_log)
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem_erro
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Atualizar estrela por id
def atualizar_estrela(estrela:Estrela, usuario:Usuario):
    print(f"ATUALIZAR ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            estrela_rowtype = connection.gettype('ESTRELA%ROWTYPE')
            retorno = cursor.callfunc(PACOTE + ".ATUALIZAR_ESTRELA", estrela_rowtype, [estrela.id, estrela.nome, estrela.classificacao, estrela.massa, estrela.x, estrela.y, estrela.z])
            estrela_atualizada = Estrela(
                estrela.id,
                retorno.NOME,
                retorno.CLASSIFICACAO,
                retorno.MASSA,
                retorno.X,
                retorno.Y,
                retorno.Z
            )

            mensagem_log = f"Estrela '{estrela.id}' atualizada --> {estrela_atualizada}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            error, = e.args
            if error.code == 20001:
                mensagem_erro = "ERRO: Estrela não encontrada."
            elif error.code == 20004:
                mensagem_erro = "ERRO: Os atributos 'ID_ESTRELA', 'X', 'Y' e 'Z' não podem ser nulos."
            else:
                mensagem_erro = f"{error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de atualizar estrela '{estrela.id}' --> {mensagem_erro}"
            mensagem_log = utils.ajustar_mensagem_log(mensagem_log)
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem_erro
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Remover estrela por id
def remover_estrela(id_estrela:str, usuario:Usuario):
    print(f"REMOVER ESTRELA --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".REMOVER_ESTRELA", [id_estrela])

            mensagem_log = f"Estrela '{id_estrela}' removida"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            error, = e.args
            if error.code == 20001:
                mensagem_erro = "ERRO: Estrela não encontrada."
            else:
                mensagem_erro = f"{error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de remover estrela '{id_estrela}' --> {mensagem_erro}"
            mensagem_log = utils.ajustar_mensagem_log(mensagem_log)
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem_erro
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
