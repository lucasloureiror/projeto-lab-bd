import oracledb
import asyncio

async def check_credentials(username, password):
    try:
        # Estabelece uma conexão assíncrona com o banco de dados
        connection = await oracledb.connect_async(user=username, password=password, dsn="orclgrad1.icmc.usp.br/pdb_elaine.icmc.usp.br")
        
        # Fecha a conexão assíncronamente
        await connection.close()
        
        print("Conexão realizada com sucesso")
        return True
    except oracledb.DatabaseError:
        print("Conexão falhou")
        return False
