class Usuario:
    def __init__(self, user_id: int, username: str, nome: str, cargo: str, eh_lider_faccao: bool):
        self.user_id = user_id
        self.username = username
        self.nome = nome
        self.cargo = cargo
        self.eh_lider_faccao = eh_lider_faccao
        