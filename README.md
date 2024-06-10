# projeto-lab-bd
Repositório para o projeto final de lab de BD

# /scripts

## Criação do banco
Para criar o esquema do banco do zero, ou seja, para criar todas as tabelas, sequências, funções e procedimentos desenvolvidos até agora e inserir os dados na base, execute os scripts na seguinte ordem:

1. `esquema.sql`
2. `insercao.sql`
3. `users.sql`
4. `log.sql`


## Remoção do banco
Caso seja necessário remover todas as tabelas, sequências, funções e procedimentos do banco, basta executar o script `remover-esquema.sql`.


## Exceções personalizadas
As seguintes exceções foram definidas pelo banco no desenvolvimento de algumas funções/procedimentos:
1. `ORA-20001`: **Objeto não encontrado** (ex.: 'Usuario nao encontrado', 'Estrela nao encontrada').
2. `ORA-20002`: **Senha inválida**.
4. `ORA-20003`: **Objeto já existe** (ex.: 'Estrela ja existe, altere o ID e tente novamente').
5. `ORA-20004`: **Atributo não pode ser nulo** (ex.: 'Os atributos "ID_ESTRELA", "X", "Y" e "Z" nao podem ser nulos.').


## Funções disponíveis
As seguintes funções foram desenvolvidas no banco e podem ser utilizadas pela aplicação:
1. `FUNC_VALIDA_USUARIO(p_id_lider, p_senha): NUMBER`
2. `FUNC_OBTER_CARGO_USUARIO(p_id_lider): CHAR(10)`
3. `FUNC_VALIDA_LIDER_FACCAO(p_id_lider): NUMBER`

### FUNC_VALIDA_USUARIO
- **Implementação**: `users.sql`
- **Parâmetros**: `p_id_lider CHAR(14)`, `p_senha VARCHAR(32)`
- **Retorno**: `v_user_id NUMBER`
- **Descrição**: Recebe o CPI do líder e sua senha de usuário. Verifica se existe um usuário no banco para esse líder e se sua senha está correta. Retorna o id do usuário, caso este seja válido. 
- **Objetivo**: Permitir que o login na aplicação seja validado com base na tabela *USERS* do banco.
- **Exceções**:
    1. `ORA-20001` - Usuário nao encontrado.
    2. `ORA-20002` - Senha inválida.

### FUNC_BUSCA_CARGO_USUARIO
- **Implementação**: `users.sql`
- **Parâmetros**: `p_id_lider CHAR(14)`
- **Retorno**: `v_cargo_usuario CHAR(10)`
- **Descrição**: Recebe o CPI do líder, pesquisa seu cargo na tabela *LIDER* e o retorna. 
- **Objetivo**: Permitir que a aplicação controle as permissões de acesso às funcionalidades para cada usuário com base no seu cargo.
- **Exceções**: `ORA-20001` - Usuário não encontrado.

### FUNC_VALIDA_LIDER_FACCAO
- **Implementação**: `users.sql`
- **Parâmetros**: `p_id_lider CHAR(14)`
- **Retorno**: `v_eh_lider_faccao NUMBER`
- **Descrição**: Recebe o CPI do líder e verifica se ele é um líder de facção, ou seja, se está associado à uma facção cadastrada. Retorna 1 caso seja um líder de facção e retorna 0 caso não seja.
- **Objetivo**: Permitir que a aplicação controle as permissões de acesso às funcionalidades adicionais para líderes de facção.
- **Exceções**: Nenhuma.


## Procedimentos disponíveis
Os seguintes procedimentos foram desenvolvidos no banco e podem ser utilizados pela aplicação:
1. `PROC_INSERIR_LOG(p_user_id, p_mensagem)`

### PROC_INSERIR_LOG
- **Implementação**: `log.sql`
- **Parâmetros**: `p_user_id NUMBER`, `p_mensagem VARCHAR(255)`
- **Descrição**: Recebe o id do usuário que acessou o sistema/executou a operação e a mensagem do log. Insere uma nova entrada na tabela de logs, utilizando o id do usuário, a data-hora atual do sistema e a mensagem especificada.
- **Objetivo**: Permitir que a tabela de logs seja mantida por chamadas da aplicação.
- **Exceções**: `ORA-20001` - Usuário não encontrado.


## Pacotes disponíveis
Os seguintes pacotes foram desenvolvidos no banco e podem ser utilizados pela aplicação:
1. `PAC_FUNC_CIENTISTA`: Pacote que incluí todas as funcionalidades de gerenciamento para usuários do tipo 'Cientista' (criação, busca, atualização e remoção de estrelas).

### PAC_FUNC_CIENTISTA
Inclui as seguintes funções/procedimentos:
1. `criar_estrela(p_estrela)`
2. `buscar_estrela(p_id_estrela): ESTRELA%ROWTYPE`
3. `atualizar_estrela(p_estrela)`
4. `remover_estrela(p_id_estrela)`

<br>

**CRIAR_ESTRELA**

- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_estrela ESTRELA%ROWTYPE`
- **Descrição**: Recebe um objeto do tipo estrela e o insere na tabela *ESTRELA*.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam inserir novas estrelas na base de dados.
- **Exceções**:
    1. `ORA-20003` - Estrela já existe, altere o ID e tente novamente.
    2. `ORA-20003` - Estrela já existe, altere as coordenadas e tente novamente.
    3. `ORA-20004` - Os atributos "ID_ESTRELA", "X", "Y" e "Z" não podem ser nulos.

<br>

**BUSCAR_ESTRELA**

- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_id_estrela VARCHAR2(31)`
- **Retorno**: `p_estrela ESTRELA%ROWTYPE`
- **Descrição**: Recebe um id de estrela, busca na tabela *ESTRELA* e retorna a estrela encontrada.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam buscar estrelas pelo id na base de dados.
- **Exceções**: `ORA-20001` - Estrela não encontrada.

<br>

**ATUALIZAR_ESTRELA**

- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_estrela ESTRELA%ROWTYPE`
- **Descrição**: Recebe um objeto do tipo estrela e o atualiza na tabela *ESTRELA* com base no id do objeto.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam atualizar os dados das estrelas na base.
- **Exceções**:
    1. `ORA-20001` - Estrela não encontrada.
    2. `ORA-20004` - Os atributos "ID_ESTRELA", "X", "Y" e "Z" não podem ser nulos.

<br>

**REMOVER_ESTRELA**

- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_id_estrela VARCHAR2(31)`
- **Descrição**: Recebe um id de estrela e a remove da tabela *ESTRELA*.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam remover estrelas pelo id na base de dados.
- **Exceções**: `ORA-20001` - Estrela não encontrada.
