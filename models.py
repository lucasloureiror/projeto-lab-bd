class Usuario:
    def __init__(self, user_id: int, username: str, nome: str, cargo: str, eh_lider_faccao: bool):
        self.user_id = user_id
        self.username = username
        self.nome = nome
        self.cargo = cargo
        self.eh_lider_faccao = eh_lider_faccao
        
class Estrela:
    def __init__(self, id:str, nome:str, classificacao:str, massa:float, x:float, y:float, z:float):
        self.id = id
        self.nome = nome
        self.classificacao = classificacao
        self.massa = massa
        self.x = x
        self.y = y
        self.z = z

    def __str__(self):
        return f"Estrela: [{self.id}, {self.nome}, {self.classificacao}, {self.massa}, {self.x}, {self.y}, {self.z}]"
    

class RelatorioLider:
    nome: str
    nacao: str
    planeta: str
    sistema: str
    especie: str
    qtd_habitantes: int

    def __init__(self, nome: str, nacao: str, planeta: str, sistema: str, especie: str, qtd_habitantes: int):
        self.nome = nome
        self.nacao = nacao
        self.planeta = planeta
        self.sistema = sistema
        self.especie = especie
        self.qtd_habitantes = qtd_habitantes

    def __repr__(self):
        return f"RelatorioLider(nome={self.nome}, nacao={self.nacao}, planeta={self.planeta}, sistema={self.sistema}, especie={self.especie}, qtd_habitantes={self.qtd_habitantes})"

    def to_dict(self):
        return {
            "nome": self.nome,
            "nacao": self.nacao,
            "planeta": self.planeta,
            "sistema": self.sistema,
            "especie": self.especie,
            "qtd_habitantes": self.qtd_habitantes
        }
    

class RelatorioHabitantesGeral:
    def __init__(self, nome: str, faccao: str, planeta: str, sistema: str, especie: str, qtd_habitantes: int):
        self.nome = nome
        self.faccao = faccao
        self.planeta = planeta
        self.sistema = sistema
        self.especie = especie
        self.qtd_habitantes = qtd_habitantes
    def to_dict(self):
        return {
            "nome": self.nome,
            "faccao": self.faccao,
            "planeta": self.planeta,
            "sistema": self.sistema,
            "especie": self.especie,
            "qtd_habitantes": self.qtd_habitantes
        }

class RelatorioHabitantesFaccao:
    def __init__(self, faccao: str, qtd_habitantes: int):
        self.faccao = faccao
        self.qtd_habitantes = qtd_habitantes

    def to_dict(self):
        return {
            "faccao": self.faccao,
            "qtd_habitantes": self.qtd_habitantes
        }

class RelatorioHabitantesSistemas:
    def __init__(self, sistema: str, qtd_habitantes: int):
        self.sistema = sistema
        self.qtd_habitantes = qtd_habitantes

    def to_dict(self):
        return {
            "sistema": self.sistema,
            "qtd_habitantes": self.qtd_habitantes
        }

class RelatorioHabitantesPlanetas:
    def __init__(self, planeta: str, qtd_habitantes: int):
        self.planeta = planeta
        self.qtd_habitantes = qtd_habitantes

    def to_dict(self):
        return {
            "planeta": self.planeta,
            "qtd_habitantes": self.qtd_habitantes
        }

class RelatorioHabitantesEspecies:
    def __init__(self, especie: str, qtd_habitantes: int):
        self.especie = especie
        self.qtd_habitantes = qtd_habitantes

    def to_dict(self):
        return {
            "especie": self.especie,
            "qtd_habitantes": self.qtd_habitantes
        }
    

class RelatorioDominacao:
    def __init__(self, id_planeta, nacao_dominante, data_ini, data_fim, qtd_comunidades, qtd_especies, total_habitantes, qtd_faccoes, faccao_majoritaria):
        self.id_planeta = id_planeta
        self.nacao_dominante = nacao_dominante
        self.data_ini = data_ini
        self.data_fim = data_fim
        self.qtd_comunidades = qtd_comunidades
        self.qtd_especies = qtd_especies
        self.total_habitantes = total_habitantes
        self.qtd_faccoes = qtd_faccoes
        self.faccao_majoritaria = faccao_majoritaria

    def to_dict(self):
        return {
            "id_planeta": self.id_planeta,
            "nacao_dominante": self.nacao_dominante,
            "data_ini": self.data_ini,
            "data_fim": self.data_fim,
            "qtd_comunidades": self.qtd_comunidades,
            "qtd_especies": self.qtd_especies,
            "total_habitantes": self.total_habitantes,
            "qtd_faccoes": self.qtd_faccoes,
            "faccao_majoritaria": self.faccao_majoritaria
        }

class RelatorioPotencialExpansao:
    def __init__(self, planeta, estrela, coord_x, coord_y, coord_z):
        self.planeta = planeta
        self.estrela = estrela
        self.coord_x = coord_x
        self.coord_y = coord_y
        self.coord_z = coord_z

    def to_dict(self):
        return {
            "planeta": self.planeta,
            "estrela": self.estrela,
            "coord_x": self.coord_x,
            "coord_y": self.coord_y,
            "coord_z": self.coord_z
        }