# Criação do banco
Para criar o esquema do banco do zero, ou seja, para criar todas as tabelas, sequências, funções e procedimentos desenvolvidos até agora e inserir os dados na base, execute os scripts na seguinte ordem:

1. `esquema.sql`
2. `insercao.sql`
3. `users.sql`
4. `log.sql`
5. `views.sql`
6. `triggers.sql`
7. `lider-faccao.sql`
8. `comandante.sql`
9. `cientista.sql`


# Remoção do banco
Caso seja necessário remover todas as tabelas, sequências, funções e procedimentos do banco, basta executar o script `remover-esquema.sql`.


# Exceções personalizadas
As seguintes exceções foram definidas pelo banco no desenvolvimento de algumas funções/procedimentos:
1. `ORA-20001`: Objeto não encontrado *(ex.: 'Usuario nao encontrado', 'Estrela nao encontrada')*.
2. `ORA-20002`: Senha inválida.
3. `ORA-20003`: Objeto já existe *(ex.: 'Estrela ja existe, altere o ID e tente novamente')*.
4. `ORA-20004`: Atributo não pode ser nulo *(ex.: 'Os atributos "ID_ESTRELA", "X", "Y" e "Z" nao podem ser nulos.')*.
5. `ORA-20005`: Regra semântica violada *(ex.: 'Sua nacao ja faz parte dessa federacao')*.


# Funções disponíveis
As seguintes funções foram desenvolvidas no banco e podem ser utilizadas pela aplicação:
- `FUNC_VALIDA_USUARIO(p_id_lider, p_senha): NUMBER`
- `FUNC_BUSCA_CARGO_USUARIO(p_id_lider): CHAR(10)`
- `FUNC_VALIDA_LIDER_FACCAO(p_id_lider): NUMBER`

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


# Procedimentos disponíveis
Os seguintes procedimentos foram desenvolvidos no banco e podem ser utilizados pela aplicação:
- `PROC_INSERIR_LOG(p_user_id, p_mensagem)`

### PROC_INSERIR_LOG
- **Implementação**: `log.sql`
- **Parâmetros**: `p_user_id NUMBER`, `p_mensagem VARCHAR(255)`
- **Descrição**: Recebe o id do usuário que acessou o sistema/executou a operação e a mensagem do log. Insere uma nova entrada na tabela de logs, utilizando o id do usuário, a data-hora atual do sistema e a mensagem especificada.
- **Objetivo**: Permitir que a tabela de logs seja mantida por chamadas da aplicação.
- **Exceções**: `ORA-20001` - Usuário não encontrado.


# Pacotes disponíveis
Os seguintes pacotes foram desenvolvidos no banco e podem ser utilizados pela aplicação:
1. `PAC_FUNC_CIENTISTA`: Pacote que incluí todas as funcionalidades de gerenciamento para usuários do tipo 'Cientista'.
2. `PAC_FUNC_COMANDANTE`: Pacote que incluí todas as funcionalidades de gerenciamento para usuários do tipo 'Comandante'.
3. `PAC_FUNC_LIDER_FACCAO`: Pacote que incluí todas as funcionalidades de gerenciamento para usuários do tipo 'Líder de Facção'.


## PAC_FUNC_CIENTISTA
Inclui as seguintes funções/procedimentos:
1. `criar_estrela(p_estrela)`
2. `buscar_estrela(p_id_estrela): ESTRELA`
3. `atualizar_estrela(p_estrela)`
4. `remover_estrela(p_id_estrela)`

### 1. CRIAR_ESTRELA
- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_estrela ESTRELA`
- **Descrição**: Recebe um objeto do tipo estrela e o insere na tabela *ESTRELA*.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam inserir novas estrelas na base de dados.
- **Exceções**:
    1. `ORA-20003` - Estrela já existe, altere o ID e tente novamente.
    2. `ORA-20003` - Estrela já existe, altere as coordenadas e tente novamente.
    3. `ORA-20004` - Os atributos "ID_ESTRELA", "X", "Y" e "Z" não podem ser nulos.

### 2. BUSCAR_ESTRELA
- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_id_estrela VARCHAR2(31)`
- **Retorno**: `p_estrela ESTRELA`
- **Descrição**: Recebe um id de estrela, busca na tabela *ESTRELA* e retorna a estrela encontrada.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam buscar estrelas pelo id na base de dados.
- **Exceções**: `ORA-20001` - Estrela não encontrada.

### 3. ATUALIZAR_ESTRELA
- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_estrela ESTRELA`
- **Descrição**: Recebe um objeto do tipo estrela e o atualiza na tabela *ESTRELA* com base no id do objeto.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam atualizar os dados das estrelas na base.
- **Exceções**:
    1. `ORA-20001` - Estrela não encontrada.
    2. `ORA-20004` - Os atributos "ID_ESTRELA", "X", "Y" e "Z" não podem ser nulos.

### 4. REMOVER_ESTRELA
- **Implementação**: `cientista.sql`
- **Parâmetros**: `p_id_estrela VARCHAR2(31)`
- **Descrição**: Recebe um id de estrela e a remove da tabela *ESTRELA*.
- **Objetivo**: Permitir que os usuários do tipo 'Cientista' possam remover estrelas pelo id na base de dados.
- **Exceções**: `ORA-20001` - Estrela não encontrada.


## PAC_FUNC_COMANDANTE
Inclui as seguintes funções/procedimentos:
1. `incluir_propria_nacao(p_nome_federacao, p_id_lider)`
2. `excluir_propria_nacao(p_nome_federacao, p_id_lider)`
3. `criar_federacao(p_federacao, p_id_lider)`
4. `inserir_dominancia(p_id_planeta, p_data_ini, p_id_lider)`

### 1. INCLUIR_PROPRIA_NACAO
- **Implementação**: `comandante.sql`
- **Parâmetros**: `p_nome_federacao VARCHAR2(15)`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe o nome de uma federação existente e o CPI do líder. Busca a nação do líder, verifica se ela já não está inclusa na federação em questão ou em alguma outra federação, e então atualiza a tabela *NACAO* para incluir a nação do líder na federação especificada.
- **Objetivo**: Permitir que os usuários do tipo 'Comandante' possam inserir sua própria nação em uma federação existente.
- **Exceções**:
    1. `ORA-20001` - Líder não encontrado.
    2. `ORA-20001` - Federação não encontrada.
    3. `ORA-20005` - Sua nação já faz parte dessa federação.
    4. `ORA-20005` - Sua nação está atualmente incluída na federação "[nome-federacao]". Exclua essa associação e tente novamente.

### 2. EXCLUIR_PROPRIA_NACAO
- **Implementação**: `comandante.sql`
- **Parâmetros**: `p_nome_federacao VARCHAR2(15)`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe o nome de uma federação existente e o CPI do líder. Busca a nação do líder, verifica se ela está de fato inclusa na federação em questão, e então atualiza a tabela *NACAO* para excluir a nação do líder da federação especificada. Também excluí a federação em questão da tabela *FEDERACAO*, caso ela não esteja mais associada a nenhuma nação.
- **Objetivo**: Permitir que os usuários do tipo 'Comandante' possam remover sua própria nação de uma federação existente.
- **Exceções**:
    1. `ORA-20001` - Líder não encontrado.
    2. `ORA-20005` - Sua nação não faz parte de nenhuma federação.
    3. `ORA-20005` - Sua nação não está incluída na federação "[nome-federacao]".

### 3. CRIAR_FEDERACAO
- **Implementação**: `comandante.sql`
- **Parâmetros**: `p_federacao FEDERACAO`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe um objeto do tipo federação e o CPI do líder. Busca a nação do líder, verifica se ela já não está associada a uma federação, e então cria a nova federação na tabela *FEDERACAO*. Em seguida, atualiza a tabela *NACAO* para associar a nação do líder à federação criada.
- **Objetivo**: Permitir que os usuários do tipo 'Comandante' possam criar novas federações utilizando sua própria nação.
- **Exceções**:
    1. `ORA-20001` - Líder não encontrado.
    2. `ORA-20003` - Federação já existe, altere o nome e tente novamente.
    3. `ORA-20004` - Os atributos "NOME" e "DATA_FUND" não podem ser nulos.
    4. `ORA-20005` - Sua nação está atualmente incluída na federação "[nome-federacao]". Exclua essa associação e tente novamente.

### 4. INSERIR_DOMINANCIA
- **Implementação**: `comandante.sql`
- **Parâmetros**: `p_id_planeta VARCHAR2(15)`, `p_data_ini DATE`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe o id de um planeta, uma data de início e o CPI do líder. Busca a nação do líder, verifica se o planeta não está sendo dominado por ninguém atualmente e então insere a nova dominância. Também ajusta a quantidade de planetas dominados pela nação em questão na tabela *NACAO*.
- **Objetivo**: Permitir que os usuários do tipo 'Comandante' possam inserir novas dominâncias da própria nação.
- **Exceções**:
    1. `ORA-20001` - Líder não encontrado.
    2. `ORA-20001` - Planeta não encontrado.
    3. `ORA-20004` - Os atributos "PLANETA", "NACAO" e "DATA_INI" não podem ser nulos.
    4. `ORA-20005` - Esse planeta já esta sendo dominado.


## PAC_FUNC_LIDER_FACCAO
Inclui as seguintes funções/procedimentos:
1. `alterar_nome_faccao(p_novo_nome_faccao, p_id_lider)`
2. `indicar_novo_lider(p_id_novo_lider, p_id_lider_atual)`
3. `credenciar_nova_comunidade(p_nome_especie, p_nome_comunidade, p_id_lider)`
4. `remover_faccao_de_nacao(p_nome_faccao, p_nome_nacao)`

### 1. ALTERAR_NOME_FACCAO
- **Implementação**: `lider-faccao.sql`
- **Parâmetros**: `p_novo_nome_faccao VARCHAR(15)`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe o novo nome que a facção deverá ter e o id do líder. Busca a facção do líder e verifica se o novo nome é diferente do nome atual da facção. Caso seja, remove todas as nações associadas e todas as comunidades credenciadas na nação em questão (para que seja possível atualizar o nome), atualiza o nome da facção e então insere novamente todas as nações associadas e comunidades credenciadas com o novo nome.
- **Triggers**: Desencadeia o compound trigger `TRIG_ALTERAR_NOME_FACCAO` ao realizar o *UPDATE* do nome na tabela *FACCAO*.
- **Objetivo**: Permitir que os usuários do tipo 'Líder de Facção' possam alterar o nome da própria facção.
- **Exceções**:
    1. `ORA-20001` - Líder de facção não encontrado.
    2. `ORA-20005` - O novo nome da facção deve ser diferente do nome atual.

### 2. INDICAR_NOVO_LIDER
- **Implementação**: `lider-faccao.sql`
- **Parâmetros**: `p_id_novo_lider CHAR(14)`, `p_id_lider_atual CHAR(14)`
- **Descrição**: Recebe o id do líder que está sendo indicado e o id do atual líder da facção. Busca a facção do líder atual e atualiza o líder na tabela *FACCAO* com o id do novo líder.
- **Triggers**: Desencadeia o trigger `TRIG_VALIDA_NACAO_NOVO_LIDER` ao realizar o *UPDATE* na tabela *FACCAO*.
- **Objetivo**: Permitir que os usuários do tipo 'Líder de Facção' possam indicar um novo líder para a própria facção.
- **Exceções**:
    1. `ORA-20001` - Líder de facção não encontrado.
    2. `ORA-20004` - O atributo "LIDER" não pode ser nulo. Indique o CPI do novo líder e tente novamente.
    3. `ORA-20005` - A facção "[nome-faccao]" não está presente na nação do líder "[nome-lider]". Escolha outro líder e tente novamente.


### 3. CREDENCIAR_NOVA_COMUNIDADE
- **Implementação**: `lider-faccao.sql`
- **Parâmetros**: `p_nome_especie VARCHAR2(15)`, `p_nome_comunidade VARCHAR2(15)`, `p_id_lider CHAR(14)`
- **Descrição**: Recebe o nome da espécie e da comunidade que será credenciada, assim como o id do líder. Busca a facção do líder, verifica se os nomes de espécie e comunidade informados não são nulos, verifica se a comunidade existe e então insere a participação da comunidade na facção do líder através da view `VIEW_COMUNIDADE_CREDENCIADA`.
- **Objetivo**: Permitir que os usuários do tipo 'Líder de Facção' possam credenciar comunidades novas que habitem planetas dominados por nações onde a própria facção está presente.
- **Triggers**: Desencadeia o trigger `TRIG_CREDENCIAR_COMUNIDADE` ao realizar um *INSERT* na view `VIEW_COMUNIDADE_CREDENCIADA`.
- **Exceções**:
    1. `ORA-20001` - Líder de facção não encontrado.
    2. `ORA-20001` - Comunidade não encontrada.
    3. `ORA-20003` - Comunidade já credenciada na sua facção, altere a comunidade e tente novamente.
    4. `ORA-20004` - Os atributos "ESPECIE" e "COMUNIDADE" não podem ser nulos.
    5. `ORA-20005` - Somente comunidades que habitam um planeta dominado por uma nação associada à sua facção podem ser credenciadas.

### 4. REMOVER_FACCAO_DE_NACAO
- **Implementação**: `lider-faccao.sql`
- **Parâmetros**: `p_nome_faccao VARCHAR2(15)`, `p_nome_nacao VARCHAR2(15)`
- **Descrição**: Recebe o nome de uma facção e de uma nação e remove a associação entre a nação e facção em questão da tabela *NACAO_FACCAO*. Também ajusta a quantidade de nações da facção em questão na tabela *FACCAO*.
- **Objetivo**: Permitir que os usuários do tipo 'Líder de Facção' possam remover facções de nações.
- **Exceções**:
    1. `ORA-20001` - Facção não encontrada. 
    2. `ORA-20001` - Associação de nação-facção não encontrada.
    3. `ORA-20005` - O líder da facção "[nome-faccao]" pertence a nação "[nome-nacao]" e, portanto, tal facção nao pode ser removida dessa nação.

## Relatorios_Lider_de_Faccao
Inclui as seguintes funções/procedimentos:
1. `Gerar_Relatorio(lider_logado, ordenar_por)`

### 1. Gerar_Relatorio
- **Implementação**: `relatorios_lider.sql`
- **Parâmetros**: `lider_logado lider%ROWTYPE`, `ordenar_por VARCHAR2`
- **Descrição**: Gera um relatório mostrando informações de todas as comunidades da Facção comandada pelo lider passado, e agrupa pelo atributo passo no segundo parâmetro, podendo ser: NACAO, SISTEMA, ESPECIE ou PLANETA.
- **Objetivo**: Permitir que qualquer lider de facção gere relatórios que possibilitem acompanhar suas comunidades.

## Relatorios_Oficial
Inclui as seguintes funções:
1. `Gerar_Relatorio_Habitantes_Geral(lider_logado)`
2. `Gerar_Relatorio_Habitantes_Faccao(lider_logado)`
3. `Gerar_Relatorio_Habitantes_Sistemas(lider_logado)`
4. `Gerar_Relatorio_Habitantes_Planetas(lider_logado)`
5. `Gerar_Relatorio_Habitantes_Especies(lider_logado)`

### 1. Gerar_Relatorio_Habitantes_Geral
- **Implementação**: `relatorios_oficial.sql`
- **Parâmetros**: `lider_logado lider%ROWTYPE`
- **Descrição**: Gera um relatório mostrando informações de todas as comunidades da Nação do lider passado.

### 2. Gerar_Relatorio_Habitantes_Faccao
- **Implementação**: `relatorios_oficial.sql`
- **Parâmetros**: `lider_logado lider%ROWTYPE`
- **Descrição**: Gera um relatório mostrando a quantidade de habitantes em comunidades onde cada facção que se relaciona com a nação do lider passado está presente.

### 3. Gerar_Relatorio_Habitantes_Sistemas
- **Implementação**: `relatorios_oficial.sql`
- **Parâmetros**: `lider_logado lider%ROWTYPE`
- **Descrição**: Gera um relatório mostrando a quantidade de habitantes em cada sistema em que a nação do lider está presente.

### 4. Gerar_Relatorio_Habitantes_Especies
- **Implementação**: `relatorios_oficial.sql`
- **Parâmetros**: `lider_logado lider%ROWTYPE`
- **Descrição**: Gera um relatório mostrando a quantidade de habitantes de cada espécie na nação do lider.