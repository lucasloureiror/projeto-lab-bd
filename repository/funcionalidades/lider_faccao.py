# Funcionalidades de gerenciamento para usuários do tipo "Líder de Facção"
import oracledb
import utils
from models import Usuario
from repository.connection import get_connection

NOVO_LOG = "PROC_INSERIR_LOG"
PACOTE = "PAC_FUNC_LIDER_FACCAO"

# Alterar nome da própria facção da qual é líder
def alterar_nome_faccao(novo_nome_faccao:str, usuario:Usuario):
    print(f"ALTERAR NOME DE FACÇÃO --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".ALTERAR_NOME_FACCAO", [novo_nome_faccao, usuario.username])

            mensagem_log = "Nome da facção do líder alterado para '" + novo_nome_faccao + "'"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem_erro = "ERRO: Líder de facção não encontrado."
            elif error.code == 20004:
                mensagem_erro = "ERRO: O novo nome da facção não pode ser nulo."
            elif error.code == 20005:
                mensagem_erro = "ERRO: O novo nome da facção deve ser diferente do nome atual."
            elif error.code == 12899 and ("maximum: 15" in error.message):
                mensagem_erro = "ERRO: O nome de facção informado é muito grande. Informe um nome com até 15 caracteres e tente novamente."
            else:
                mensagem_erro = f"{error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de alterar o nome da facção do líder para '{novo_nome_faccao}' --> {mensagem_erro}"
            mensagem_log = utils.ajustar_mensagem_log(mensagem_log)
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem_log)
            return mensagem_erro
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Indicar um novo líder para a própria facção (deve perder acesso às funcionalidades)
def indicar_novo_lider(id_novo_lider:str, usuario:Usuario):
    print(f"INDICAR NOVO LÍDER --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".INDICAR_NOVO_LIDER", [id_novo_lider, usuario.username])

            mensagem_log = "Líder '" + id_novo_lider + "' indicado como o novo líder da facção"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = "Líder de facção não encontrado."
            elif error.code == 20004:
                mensagem = "O atributo 'LIDER'' não pode ser nulo. Indique o CPI do novo líder e tente novamente."
            elif error.code == 20005:
                mensagem = "Sua facção não está presente na nação do líder '" +  id_novo_lider + "'. Escolha outro líder e tente novamente."
            else:
                mensagem = f"{error.code}: {error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de indicar '{id_novo_lider}' como o novo líder da facção --> ERRO {error.code}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem_log)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"

# Credenciar comunidades novas que habitem planetas dominados por nações onde a própria facção está presente
def credenciar_nova_comunidade(nome_especie:str, nome_comunidade:str, usuario:Usuario):
    print(f"CREDENCIAR NOVA COMUNIDADE --> Usuário {usuario.user_id}")
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".CREDENCIAR_NOVA_COMUNIDADE", [nome_especie, nome_comunidade, usuario.username])

            mensagem_log = "Nova comunidade '{" + nome_especie + ", " + nome_comunidade + "}' credenciada na facção do líder"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = f"{error.code}: {error.message}"
            elif error.code == 20003:
                mensagem = "Comunidade já credenciada na sua facção, altere a comunidade e tente novamente."
            elif error.code == 20004:
                mensagem = "Os atributos 'ESPECIE' e 'COMUNIDADE' não podem ser nulos."
            elif error.code == 20005:
                mensagem = "Somente comunidades que habitam um planeta dominado por uma nação associada à sua facção podem ser credenciadas."
            else:
                mensagem = f"{error.code}: {error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de credenciar comunidade '[{nome_especie}, {nome_comunidade}]' na facção do líder --> ERRO {error.code}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem_log)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
    
# Remover facção de nação (NACAO_FACCAO)
def remover_faccao_de_nacao(nome_faccao:str, nome_nacao:str, usuario:Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        try:
            cursor.callproc(PACOTE + ".REMOVER_FACCAO_DE_NACAO", [nome_faccao, nome_nacao])

            mensagem_log = "Facção '" + nome_faccao + "' foi removida da nação '" + nome_nacao + "' pelo líder"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])

            connection.commit()
            print(mensagem_log)

        except oracledb.DatabaseError as e:
            error, = e.args
            if error.code == 20001:
                mensagem = f"{error.code}: {error.message}"
            elif error.code == 20005:
                mensagem = "O líder da facção '" + nome_faccao + "' pertence a nação '" + nome_nacao + "' e, portanto, tal facção nao pode ser removida dessa nação."
            else:
                mensagem = f"{error.code}: {error.message}"

            connection.rollback()

            mensagem_log = f"Tentativa de remover a facção '{nome_faccao}' da nação '{nome_nacao}' --> ERRO {error.code}"
            cursor.callproc(NOVO_LOG, [usuario.user_id, mensagem_log])
            connection.commit()

            print(mensagem_log)
            return mensagem
        
        finally:
            cursor.close()
            connection.close()

    except oracledb.DatabaseError as e:
        return "Conexão falhou"
