import oracledb
import utils
from models import Usuario
from repository.connection import get_connection

NOVO_LOG = "PROC_INSERIR_LOG"
PACOTE_FUNC = "PAC_FUNC_COMANDANTE"

# Funcionalidades de gerenciamento para usuários do tipo "Comandante"

# Incluir a própria nação em uma federação existente
def incluir_propria_nacao(nome_federacao:str, usuario:Usuario):
    print(f"INCLUIR PRÓPRIA NAÇÃO  --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE_FUNC + ".INCLUIR_PROPRIA_NACAO", [nome_federacao, usuario.username])

            mensagem_log = f"Nação do líder incluída na federação '{nome_federacao}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001 and ("Lider nao encontrado" in error.message):
                mensagem = "ERRO: Líder não encontrado."
            elif error.code == 20001:
                mensagem = "ERRO: Federação não encontrada."
            elif error.code == 20004:
                mensagem = "ERRO: O nome da federação que será incluída não pode ser nulo."
            elif error.code == 20005 and ("ja faz parte dessa federacao" in error.message):
                mensagem = "ERRO: Sua nação já faz parte dessa federação."
            elif error.code == 20005:
                mensagem = "ERRO: Sua nação está atualmente incluída em outra federação. Exclua essa associação e tente novamente."
            else:
                mensagem = f"{error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de incluir a nação do líder na federação '{nome_federacao}' --> {mensagem}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
    
# Excluir a própria nação de uma federação existente
def excluir_propria_nacao(nome_federacao:str, usuario:Usuario):
    print(f"EXCLUIR PRÓPRIA NAÇÃO  --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE_FUNC + ".EXCLUIR_PROPRIA_NACAO", [nome_federacao, usuario.username])

            mensagem_log = f"Nação do líder excluída da federação '{nome_federacao}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "ERRO: Líder não encontrado."
            elif error.code == 20004:
                mensagem = "ERRO: O nome da federação que será excluída não pode ser nulo."
            elif error.code == 20005 and ("nao faz parte de nenhuma federacao" in error.message):
                mensagem = "ERRO: Sua nação não faz parte de nenhuma federação."
            elif error.code == 20005:
                mensagem = f"ERRO: Sua nação não está incluída na federação '{nome_federacao}'."
            else:
                mensagem = f"{error.message}"
            connection.rollback()

            mensagem_log = f"Tentativa de excluir a nação do líder da federação '{nome_federacao}' --> {mensagem}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Criar nova federação, com a própria nação
def criar_federacao(nome_federacao:str, data_fund:utils.Data, usuario:Usuario):
    print(f"CRIAR FEDERAÇÃO  --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            data_fund = utils.converter_data(data_fund)
            cursor.callproc(PACOTE_FUNC + ".CRIAR_FEDERACAO", [nome_federacao, data_fund, usuario.username])

            mensagem_log = f"Federação '{nome_federacao}' criada com a nação do líder"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "ERRO: Líder não encontrado."
            elif error.code == 20003:
                mensagem = "ERRO: Federação já existe, altere o nome e tente novamente."
            elif error.code == 20004:
                mensagem = "ERRO: O nome da federação e a data de fundação não podem ser nulos."
            elif error.code == 20005:
                mensagem = "ERRO: Sua nação está atualmente incluída em outra federação. Exclua essa associação e tente novamente."
            else:
                mensagem = f"{error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de criar a federação '{nome_federacao}' com a nação do líder --> {mensagem}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Inserir nova dominância de um planeta que não está sendo dominado por ninguém
def inserir_dominancia(id_planeta:str, data_ini:utils.Data, usuario:Usuario):
    print(f"INSERIR DOMINÂNCIA  --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            data_ini = utils.converter_data(data_ini)
            cursor.callproc(PACOTE_FUNC + ".INSERIR_DOMINANCIA", [id_planeta, data_ini, usuario.username])

            mensagem_log = f"Inserida dominância da nação do líder sobre o planeta '{id_planeta}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001 and ("Lider nao encontrado" in error.message):
                mensagem = "ERRO: Líder não encontrado."
            elif error.code == 20001:
                mensagem = "ERRO: Planeta não encontrado."
            elif error.code == 20004:
                mensagem = "ERRO: Os atributos 'PLANETA', 'NACAO' e 'DATA_INI' não podem ser nulos."
            elif error.code == 20005:
                mensagem = "ERRO: Esse planeta já esta sendo dominado."
            else:
                mensagem = f"{error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de inserir dominância da nação do líder sobre o planeta '{id_planeta}' --> {mensagem}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(error.message)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

