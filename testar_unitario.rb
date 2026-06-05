require_relative 'mtu'

# Captura o primeiro argumento passado no terminal (ex: entradas/sensivel.txt)
# Se não houver argumento, usa o arquivo de teste padrão.
caminho_arquivo = ARGV[0] || File.join(__dir__, 'entradas', 'teste1.txt')

if caminho_arquivo.empty?
  puts "=================================================================="
  puts "ERRO: Você precisa passar o caminho do arquivo de teste!"
  puts "Exemplo de uso:"
  puts "  ruby testar_unitario.rb entradas/livre_contexto.txt"
  puts "=================================================================="
  exit
end

puts "=================================================="
puts "         EXECUTANDO TESTE INDIVIDUAL DA MTU       "
puts "=================================================="
puts "Arquivo selecionado: #{caminho_arquivo}"
puts "--------------------------------------------------"

# Instancia e roda a máquina isoladamente
mtu = MTU.new
mtu.carregar_cenario(caminho_arquivo)

puts "--- Transições Carregadas do Arquivo ---"
mtu.mostrar_transicoes
puts "=================================================="
puts "Iniciando a execução passo a passo..."
puts "--------------------------------------------------"

resultado = mtu.executar

puts "--------------------------------------------------"
if resultado
  puts "FIM DA SIMULAÇÃO: Cadeia foi ACEITA com sucesso! 🎉"
else
  puts "FIM DA SIMULAÇÃO: Cadeia foi REJEITADA! ❌"
end
puts "=================================================="