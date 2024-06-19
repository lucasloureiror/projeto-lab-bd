import oracledb
from models import RelatorioEstrela, RelatorioPlaneta, RelatorioSistema
from repository.connection import get_connection


def get_relatorio_estrela():
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "relatorios_cientista.Gerar_Relatorio1",
            oracledb.DB_TYPE_CURSOR
        )

        relatorios = []
        for rec in result:
            relatorio = RelatorioEstrela(
                id_estrela=rec[0],
                nome=rec[1],
                massa=rec[2],
                classificacao=rec[3],
                sistema_nome=rec[4],
                qtd_planetas_orbitam=rec[5],
                qtd_estrelas_orbitam=rec[6],
                qtd_estrelas_orbita=rec[7],
                x=rec[8],
                y=rec[9],
                z=rec[10]
            )
            relatorios.append(relatorio)

        print("Relatórios de Estrela obtidos:")
        for relat in relatorios:
            print(
                f"ID Estrela: {relat.id_estrela}, "
                f"Nome: {relat.nome}, "
                f"Massa: {relat.massa}, "
                f"Classificação: {relat.classificacao}, "
                f"Nome do Sistema: {relat.sistema_nome}, "
                f"Qtd Planetas que Orbitam: {relat.qtd_planetas_orbitam}, "
                f"Qtd Estrelas que Orbitam: {relat.qtd_estrelas_orbitam}, "
                f"Qtd Estrelas que Orbita: {relat.qtd_estrelas_orbita}, "
                f"X: {relat.x}, "
                f"Y: {relat.y}, "
                f"Z: {relat.z}"
            )
        return relatorios, "Relatórios de Corpos Celestes - Estrelas"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório de estrelas: {error.message}")

def get_relatorio_planeta():
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "relatorios_cientista.Gerar_Relatorio2",
            oracledb.DB_TYPE_CURSOR
        )

        relatorios = []
        for rec in result:
            relatorio = RelatorioPlaneta(
                id_astro=rec[0],
                massa=rec[1],
                classificacao=rec[2],
                sistema_nome=rec[3],
                qtd_estrelas_orbita=rec[4]
            )
            relatorios.append(relatorio)

        print("Relatórios de Planeta obtidos:")
        for relat in relatorios:
            print(
                f"ID Astro: {relat.id_astro}, "
                f"Massa: {relat.massa}, "
                f"Classificação: {relat.classificacao}, "
                f"Nome do Sistema: {relat.sistema_nome}, "
                f"Qtd Estrelas que Orbita: {relat.qtd_estrelas_orbita}"
            )
        return relatorios, "Relatórios de Corpos Celestes - Planetas"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório de planetas: {error.message}")

def get_relatorio_sistema():
    try:
        connection = get_connection()
        cursor = connection.cursor()

        # Chamando a função PL/SQL
        result = cursor.callfunc(
            "relatorios_cientista.Gerar_Relatorio3",
            oracledb.DB_TYPE_CURSOR
        )

        relatorios = []
        for rec in result:
            relatorio = RelatorioSistema(
                nome=rec[0],
                qtd_estrelas=rec[1],
                qtd_planetas=rec[2]
            )
            relatorios.append(relatorio)

        print("Relatórios de Sistema obtidos:")
        for relat in relatorios:
            print(
                f"Nome: {relat.nome}, "
                f"Qtd Estrelas: {relat.qtd_estrelas}, "
                f"Qtd Planetas: {relat.qtd_planetas}"
            )
        return relatorios, "Relatórios de Corpos Celestes - Sistemas"

    except oracledb.DatabaseError as e:
        error, = e.args
        print(f"Erro ao obter relatório de sistemas: {error.message}")