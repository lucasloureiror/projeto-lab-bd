import oracledb

# Função para conectar ao banco de dados Oracle
def get_connection():
    try:
        dsn = oracledb.makedsn('localhost', '1521', service_name='FREEPDB1')
        connection = oracledb.connect(user='LAB_BD', password='lab_bd', dsn=dsn)
        print("Conexão realizada com sucesso")
        return connection
    except oracledb.DatabaseError as e:
        error, = e.args
        print("Falha na conexão com o banco de dados:", error.message)


# Função para validar as credenciais do usuário
async def check_credentials(username: str, password: str):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        print("Checando credenciais...")

        # Login bem-sucedido se a função retornar um ID válido
        user_id = cursor.callfunc("FUNC_VALIDA_USUARIO", int, [username, password])
        print("Usuário encontrado! User ID: ", user_id);

        cursor.close()
        connection.close()
        return user_id
    except oracledb.DatabaseError as e:
        error, = e.args
        if error.code == 20001:
            mensagem = "Usuário não encontrado."
        elif error.code == 20002:
            mensagem = "Senha inválida."
        else:
            mensagem = f"{error.code}: {error.message}"
        return mensagem
