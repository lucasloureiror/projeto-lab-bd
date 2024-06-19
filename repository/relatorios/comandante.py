import oracledb
from models import Usuario, RelatorioDominacao, RelatorioPotencialExpansao
from repository.connection import get_connection


def get_relatorio_dominacao(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "Relatorios_Comandante.Gerar_Relatorio_Dominacao",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        relatorios = []
        for rec in result:
            relatorio = RelatorioDominacao(
                id_planeta=rec[0],
                nacao_dominante=rec[1],
                data_ini=rec[2],
                data_fim=rec[3],
                qtd_comunidades=rec[4],
                qtd_especies=rec[5],
                total_habitantes=rec[6],
                qtd_faccoes=rec[7],
                faccao_majoritaria=rec[8]
            )
            relatorios.append(relatorio)

        print("Relatórios de Dominação obtidos:")
        for relat in relatorios:
            print(
                f"ID Planeta: {relat.id_planeta}, "
                f"Nação Dominante: {relat.nacao_dominante}, "
                f"Data Início: {relat.data_ini}, "
                f"Data Fim: {relat.data_fim}, "
                f"Qtd Comunidades: {relat.qtd_comunidades}, "
                f"Qtd Espécies: {relat.qtd_especies}, "
                f"Total Habitantes: {relat.total_habitantes}, "
                f"Qtd Facções: {relat.qtd_faccoes}, "
                f"Facção Majoritária: {relat.faccao_majoritaria}"
            )
        return relatorios, "Relatório de Dominação"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório de dominação: {error.message}")

def get_relatorio_potencial_expansao(usuario: Usuario, distancia_maxima):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "Relatorios_Comandante.Gerar_Relatorio_Potencial_Expansao",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username, distancia_maxima]
        )

        relatorios = []
        for rec in result:
            relatorio = RelatorioPotencialExpansao(
                planeta=rec[0],
                estrela=rec[1],
                coord_x=rec[2],
                coord_y=rec[3],
                coord_z=rec[4]
            )
            relatorios.append(relatorio)

        print("Relatórios de Potencial de Expansão obtidos:")
        for relat in relatorios:
            print(
                f"Planeta: {relat.planeta}, "
                f"Estrela: {relat.estrela}, "
                f"Coord X: {relat.coord_x}, "
                f"Coord Y: {relat.coord_y}, "
                f"Coord Z: {relat.coord_z}"
            )
        return relatorios, "Relatório de Potencial de Expansão"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório de potencial de expansão: {error.message}")