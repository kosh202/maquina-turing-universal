# Máquina de Turing Universal (MTU) em Ruby

Este repositório implementa uma Máquina de Turing Universal (MTU) em Ruby, usada para simular uma Máquina de Turing M rodando sobre uma fita de entrada w. O projeto foi feito sem dependências externas e com foco em ensino e experimentação.

---

## Requisitos

- Ruby instalado (versão 2.5+ recomendada).

---

## Estrutura do projeto

```text
.
├── mtu.rb                 # Núcleo da MTU (simulador)
├── testar-todos.rb        # Executa a suíte de testes definida em `entradas/`
├── testar_unitario.rb     # Executa um único arquivo de entrada para depuração
├── entradas/              # Arquivos de entrada (regras + cadeia)
│   ├── livre_contexto.txt
│   ├── regular.txt
│   ├── sensivel.txt
│   └── teste1.txt
└── README.md
```

Observação: os scripts usam a pasta `entradas/`.

---

## Formato de arquivo de entrada

Cada arquivo em `entradas/` deve conter duas partes separadas por `#`:

- à esquerda: as regras de transição da máquina;
- à direita: a cadeia de entrada codificada.

A parte de regras pode ocupar várias linhas. A cadeia aparece depois do `#`.

Exemplo:

```text
fa sc faa scccc d
faa scc fa scc e
...                # outras transições
# sc sc scc scc    # cadeia codificada
```

Cada transição deve ter 5 campos separados por espaço:

- Estado atual (ex: `fa`, `faa`)
- Símbolo lido (ex: `sc`, `scc`, `_`)
- Estado destino (ex: `faa`, `fb`)
- Símbolo escrito (ex: `scccc`, `_`)
- Movimento (`d` = direita, `e` = esquerda)

Observação: o campo de movimento aceita apenas `d` ou `e`.

### Mapeamento recomendado de símbolos

- `sc` → `a`
- `scc` → `b`
- `sccc` → `c`
- `scccc` → marcador X
- `sccccc` → marcador Y
- `scccccc` → marcador Z
- `_` → espaço branco (fita vazia)

---

## Exemplo prático: criar uma entrada para a linguagem regular `a*b*`

Crie o arquivo `entradas/exemplo_regular.txt` com o conteúdo abaixo:

```text
fa sc fa sc d
fa scc fb scc d
fb scc fb scc d
# sc sc scc scc
```

Neste exemplo:

- as primeiras linhas são as transições da máquina;
- a linha com `#` separa as transições da cadeia de entrada;
- a cadeia `sc sc scc scc` representa `aabb`.

### Como rodar

```bash
ruby testar_unitario.rb entradas/exemplo_regular.txt
```

Para executar todos os testes:

```bash
ruby testar-todos.rb
```

---

## Como funciona `entradas/livre_contexto.txt`

Este arquivo contém as transições de uma máquina que aceita a linguagem livre de contexto `a^n b^n`.

- A primeira parte do arquivo traz as transições.
- A linha `#` separa as transições da cadeia de entrada.
- A segunda parte traz a cadeia codificada.

No arquivo atual, a cadeia é escrita como `scscsccscc`.

Isso corresponde, em tokens, a:

- `sc` → `a`
- `sc` → `a`
- `scc` → `b`
- `scc` → `b`

Ou seja, a cadeia lógica é `aabb`.

> Observação: alguns arquivos usam a forma com espaços, como `sc sc scc scc`. Ambos os formatos representam a mesma sequência, desde que o parser aceite a leitura correta.

---

## Dicas rápidas

- Use espaços entre símbolos para facilitar a leitura (`sc sc scc`).
- Garanta que o arquivo contenha apenas um `#` separando transições e cadeia.
- Se o programa terminar sem encontrar uma regra válida, a cadeia é rejeitada.

---

## Exemplo de arquivo `entradas/regular.txt`

Este exemplo mostra como uma máquina pode ler a cadeia `aabb` e aceitar o final da fita.

```text
fa sc fa sc d
fa scc faa scc d
faa scc faa scc d
fa _ fb _ d
faa _ fb _ d

# sc sc scc scc
```

Explicação do fluxo:

- o motor lê `sc` (a) e `scc` (b);
- ao alcançar `_`, ele vai para o estado final `fb`;
- se chegar a um estado de aceitação válido, a cadeia é aceita.

---

## Sobre os exemplos obrigatórios

1. `entradas/livre_contexto.txt`
   - Cadeia codificada: `scscsccscc` (corresponde a `aabb`).
   - Lógica: busca um `a` (`sc`), marca-o como `X` e encontra o `b` correspondente (`scc`), marcando-o como `Y`.

2. `entradas/sensivel.txt`
   - Cadeia codificada: `scscsccsccscccsccc` (corresponde a `aabbcc`).
   - Lógica: marca `a`, depois `b`, depois `c`; repete o ciclo até todos os símbolos estarem balanceados.
