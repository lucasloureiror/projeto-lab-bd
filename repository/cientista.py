import oracledb
from models import Usuario, Estrela
from repository.connection import get_connection

NOVO_LOG = "PROC_INSERIR_LOG"
PACOTE_FUNC = "PAC_FUNC_CIENTISTA"

# Funcionalidades de gerenciamento para usuários do tipo "Cientista"

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
            print(f"Estrela: [{estrela.id}, {estrela.nome}, {estrela.classificacao}, {estrela.massa}, {estrela.x}, {estrela.y}, {estrela.z}]")

            mensagem_log = f"Estrela '{estrela.id}' encontrada"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "Estrela não encontrada."
            else:
                mensagem = f"{error.code}: {error.message}"
            
            connection.rollback()

            mensagem_log = f"Tentativa de buscar a estrela '{id_estrela}'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
