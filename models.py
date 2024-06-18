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