require_relative 'mtu'

# Lista com os arquivos de teste e o resultado que ESPERAMOS que eles deem
cenarios_testes = [
  { arquivo: "entradas/regular.txt", descricao: "Linguagem Regular (a*b*) - Cadeia: aabb", esperado: true },
  { arquivo: "entradas/livre_contexto.txt", descricao: "Linguagem Livre de Contexto (a^n b^n) - Cadeia: aabb", esperado: true },
  { arquivo: "entradas/sensivel.txt", descricao: "Linguagem Sensível ao Contexto (a^n b^n c^n) - Cadeia: aabbcc", esperado: true }
]

sucessos = 0
falhas = 0

puts "=================================================="
puts "         EXECUTANDO SUÍTE DE TESTES DA MTU        "
puts "=================================================="

cenarios_testes.each_with_index do |cenario, indice|
  puts "\n[Teste #{indice + 1}] #{cenario[:descricao]}"
  puts "Arquivo: #{cenario[:arquivo]}"
  puts "--------------------------------------------------"

  # Instancia uma nova MTU para cada teste para não misturar os estados
  mtu = MTU.new
  mtu.carregar_cenario(cenario[:arquivo])
  
  # Executa a máquina. O método 'executar' retorna true (aceita) ou false (rejeitada)
  resultado_obtido = mtu.executar
  
  puts "--------------------------------------------------"
  if resultado_obtido == cenario[:esperado]
    puts "=> STATUS: PASSOU (Resultado esperado obtido)"
    sucessos += 1
  else
    puts "=> STATUS: FALHOU (Esperava #{cenario[:esperado]} mas obteve #{resultado_obtido})"
    falhas += 1
  end
  puts "=================================================="
end

# Relatório Final
puts "\n### RESUMO DOS TESTES ###"
puts "Total de testes rodados: #{cenarios_testes.length}"
puts "Passaram: #{sucessos}"
puts "Falharam: #{falhas}"
puts "=================================================="

if falhas == 0
  puts "Parabéns! Todos os cenários obrigatórios foram validados com sucesso! 🚀"
else
  puts "Atenção: Verifique os cenários que falharam."
end