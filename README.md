# Máquina de Turing Universal (MTU)

Este projeto implementa uma simulação simples de uma Máquina de Turing Universal em Ruby. A ideia é carregar a definição de transições e a fita de entrada a partir de um arquivo de cenário, executar passo a passo e determinar se a cadeia é aceita ou rejeitada.

## Estrutura do projeto

- `mtu.rb` - Classe principal que representa a Máquina de Turing Universal, suas transições, fita e execução.
- `testar_unitario.rb` - Script para executar um único cenário de teste. Pode usar um arquivo de entrada padrão ou um caminho passado por argumento.
- `testar-todos.rb` - Script para executar uma suíte de testes com três cenários predefinidos.
- `entradas/` - Pasta contendo arquivos de cenário com a definição da máquina e a fita de entrada.

## Requisitos

- Ruby instalado no seu sistema.
- Executar os scripts a partir da pasta raiz do repositório `maquina-turing-universal`.

## Formato dos arquivos de cenário

Cada arquivo de cenário deve ter duas seções separadas pelo caractere `#`:

1. Definição de transições
2. Fita de entrada

### Exemplo

```text
fa sc fa sc d
fa scc faa scc d
faa scc faa scc d
fa _ fb _ d
faa _ fb _ d
#
scscsccscc
```

Cada linha de transição deve conter exatamente 5 campos separados por espaços:

- `origem` - estado atual
- `lido` - símbolo lido na fita
- `destino` - próximo estado
- `escrito` - símbolo a ser escrito na fita
- `movimento` - direção do ponteiro (`d` para direita, `e` para esquerda)

A fita de entrada aparece após o `#` e pode conter símbolos como `sc`, `scc` e `_`.

## Como rodar

### Executar um teste único

```bash
ruby testar_unitario.rb entradas/teste1.txt
```

Se nenhum argumento for passado, o script usa por padrão o arquivo `entradas/teste1.txt`.

### Executar a suíte de testes

```bash
ruby testar-todos.rb
```

Este script executa três cenários predefinidos que cobrem exemplos de linguagens:

- Regular: `a*b*`
- Livre de contexto: `a^n b^n`
- Sensível ao contexto: `a^n b^n c^n`

## O que cada arquivo faz

- `mtu.rb`
  - Define a classe `Transicao` para representar uma transição da máquina.
  - Define a classe `MTU`, que carrega cenários, busca transições, atualiza a fita, e executa a máquina até aceitar ou rejeitar.
  - Exibe a configuração passo a passo durante a simulação.

- `testar_unitario.rb`
  - Abre um arquivo de cenário especificado por argumento ou usa o cenário padrão.
  - Exibe as transições carregadas.
  - Executa a máquina passo a passo e mostra se a cadeia foi aceita ou rejeitada.

- `testar-todos.rb`
  - Executa vários cenários em sequência.
  - Compara o resultado obtido com o resultado esperado.
  - Exibe um resumo de quantos testes passaram e quantos falharam.

## Observações

- O programa lê o arquivo de cenário inteiro como uma string, separa as transições e a entrada pelo `#`, e converte a cadeia em símbolos na fita.
- A máquina aceita um estado se o estado atual começar com `fb`.
- A fita é estendida automaticamente com `_` quando o ponteiro se move além do comprimento disponível.

## Dicas

- Edite ou adicione novos cenários em `entradas/` para testar outras máquinas.
- Use `ruby testar_unitario.rb entradas/arquivo.txt` para validar um único caso específico.
- Para ver todos os casos obrigatórios juntos, use `ruby testar-todos.rb`.
