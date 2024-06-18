import datetime

class Data:
    def __init__(self, dia, mes, ano):
        self.dia = dia
        self.mes = mes
        self.ano = ano

def converter_data(data:Data):
    try:
        return datetime.date(int(data.ano), int(data.mes), int(data.dia))

    except ValueError:
        print(f"Erro ao converter data --> [dia:'{data.dia}', mes:'{data.mes}', ano:'{data.ano}']")
        return None

# Ajusta a mensagem do log para ter no máximo 255 caracteres
def ajustar_mensagem_log(mensagem:str):
    TAM_MAX:int = 250
    if len(mensagem) > TAM_MAX:
        return mensagem[:TAM_MAX]
    else:
        return mensagem