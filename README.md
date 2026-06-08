<h1 align="center">🧠 Máquina de Turing Universal (MTU)</h1>

<p align="center">
  <i>Uma Máquina de Turing que lê, decodifica e simula <b>qualquer outra</b> Máquina de Turing.</i>
</p>

<p align="center">
  <img alt="Ruby" src="https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white">
  <img alt="Sem dependências" src="https://img.shields.io/badge/dependências-nenhuma-success">
  <img alt="Testes" src="https://img.shields.io/badge/testes-3%2F3%20passando-brightgreen">
  <img alt="Disciplina" src="https://img.shields.io/badge/Linguagens%20Formais-SENAC-blue">
</p>

---

## 📜 Sobre o projeto

A **Máquina de Turing Universal (MTU)**, proposta por Alan Turing em 1936, é uma
Máquina de Turing especial: em vez de resolver um problema fixo, ela recebe na
fita a **descrição de outra máquina `M`** seguida de uma **cadeia de entrada `w`**,
e então **simula `M` rodando sobre `w`**. É a prova de que uma única máquina pode
executar qualquer algoritmo computável.

Este repositório implementa uma MTU em **Ruby puro**, sem gems e sem nenhuma
biblioteca de simulação. A linguagem reconhecida é:

```
L = { C(M)·w  ∈  Σ*  |  w ∈ L(M) }
```

onde `C(M)` é a codificação de uma Máquina de Turing `M` e `w` é uma cadeia de
entrada qualquer para ela.

> 💡 A MTU **não** carrega as regras com um parser de propósito geral: ela
> percorre a fita **caractere a caractere**, com um cabeçote, usando **apenas
> transições de estado** — exatamente como uma Máquina de Turing faria.

---

## 🔤 Codificação

Toda a entrada da MTU é uma **única cadeia** sobre o alfabeto da codificação:

| Elemento | Codificação | Exemplos |
| --- | --- | --- |
| Estados de **não** aceitação | `f` + `a`'s | `fa`, `faa`, `faaa`, … |
| Estados de **aceitação** | `f` + `b`'s | `fb`, `fbb`, `fbbb`, … |
| Símbolos da fita | `s` + `c`'s | `sc`, `scc`, `sccc`, … |
| Símbolo branco | — | `_` |
| Movimento do cabeçote | — | `d` (direita), `e` (esquerda) |
| Separador `C(M)` / `w` | — | `#` |

Cada transição `(origem, lido) -> (destino, escrito, movimento)` é codificada
pela **concatenação direta** dos cinco campos:

```
(fa, sc)    -> (fa, sc, d)     =>   fascfascd
(faaaa, _)  -> (fb, _, d)      =>   faaaa_fb_d
```

A codificação é **auto-delimitável**, então a MTU sabe onde cada token começa e
termina lendo um caractere por vez:

```
 f  ->  começa um ESTADO          s      ->  começa um SÍMBOLO
 _  ->  símbolo branco completo   d / e  ->  movimento
 #  ->  separa C(M) de w
```

---

## 🧩 Como funciona — duas fases

```
   FITA DA MTU:   fascfascd ... fa_fb_d # scscsccscc
                  \____________________/ \__________/
                          C(M)                 w
                            |
        +-------------------+-------------------+
        |                                       |
        v                                       v
  (1) LEITURA / DECODIFICACAO            (2) SIMULACAO de M sobre w
  A MTU anda pela fita com seus           A MTU executa M: le a fita,
  estados internos                        escreve, troca de estado e
  (ler_origem -> ler_lido ->              move o cabecote (d/e).
   ler_destino -> ler_escrito ->
   ler_movimento -> ler_w)                ACEITA  -> M chega a um estado
  e monta a LISTA de transicoes.                     de aceitacao (fb...)
                                          REJEITA -> nao ha transicao
```

**(1) Leitura (a parte "universal"):** começando em `ler_origem`, a MTU consome
um caractere por passo, move o cabeçote para a direita e, ao completar os cinco
campos de uma regra, registra essa transição de `M` numa **lista** (não em
tabela/hash). Ao encontrar `#`, passa a ler a cadeia `w`.

**(2) Simulação:** a MTU roda `M` sobre `w` como uma Máquina de Turing comum.
A cadeia é **aceita** quando `M` atinge um estado de aceitação (que começa com
`fb`) e **rejeitada** quando não existe transição aplicável.

---

## 📁 Estrutura

```text
.
├── mtu.rb                 # A MTU: lê C(M)#w da fita, decodifica M e simula M sobre w
├── testar-todos.rb        # Roda os 3 cenários obrigatórios e gera um relatório
├── testar_unitario.rb     # Roda um único arquivo, mostrando a MTU lendo a fita
├── entradas/              # Cenários no formato C(M)#w (uma linha cada)
│   ├── regular.txt        #   Linguagem Regular            ->  a*b*
│   ├── livre_contexto.txt #   Linguagem Livre de Contexto  ->  a^n b^n
│   ├── sensivel.txt       #   Linguagem Sensível ao Ctx.   ->  a^n b^n c^n
│   ├── teste1.txt         #   Caso extra (a^n b^n com a^3 b^2)
│   └── teste_erro.txt     #   Caso extra de rejeição
└── README.md
```

### Formato do arquivo de entrada

Cada arquivo é **uma linha** no formato `C(M)#w`:

```text
fascfascdfasccfaasccdfaasccfaasccdfa_fb_dfaa_fb_d#scscsccscc
\_______________________________________________/ \________/
                      C(M)                              w
```

> Espaços e quebras de linha, se você quiser usar para facilitar a leitura, são
> ignorados pela MTU.

---

## ▶️ Como rodar

Pré-requisito: **Ruby** instalado (`ruby -v`).

Rodar os três cenários obrigatórios:

```bash
ruby testar-todos.rb
```

Rodar um cenário específico, com o passo a passo da MTU lendo a fita e simulando `M`:

```bash
ruby testar_unitario.rb entradas/sensivel.txt
```

---

## ✅ Cenários obrigatórios

| # | Classe | Linguagem | Arquivo | Cadeia testada | Resultado |
|---|--------|-----------|---------|----------------|-----------|
| 1 | Regular | `a*b*` | `entradas/regular.txt` | `aabb` | aceita |
| 2 | Livre de Contexto | `a^n b^n` | `entradas/livre_contexto.txt` | `aabb` | aceita |
| 3 | Sensível ao Contexto | `a^n b^n c^n` | `entradas/sensivel.txt` | `aabbcc` | aceita |

Mapeamento dos símbolos nos exemplos: `sc -> a`, `scc -> b`, `sccc -> c`
(os símbolos maiores — `scccc`, `sccccc`, `scccccc` — são marcadores internos
que cada máquina usa para "riscar" os símbolos já casados).

- **`a^n b^n`** — marca cada `a`, procura o `b` correspondente, marca-o, e volta;
  repete até equilibrar. Sobra de `a` ou de `b` significa rejeição.
- **`a^n b^n c^n`** — mesma ideia em três tempos: casa um `a`, um `b` e um `c`
  por ciclo, até todos estarem balanceados.

---

## 🔍 Exemplo de execução

```bash
$ ruby testar_unitario.rb entradas/regular.txt
```

```text
  [MTU] passo 0  cursor=0  estado=ler_origem  le 'f'
  [MTU] passo 1  cursor=1  estado=ler_origem  le 'a'
  [MTU] passo 2  cursor=2  estado=ler_origem  le 's'
  ...
  [MTU] -> transicao decodificada: (fa,sc) -> (fa,sc,d)
  ...
Estado Atual : fb
Fita         : sc sc scc scc _
CADEIA ACEITA!
```

---

## 🚫 Restrições respeitadas

- ✔️ Repositório **exclusivo** para este trabalho.
- ✔️ Codificação **exatamente** no formato especificado.
- ✔️ Máquinas e entradas em **arquivos separados**.
- ✔️ **Sem** gems ou bibliotecas de simulação de Máquina de Turing.
- ✔️ **Sem** tabelas/hash na lógica da MTU — apenas transições de estado.

---

<p align="center"><sub>Disciplina de Linguagens Formais e Autômatos</sub></p>
