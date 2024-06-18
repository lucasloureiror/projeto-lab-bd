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