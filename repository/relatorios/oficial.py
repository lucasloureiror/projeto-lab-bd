import oracledb
from models import Usuario, RelatorioHabitantesGeral, RelatorioHabitantesFaccao, RelatorioHabitantesSistemas, RelatorioHabitantesPlanetas, RelatorioHabitantesEspecies
from repository.connection import get_connection


def get_relatorio_habitantes_geral(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        result = cursor.callfunc(
            "Relatorios_Oficial.Gerar_Relatorio_Habitantes_Geral",
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
            relatorio = RelatorioHabitantesGeral(
                nome=rec[0],
                faccao=rec[1],
                planeta=rec[2],
                sistema=rec[3],
                especie=rec[4],
                qtd_habitantes=rec[5]
            )
            relatorios.append(relatorio)

        print("Relatórios obtidos:")
        for relat in relatorios:
            print(
                f"Nome: {relat.nome}, "
                f"Facção: {relat.faccao}, "
                f"Planeta: {relat.planeta}, "
                f"Sistema: {relat.sistema}, "
                f"Espécie: {relat.especie}, "
                f"QTD_Habitantes: {relat.qtd_habitantes}"
            )

        return relatorios, "Relatório Habitantes Geral"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")

def get_relatorio_habitantes_faccao(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        result = cursor.callfunc(
            "Relatorios_Oficial.Gerar_Relatorio_Habitantes_Faccao",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        registros = []
        for rec in result:
            registros.append(rec)

        relatorios = []
        for rec in registros:
            print(
                f"Facção: {rec[0]}, "
                f"QTD_Habitantes: {rec[1]}"
            )
            relatorio = RelatorioHabitantesFaccao(
                faccao=rec[0],
                qtd_habitantes=rec[1]
            )
            relatorios.append(relatorio)

        print("Relatórios obtidos:")
        for relat in relatorios:
            print(
                f"Facção: {relat.faccao}, "
                f"QTD_Habitantes: {relat.qtd_habitantes}"
            )

        return relatorios, "Relatório Habitantes por Faccão"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")

def get_relatorio_habitantes_sistemas(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        result = cursor.callfunc(
            "Relatorios_Oficial.Gerar_Relatorio_Habitantes_Sistemas",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        registros = []
        for rec in result:
            registros.append(rec)

        relatorios = []
        for rec in registros:
            print(
                f"Sistema: {rec[0]}, "
                f"QTD_Habitantes: {rec[1]}"
            )
            relatorio = RelatorioHabitantesSistemas(
                sistema=rec[0],
                qtd_habitantes=rec[1]
            )
            relatorios.append(relatorio)

        print("Relatórios obtidos:")
        for relat in relatorios:
            print(
                f"Sistema: {relat.sistema}, "
                f"QTD_Habitantes: {relat.qtd_habitantes}"
            )

        return relatorios, "Relatório Habitantes por Sistemas"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")

def get_relatorio_habitantes_planetas(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        result = cursor.callfunc(
            "Relatorios_Oficial.Gerar_Relatorio_Habitantes_Planetas",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        registros = []
        for rec in result:
            registros.append(rec)

        relatorios = []
        for rec in registros:
            print(
                f"Planeta: {rec[0]}, "
                f"QTD_Habitantes: {rec[1]}"
            )
            relatorio = RelatorioHabitantesPlanetas(
                planeta=rec[0],
                qtd_habitantes=rec[1]
            )
            relatorios.append(relatorio)

        print("Relatórios obtidos:")
        for relat in relatorios:
            print(
                f"Planeta: {relat.planeta}, "
                f"QTD_Habitantes: {relat.qtd_habitantes}"
            )

        return relatorios, "Relatório Habitantes por Planeta"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")

def get_relatorio_habitantes_especies(usuario: Usuario):
    try:
        connection = get_connection()
        cursor = connection.cursor()

        result = cursor.callfunc(
            "Relatorios_Oficial.Gerar_Relatorio_Habitantes_Especies",
            oracledb.DB_TYPE_CURSOR,
            [usuario.username]
        )

        registros = []
        for rec in result:
            registros.append(rec)

        relatorios = []
        for rec in registros:
            print(
                f"Espécie: {rec[0]}, "
                f"QTD_Habitantes: {rec[1]}"
            )
            relatorio = RelatorioHabitantesEspecies(
                especie=rec[0],
                qtd_habitantes=rec[1]
            )
            relatorios.append(relatorio)

        print("Relatórios obtidos:")
        for relat in relatorios:
            print(
                f"Espécie: {relat.especie}, "
                f"QTD_Habitantes: {relat.qtd_habitantes}"
            )

        return relatorios, "Relatório Habitantes por Espécie"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório: {error.message}")