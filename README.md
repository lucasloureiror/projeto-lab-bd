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
1. OR-20001: Usuario não encontrado.
2. OR-20002: Senha invalida.


## Funções disponíveis
As seguintes funções foram desenvolvidas no banco e podem ser utilizadas pela aplicação:
1. `FUNC_VALIDA_USUARIO(p_id_lider, p_senha): v_user_id`
2. `FUNC_OBTER_CARGO_USUARIO(p_id_lider)`
3. `FUNC_VALIDA_LIDER_FACCAO(p_id_lider)`

### FUNC_VALIDA_USUARIO
- **Implementação**: `users.sql`
- **Parâmetros**: `p_id_lider CHAR(14)`, `p_senha VARCHAR(32)`
- **Retorno**: `v_user_id NUMBER`
- **Descrição**: Recebe o CPI do líder e sua senha de usuário. Verifica se existe um usuário no banco para esse líder e se sua senha está correta. Retorna o id do usuário, caso este seja válido. 
- **Objetivo**: Permitir que o login na aplicação seja validado com base na tabela *USERS* do banco.
- **Exceções**: `OR-20001`, `OR-20002`

### FUNC_BUSCA_CARGO_USUARIO
- **Implementação**: `users.sql`
- **Parâmetros**: `p_id_lider CHAR(14)`
- **Retorno**: `v_cargo_usuario CHAR(10)`
- **Descrição**: Recebe o CPI do líder, pesquisa seu cargo na tabela *LIDER* e o retorna. 
- **Objetivo**: Permitir que a aplicação controle as permissões de acesso às funcionalidades para cada usuário com base no seu cargo.
- **Exceções**: `OR-20001`

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
- **Exceções**: `OR-20001`
