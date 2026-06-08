# encoding: utf-8
require_relative 'mtu'

# Captura o primeiro argumento (ex: entradas/sensivel.txt).
# Sem argumento, usa um arquivo padrão.
caminho_arquivo = ARGV[0] || File.join(__dir__, 'entradas', 'regular.txt')

puts "=================================================="
puts "         EXECUTANDO TESTE INDIVIDUAL DA MTU       "
puts "=================================================="
puts "Arquivo selecionado: #{caminho_arquivo}"
puts "--------------------------------------------------"

mtu = MTU.new
mtu.verbose = true  # mostra a MTU lendo a fita C(M)#w caractere a caractere

puts "--- A MTU lê a fita como uma Máquina de Turing e decodifica ---"
mtu.carregar_cenario(caminho_arquivo)

puts
mtu.mostrar_fita_mtu
puts
puts "--- Transições de M decodificadas a partir da fita ---"
mtu.mostrar_transicoes
puts "=================================================="
puts "Iniciando a simulação de M sobre w (passo a passo)..."
puts "--------------------------------------------------"

resultado = mtu.executar

puts "--------------------------------------------------"
if resultado
  puts "FIM DA SIMULAÇÃO: Cadeia foi ACEITA com sucesso! 🎉"
else
  puts "FIM DA SIMULAÇÃO: Cadeia foi REJEITADA! ❌"
end
puts "=================================================="
