import oracledb
from models import Usuario, RelatorioLider
from repository.connection import get_connection

# Relatórios para usuários do tipo "Líder de Facção"
def get_relatorio_lider(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "Relatorios_Lider_de_Faccao.Gerar_Relatorio",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        registros = []
        for rec in result:
            registros.append(rec)

        relatorios = []
        for rec in registros:
            print(
                f"Nome: {rec[0]}, "
                f"Facção: {rec[1]}, "
                f"Planeta: {rec[2]}, "
                f"Sistema: {rec[3]}, "
                f"Espécie: {rec[4]}, "
                f"QTD_Habitantes: {rec[5]}"
            )
            relatorio = RelatorioLider(
                nome=rec[0],
                nacao=rec[1],
                planeta=rec[2],
                sistema=rec[3],
                especie=rec[4],
                qtd_habitantes=rec[5]
            )
            relatorios.append(relatorio)

        return relatorios, "Relatório para Líder"


    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")
