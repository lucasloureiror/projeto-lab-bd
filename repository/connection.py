import oracledb
from models import Usuario

# Função para conectar ao banco de dados Oracle
def get_connection():
    try:
        dsn = oracledb.makedsn('localhost', '1521', service_name='FREEPDB1')
        connection = oracledb.connect(user='LAB_BD', password='lab_bd', dsn=dsn)
        print("Conexão realizada com sucesso")
        return connection
    except oracledb.DatabaseError as e:
        error, = e.args
        print("Falha na conexão com o banco de dados! --> ", error.message)
        raise


# Função para validar as credenciais do usuário
async def check_credentials(username: str, password: str):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            # Validar o usuário pela tabela USERS
            user_id = cursor.callfunc("FUNC_VALIDA_USUARIO", int, [username, password])
            print("Usuário encontrado! User ID: ", user_id)

            # Registrar o acesso do usuário na tabela LOG_TABLE
            cursor.callproc("PROC_INSERIR_LOG", [user_id, "Login realizado com sucesso."])
            print("Acesso registrado no log")

            # Buscar o cargo do usuário logado
            cargo = cursor.callfunc("FUNC_BUSCA_CARGO_USUARIO", str, [username])

            # Verificar se o usuário logado é um líder de facção
            eh_lider_faccao = cursor.callfunc("FUNC_VALIDA_LIDER_FACCAO", bool, [username])

            # Buscar o nome do usuário
            nome = cursor.callfunc("FUNC_BUSCA_NOME_USUARIO", str, [username])

            connection.commit()
            
            return Usuario(user_id, username, nome, cargo, eh_lider_faccao)
        
        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "Usuário não encontrado."
            elif error.code == 20002:
                mensagem = "Senha inválida."
            else:
                mensagem = f"{error.code}: {error.message}"

            connection.rollback()
            print(mensagem)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
