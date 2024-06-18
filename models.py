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