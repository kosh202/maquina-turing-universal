# ==========================================================================
#  Máquina de Turing Universal (MTU)
# --------------------------------------------------------------------------
#  Esta MTU é, ela mesma, uma Máquina de Turing: ela recebe na fita a string
#  concatenada  C(M)#w  e a LÊ caractere por caractere, com um cabeçote que
#  anda para a direita, decodificando as transições da máquina M codificada.
#  Depois, simula M sobre a cadeia w.
#
#  Codificação (conforme enunciado):
#    - Estados de NÃO aceitação : "fa", "faa", "faaa", ...   (f + a's)
#    - Estados de aceitação     : "fb", "fbb", "fbbb", ...   (f + b's)
#    - Símbolos da fita         : "sc", "scc", "sccc", ...   (s + c's)
#    - Símbolo branco           : "_"
#    - Movimentos               : "d" (direita), "e" (esquerda)
#    - Separador C(M) / w       : "#"
#
#  Uma transição  (origem, lido) -> (destino, escrito, mov)  é codificada pela
#  simples concatenação dos cinco campos. Ex.: (fa,sc)->(fa,sc,d) = "fascfascd".
#  A codificação é auto-delimitável: 'f' inicia um estado, 's' inicia um
#  símbolo, '_' é um símbolo branco completo, e 'd'/'e' são movimentos. Por
#  isso a MTU consegue identificar as fronteiras dos tokens lendo um caractere
#  de cada vez, sem usar tabelas/hash — apenas transições de estado.
# ==========================================================================

class MTU
  ESTADO_INICIAL_M = "fa".freeze  # estado inicial de M (codificação do estado "a")

  attr_accessor :verbose

  def initialize
    @fita       = ""            # fita da MTU: a string C(M)#w
    @cursor     = 0             # cabeçote da MTU
    @estado     = :ler_origem   # estado interno da MTU
    @transicoes = []            # lista de transições decodificadas (NÃO é hash)
    @w          = []            # cadeia de entrada de M, como lista de símbolos
    @verbose    = false
  end

  # -------------------------------------------------------------------------
  #  Carga do cenário: lê o arquivo (formato C(M)#w) e decodifica
  # -------------------------------------------------------------------------
  def carregar_cenario(caminho_arquivo)
    unless File.exist?(caminho_arquivo)
      puts "Erro: Arquivo #{caminho_arquivo} não encontrado."
      exit
    end

    # Remove qualquer espaço em branco/quebra de linha: aceita tanto o formato
    # 100% concatenado quanto uma escrita espaçada para leitura humana.
    @fita = File.read(caminho_arquivo).gsub(/\s+/, "")

    unless @fita.include?("#")
      puts "Erro: cenário inválido. Esperado o formato C(M)#w (com '#')."
      exit
    end

    decodificar
  end

  # -------------------------------------------------------------------------
  #  A MTU lê a fita como uma Máquina de Turing e decodifica C(M) e w.
  #  Cada `in [...]` abaixo é uma transição de estado da PRÓPRIA MTU.
  # -------------------------------------------------------------------------
  def decodificar
    @cursor = 0
    @estado = :ler_origem
    origem = ""; lido = ""; destino = ""; escrito = ""
    w_tok = ""
    passo = 0

    loop do
      c = @fita[@cursor]
      break if c.nil?

      if @verbose
        puts format("  [MTU] passo %-3d cursor=%-3d estado=%-13s lê '%s'",
                    passo, @cursor, @estado, c)
      end
      passo += 1

      case [@estado, c]

      # --------- ORIGEM: estado de origem (f a* / f b*) ---------
      in [:ler_origem, "f"] | [:ler_origem, "a"] | [:ler_origem, "b"]
        origem << c
        mover(:ler_origem)
      in [:ler_origem, "s"]            # fim da origem; inicia o símbolo lido
        lido = "s"
        mover(:ler_lido)
      in [:ler_origem, "_"]            # símbolo lido é branco
        lido = "_"
        mover(:ler_destino)
      in [:ler_origem, "#"]            # fim das transições; passa a ler w
        mover(:ler_w)

      # --------- LIDO: símbolo (s c*) ---------
      in [:ler_lido, "c"]
        lido << c
        mover(:ler_lido)
      in [:ler_lido, "f"]              # fim do símbolo; inicia o estado destino
        destino = "f"
        mover(:ler_destino)

      # --------- DESTINO: estado destino (f a* / f b*) ---------
      in [:ler_destino, "f"] | [:ler_destino, "a"] | [:ler_destino, "b"]
        destino << c
        mover(:ler_destino)
      in [:ler_destino, "s"]           # fim do destino; inicia o símbolo escrito
        escrito = "s"
        mover(:ler_escrito)
      in [:ler_destino, "_"]           # símbolo escrito é branco; vem o movimento
        escrito = "_"
        mover(:ler_movimento)

      # --------- ESCRITO: símbolo (s c*) ---------
      in [:ler_escrito, "c"]
        escrito << c
        mover(:ler_escrito)
      in [:ler_escrito, "d"] | [:ler_escrito, "e"]   # este char já é o movimento
        registrar(origem, lido, destino, escrito, c)
        origem = ""; lido = ""; destino = ""; escrito = ""
        mover(:ler_origem)

      # --------- MOVIMENTO (após símbolo escrito branco) ---------
      in [:ler_movimento, "d"] | [:ler_movimento, "e"]
        registrar(origem, lido, destino, escrito, c)
        origem = ""; lido = ""; destino = ""; escrito = ""
        mover(:ler_origem)

      # --------- W: cadeia de entrada (sequência de símbolos) ---------
      in [:ler_w, "s"]
        @w << w_tok unless w_tok.empty?
        w_tok = "s"
        mover(:ler_w)
      in [:ler_w, "c"]
        w_tok << c
        mover(:ler_w)
      in [:ler_w, "_"]
        @w << w_tok unless w_tok.empty?
        @w << "_"
        w_tok = ""
        mover(:ler_w)

      else
        # Caractere inesperado: avança para não travar (robustez).
        mover(@estado)
      end
    end

    @w << w_tok unless w_tok.empty?
  end

  # -------------------------------------------------------------------------
  #  Simulação de M sobre w: M também é uma Máquina de Turing (lê fita,
  #  escreve, troca de estado e move o cabeçote para 'd'/'e').
  # -------------------------------------------------------------------------
  def executar
    estado_m = ESTADO_INICIAL_M
    cursor   = 0
    fita     = @w.dup
    fita     = ["_"] if fita.empty?
    passo    = 0

    loop do
      mostrar_configuracao(estado_m, fita, cursor)
      puts "----------------"

      if aceitacao?(estado_m)
        puts "CADEIA ACEITA!"
        return true
      end

      simbolo = (cursor >= 0 && cursor < fita.length) ? fita[cursor] : "_"
      simbolo = "_" if simbolo.nil?

      t = buscar_transicao(estado_m, simbolo)
      if t.nil?
        puts "Nenhuma transição encontrada para o estado '#{estado_m}' lendo '#{simbolo}'."
        puts "CADEIA REJEITADA!"
        return false
      end

      fita << "_" while cursor >= fita.length
      fita[cursor] = t[3]      # símbolo escrito
      estado_m     = t[2]      # estado destino

      if t[4] == "d"
        cursor += 1
      else
        cursor -= 1
        cursor = 0 if cursor < 0  # fita limitada à esquerda
      end

      passo += 1
      if passo > 100_000
        puts "LIMITE de passos atingido (possível laço infinito). CADEIA REJEITADA!"
        return false
      end
    end
  end

  # -------------------------------------------------------------------------
  #  Auxiliares
  # -------------------------------------------------------------------------
  def mostrar_transicoes
    @transicoes.each do |o, l, d, e, m|
      puts "(#{o}, #{l}) -> (#{d}, #{e}, #{m})"
    end
  end

  def mostrar_fita_mtu
    puts "Fita da MTU (C(M)#w): #{@fita}"
    puts "Cadeia w decodificada: #{@w.join(' ')}"
  end

  private

  def aceitacao?(estado_m)
    estado_m.start_with?("fb")
  end

  # Varredura linear da LISTA de transições (não é hash).
  def buscar_transicao(estado_m, simbolo)
    @transicoes.each do |t|
      return t if t[0] == estado_m && t[1] == simbolo
    end
    nil
  end

  def registrar(origem, lido, destino, escrito, mov)
    @transicoes << [origem, lido, destino, escrito, mov]
    if @verbose
      puts "  [MTU] -> transição decodificada: (#{origem},#{lido}) -> (#{destino},#{escrito},#{mov})"
    end
  end

  # Operação elementar da MTU: escreve nada, troca de estado e move à direita.
  def mover(novo_estado)
    @cursor += 1
    @estado = novo_estado
  end

  def mostrar_configuracao(estado_m, fita, cursor)
    fita_texto = fita.empty? ? "_" : fita.join(" ")
    puts "Estado Atual : #{estado_m}"
    puts "Fita         : #{fita_texto}"

    ponteiro = "               "
    cursor.times do |i|
      tam = fita[i] ? fita[i].length : 1
      ponteiro += " " * (tam + 1)
    end
    puts ponteiro + "^"
  end
end
