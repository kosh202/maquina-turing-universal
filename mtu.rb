class Transicao
  attr_accessor :origem, :lido, :destino, :escrito, :movimento

  def initialize(origem, lido, destino, escrito, movimento)
    @origem = origem
    @lido = lido
    @destino = destino
    @escrito = escrito
    @movimento = movimento
  end
end

class MTU
  def initialize
    @estado = "fa"
    @posicao = 0
    @fita = []
    @transicoes = []
  end

  def estado_aceitacao?
    @estado.start_with?("fb")
  end

  def executar
    loop do
      mostrar_configuracao
      puts "----------------"

      if estado_aceitacao?
        puts "CADEIA ACEITA!"
        return true
      end

      unless executar_passo
        puts "CADEIA REJEITADA!"
        return false
      end
    end
  end

  def simbolo_atual
    # Se o cursor passar do tamanho atual da fita, simula o símbolo branco
    if @posicao >= @fita.length || @fita[@posicao].nil?
      "_"
    else
      @fita[@posicao]
    end
  end

  def buscar_transicao
    @transicoes.each do |t|
      if t.origem == @estado && t.lido == simbolo_atual
        return t
      end
    end
    nil
  end

  def executar_passo
    transicao = buscar_transicao
    if transicao.nil?
      puts "Nenhuma transição encontrada para o estado '#{@estado}' lendo '#{simbolo_atual}'."
      return false
    end

    # Garante que a fita expanda dinamicamente se o ponteiro estiver além do tamanho atual
    while @posicao >= @fita.length
      @fita << "_"
    end

    # Escreve na fita e atualiza o estado
    @fita[@posicao] = transicao.escrito
    @estado = transicao.destino

    # Movimenta o cursor com trava de segurança à esquerda
    if transicao.movimento == "d"
      @posicao += 1
    elsif transicao.movimento == "e"
      @posicao -= 1
      @posicao = 0 if @posicao < 0 # Fita limitada à esquerda
    end

    true
  end

  def carregar_cenario(caminho_arquivo)
    unless File.exist?(caminho_arquivo)
      puts "Erro: Arquivo #{caminho_arquivo} não encontrado."
      exit
    end

    conteudo_completo = File.read(caminho_arquivo).strip
    
    # Divide a máquina da cadeia de entrada pelo caractere '#'
    codigo_maquina, cadeia_entrada = conteudo_completo.split('#')

    if codigo_maquina.nil? || cadeia_entrada.nil?
      puts "Erro: Arquivo de cenário inválido. Use o formato 'regras#entrada'"
      exit
    end

    # Processa cada linha da máquina de Turing descrita
    codigo_maquina.each_line do |linha|
      linha = linha.strip
      next if linha.empty? # Pula linhas vazias

      # Divide a linha por espaços em branco
      partes = linha.split(/\s+/)
      
      # Uma transição válida DEVE ter exatamente 5 partes: 
      # [origem, lido, destino, escrito, movimento]
      if partes.length == 5
        origem    = partes[0]
        lido      = partes[1]
        destino   = partes[2]
        escrito   = partes[3]
        movimento = partes[4]

        @transicoes << Transicao.new(origem, lido, destino, escrito, movimento)
      end
    end

    # Carrega a fita de entrada interpretando os símbolos sc, scc... e brancos (_)
    @fita = cadeia_entrada.scan(/sc+|_/)
  end

  def mostrar_transicoes
    @transicoes.each do |t|
      puts "(#{t.origem}, #{t.lido}) -> (#{t.destino}, #{t.escrito}, #{t.movimento})"
    end
  end

  def mostrar_configuracao
    fita_texto = @fita.empty? ? "_" : @fita.join(" ")
    puts "Estado Atual : #{@estado}"
    puts "Fita         : #{fita_texto}"
    
    # Monta a seta indicativa na posição correta da fita na tela
    ponteiro = "               " # Alinhado com o texto "Fita         : "
    @posicao.times do |i|
      # Adiciona o espaçamento proporcional ao tamanho do elemento da fita + espaço em branco
      tamanho_elemento = @fita[i] ? @fita[i].length : 1
      ponteiro += " " * (tamanho_elemento + 1)
    end
    puts ponteiro + "^"
  end
end

# --- Execução do Programa ---

# mtu = MTU.new

# # Substitua pelo caminho do cenário que você quer testar
# # Ex: "testes/regular.txt", "testes/livre_contexto.txt", etc.
# arquivo_teste = "entradas/regular.txt" 

# puts "Carregando cenário: #{arquivo_teste}..."
# mtu.carregar_cenario(arquivo_teste)

# puts "\n--- Tabela de Transições Carregada ---"
# mtu.mostrar_transicoes
# puts "=======================================\n\n"

# puts "Iniciando Simulação:"
# mtu.executar