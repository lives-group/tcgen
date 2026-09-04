# Título

Geração Automática de Casos de Teste para Juízes Online por Análise de Fluxo de
Controle.

# Resumo

Juízes online são sistemas de avaliação automática de exercícios de programação
amplamente utilizados no ensino de computação. A qualidade dos casos de teste
empregados por esses sistemas é decisiva para a equidade das avaliações: casos
insuficientes permitem que soluções incorretas sejam aceitas, enquanto casos mal
distribuídos concentram cobertura em caminhos triviais e ignoram fronteiras de
comportamento relevantes. A criação manual de casos de teste é trabalhosa e
propensa a omissões sistemáticas, demandando abordagens automatizadas que
garantam cobertura estrutural do programa avaliado.

Este projeto propõe a concepção, formalização e implementação de TCGen, uma
ferramenta completamente implementada em Haskell para geração automática de
casos de teste para juízes online. A ferramenta recebe como entrada um
programa-gabarito escrito em uma linguagem imperativa com todas as construções
usualmente encontradas em cursos introdutórios de programação de computadores, e
produz automaticamente casos de teste cujos valores de entrada cobrem os
caminhos linearmente independentes do programa, conforme o critério de
complexidade ciclomática de McCabe. O fundamento técnico central é a análise do
grafo de fluxo de controle (CFG) do gabarito, da qual são extraídas restrições
sobre as variáveis de entrada; essas restrições são traduzidas em geradores da
biblioteca QuickCheck, construídos e executados como valores de primeira classe
dentro do próprio processo da ferramenta, sem nenhuma etapa de geração e
recompilação de código externo.

# Palavras-chave

geração de casos de teste, análise de fluxo de controle, QuickCheck, Haskell,
juízes online, complexidade ciclomática

# Introdução

A avaliação automática de exercícios de programação, realizada por sistemas
denominados juízes online, é uma prática consolidada no ensino de computação
[Bez et al., 2014; Oliveira et al., 2021; Mirzayanov et al., 2020]. O mecanismo
central desses sistemas é a análise dinâmica [Ball, 1999]: o programa submetido
pelo aluno é executado sobre um conjunto de entradas predefinidas e sua saída é
comparada com a saída esperada. A qualidade desse conjunto de entradas — os
casos de teste — é determinante para a utilidade pedagógica da avaliação. Casos
de teste bem construídos discriminam soluções corretas de incorretas, cobrindo
os diferentes comportamentos do programa; casos mal construídos podem aprovar
soluções incorretas ou reprovar soluções corretas por incidentalidades de
formato.

A construção manual de casos de teste é uma tarefa que exige do professor tanto
o conhecimento do domínio do exercício quanto a compreensão dos caminhos de
execução possíveis do programa. Esse processo é trabalhoso e propenso a
omissões: é comum que fronteiras de comportamento importantes — como o caso em
que dois valores são iguais, ou o laço que não executa nenhuma iteração — sejam
esquecidas. A geração automática de casos de teste a partir da estrutura do
programa é, portanto, uma necessidade premente para o contexto de juízes online
pedagógicos.

O grafo de fluxo de controle (CFG) de um programa é uma representação formal de
sua estrutura de execução: os vértices são blocos básicos de instruções
sequenciais e as arestas representam possíveis transferências de controle,
anotadas com as condições de guarda que as habilitam. A partir do CFG, McCabe
[1976] definiu a complexidade ciclomática como uma medida do número de caminhos
linearmente independentes, fornecendo um critério preciso para determinar o
conjunto mínimo de casos de teste que garante cobertura estrutural completa do
programa. A abordagem de cobertura de base de McCabe é o fundamento teórico da
geração de casos de teste proposta neste projeto.

A tradução das restrições extraídas dos caminhos do CFG em geradores de dados de
teste é realizada usando a biblioteca QuickCheck [Claessen e Hughes, 2000], uma
ferramenta consolidada para testes baseados em propriedades em Haskell. Em
QuickCheck, um gerador é um valor de primeira classe do tipo `Gen a`, que pode
ser construído programaticamente usando combinadores como `choose` (para
intervalos numéricos), `elements` (para escolha de conjunto finito), `vectorOf`
(para listas de tamanho fixo) e `suchThat` (para filtragem por predicado). Essa
característica permite que as restrições extraídas do CFG sejam traduzidas
diretamente em geradores, construídos e executados dentro do próprio processo da
ferramenta, sem nenhuma etapa de geração de código-fonte ou recompilação.

A escolha de Haskell como linguagem única de implementação é motivada por três
propriedades do ecossistema que se alinham diretamente com os requisitos do
problema. Primeiro, os tipos algébricos de dados (ADTs) representam naturalmente
a AST e o CFG: cada construção da linguagem de entrada corresponde a um
construtor de tipo, e o compilador Haskell garante que o tratamento de todas as
formas seja exaustivo. Segundo, as mônadas de estado (`State`), leitura
(`Reader`) e escrita (`Writer`) disciplinam as transformações entre as fases de
análise, tornando explícito o fluxo de informação sem recorrer a efeitos
colaterais globais. Terceiro, a biblioteca QuickCheck, disponível como
dependência Haskell ordinária, permite que os geradores sintetizados sejam
valores manipulados em tempo de execução — não código gerado e compilado —
eliminando a complexidade de um segundo compilador no pipeline [Hughes, 1989;
Wadler, 1995].

A linguagem de entrada da ferramenta — denominada StructLang — cobre os recursos
tradicionais de programação estruturada: atribuição, leitura e impressão de
valores, comandos condicionais, comandos de repetição (`while`, `do-while`,
`for`), desvios múltiplos (`switch`), funções e arranjos. O parser de StructLang
é implementado com a biblioteca Megaparsec [Leijen e Meijer, 2001], um framework
de combinadores de parser monádicos que oferece mensagens de erro precisas e
suporte nativo a espaços e comentários. A interface de uso da ferramenta é por
linha de comando, implementada com a biblioteca optparse-applicative, e recebe o
arquivo do programa-gabarito e o número máximo de casos a gerar. A saída é
emitida no console ou em um arquivo JSON via a biblioteca Aeson.

A geração automática de casos de teste a partir da análise de fluxo de controle
é um problema amplamente estudado na literatura de engenharia de software [Anand
et al., 2013]. O presente projeto se distingue pelo foco no contexto de juízes
online pedagógicos — onde o programa-gabarito é conhecido e a cobertura
estrutural desse gabarito é o critério relevante — e pela implementação
completamente em Haskell, que permite a construção de geradores QuickCheck como
valores de primeira classe, evitando a complexidade de pipelines que envolvem
múltiplas linguagens ou etapas de compilação.

Diante desse cenário, o presente projeto representa uma contribuição de
relevância direta tanto para a prática docente quanto para a pesquisa em
engenharia de software educacional. Ao automatizar a geração de casos de teste
estruturalmente completos, a ferramenta reduz o esforço manual dos professores,
minimiza o risco de omissão de fronteiras de comportamento e eleva a qualidade
avaliativa dos juízes online, beneficiando diretamente os alunos com um feedback
mais justo e discriminativo. Do ponto de vista científico, o projeto produz
artefatos formalizados e verificáveis: um algoritmo de síntese de geradores a
partir de restrições de caminhos e a implementação de referência em Haskell, que
pode servir de base para trabalhos futuros envolvendo extensões da linguagem de
entrada, integração com resolvedores SMT ou adaptação a outros contextos de
teste baseado em cobertura. A disponibilização pública da ferramenta
potencializa ainda sua adoção por outras instituições que operam juízes online,
ampliando o impacto prático dos resultados além do contexto imediato do projeto.

# Objetivos

O objetivo geral deste projeto é conceber, formalizar e implementar TCGen, uma
ferramenta em Haskell para geração automática de casos de teste para juízes
online, fundamentada na análise do grafo de fluxo de controle do
programa-gabarito e na síntese de geradores QuickCheck a partir das restrições
extraídas dos caminhos linearmente independentes.

Os objetivos específicos são:

**1. Revisar e sistematizar o estado da arte em geração automática de casos de
teste por análise de fluxo de controle** Realizar levantamento bibliográfico
abrangente sobre métodos de geração de casos de teste baseados em cobertura
estrutural [Anand et al., 2013], com ênfase em abordagens que utilizam o
critério de cobertura de base de McCabe [McCabe, 1976], testes baseados em
propriedades [Claessen e Hughes, 2000] e análise estática de programas.
Identificar as limitações das abordagens existentes no contexto de juízes
online, onde o gabarito é disponível e a cobertura estrutural desse gabarito é o
critério de qualidade dos casos de teste.

**2. Definir formalmente a linguagem StructLang** Especificar a gramática
completa de StructLang como uma Parsing Expression Grammar (PEG), cobrindo os
tipos primitivos (inteiro, real, booleano, caractere e cadeia), a atribuição
simples e composta, os comandos de leitura e impressão, os condicionais, os
laços (`while`, `do-while`, `for`), os desvios múltiplos (`switch`), as funções
com parâmetros por valor e referência, e os arranjos uni e bidimensionais.
Garantir que a gramática seja não ambígua e analisável em tempo linear,
propriedades decorrentes do formalismo PEG [Ford, 2004].

**3. Implementar o frontend de StructLang em Haskell** Desenvolver o lexer e o
parser de StructLang usando a biblioteca Megaparsec [Leijen e Meijer, 2001],
produzindo uma AST representada como ADTs Haskell. Implementar a análise
semântica (verificação de tipos e coleta das variáveis de entrada) usando a
mônada `StateT
SymTable (Either String)`, que encapsula o estado da tabela de
símbolos e permite falha com mensagem de erro precisa.

**4. Implementar a construção e análise do CFG** Desenvolver o módulo de
construção do grafo de fluxo de controle a partir da AST de StructLang, usando a
mônada `State` sobre um mapa de blocos básicos. As arestas do CFG devem ser
anotadas com expressões de guarda que representam as condições de controle de
cada transferência. Implementar a enumeração dos caminhos de base de McCabe por
busca em profundidade com controle de back-edges e o cálculo da complexidade
ciclomática do programa.

**5. Implementar a síntese de geradores QuickCheck** Desenvolver o módulo de
tradução das restrições extraídas dos caminhos do CFG em geradores
`Gen TestCase` da biblioteca QuickCheck. Os geradores devem tratar separadamente
os tipos inteiro (com inferência de intervalos a partir de restrições lineares e
filtragem via `suchThat` para restrições não lineares), real, booleano,
caractere, cadeia (com suporte a alternativas derivadas de `switch`) e arranjo
(com tamanho inferido da declaração ou do laço de leitura). Dependências entre
variáveis de entrada devem ser modeladas via encadeamento monádico
(`do`-notation de `Gen`), respeitando a ordem topológica das dependências.

**6. Implementar a interface de linha de comando e os formatos de saída**
Desenvolver a CLI com a biblioteca optparse-applicative, recebendo o
arquivo-gabarito, o número máximo de casos, opções de critério de cobertura
(`base`, `full`, `boundary`), semente aleatória para reprodutibilidade e modo de
saída. Implementar a saída em formato texto no console (um valor por linha, na
ordem de leitura do programa) e em formato JSON via Aeson. Adicionar casos de
fronteira derivados diretamente das restrições, sempre incluídos
independentemente do número solicitado.

**7. Validar a ferramenta experimentalmente** Aplicar o TCGen a um conjunto de
exercícios reais de disciplinas introdutórias de programação, verificando que:
os casos gerados cobrem os caminhos de base do CFG; casos de fronteira
relevantes são incluídos; e o número de casos gerados é suficiente para
discriminar soluções corretas de incorretas comuns (como o uso de operador
errado em expressões aritméticas ou condições invertidas em condicionais).

**8. Produzir e disseminar resultados científicos** Documentar os resultados em
relatório técnico, submeter artigo científico a evento ou periódico da área
(e.g., SBIE, WEI, SIGCSE, ICST), e disponibilizar publicamente a especificação
formal e a implementação de referência em repositório aberto.

# Justificativa/Relevância

A criação de casos de teste de qualidade é um dos gargalos práticos na operação
de juízes online com foco pedagógico. Professores que preparam exercícios
frequentemente definem apenas os casos de teste mais óbvios — entradas
positivas, casos simétricos, valores neutros — deixando de cobrir fronteiras de
comportamento que são precisamente os casos que distinguem uma solução correta
de uma solução parcialmente correta. O impacto direto é a aprovação indevida de
soluções com erros lógicos sutis, reduzindo a utilidade avaliativa e pedagógica
do juiz online.

A abordagem proposta ataca esse problema sistematicamente: ao analisar o CFG do
programa-gabarito, a ferramenta identifica automaticamente quais combinações de
valores de entrada levam cada ramo condicional e cada iteração de laço a ser
exercitados, garantindo que nenhum caminho estruturalmente distinto seja
omitido. O critério de cobertura de base de McCabe [1976] é consolidado na
literatura de engenharia de software como o número mínimo de casos necessários
para garantir que toda aresta do CFG seja percorrida ao menos uma vez,
fornecendo uma base formal para a afirmação de completude da cobertura.

A implementação em Haskell oferece vantagens concretas sobre abordagens que usam
múltiplas linguagens. O sistema de tipos garante que todas as formas da AST e do
CFG sejam tratadas exaustivamente em tempo de compilação, eliminando uma classe
inteira de erros de runtime que seriam difíceis de depurar em implementações
menos tipadas. A biblioteca QuickCheck, disponível nativamente, permite que os
geradores sintetizados sejam valores de primeira classe manipulados em memória —
e não código gerado e compilado — tornando o pipeline da ferramenta mais
simples, auditável e extensível [Claessen e Hughes, 2000; Hughes, 1989]. Em
particular, a composição monádica do `do`-notation de `Gen` modela naturalmente
a geração sequencial de variáveis de entrada com dependências entre si, um
requisito frequente em exercícios onde uma variável restringe o domínio de outra
(e.g., `y > x`).

Do ponto de vista pedagógico, a integração do TCGen com sistemas de juízes
online representa um avanço na qualidade da avaliação automática de programas no
ensino de computação [Messer et al., 2024; Kurniawan et al., 2023], contribuindo
para um feedback mais justo e pedagogicamente útil para os alunos. Do ponto de
vista científico, o trabalho contribui com: a especificação formal de StructLang
como PEG; o algoritmo de síntese de geradores QuickCheck a partir de restrições
de caminhos de CFG; e evidências empíricas sobre a eficácia da abordagem na
cobertura de comportamentos relevantes de exercícios de programação
introdutória.

# Atividades/Metodologias

A pesquisa será conduzida em etapas progressivas, combinando revisão
bibliográfica, desenvolvimento teórico-formal e implementação experimental em
Haskell.

**Etapa 1: Revisão bibliográfica e nivelamento teórico (meses 1–3)**

Estudo dos fundamentos necessários ao projeto:

- Geração automática de casos de teste: métodos baseados em cobertura
  estrutural, execução simbólica e testes baseados em propriedades [Anand et
  al., 2013];
- Complexidade ciclomática e cobertura de base de McCabe: definições,
  propriedades e uso como critério de adequação de casos de teste [McCabe,
  1976];
- Testes baseados em propriedades com QuickCheck: a API `Gen`, os combinadores
  `choose`, `elements`, `vectorOf`, `suchThat`, `oneof`, `frequency`, e a
  semântica monádica de geradores [Claessen e Hughes, 2000];
- Mônadas e programação funcional em Haskell: `State`, `Reader`, `Writer`,
  `Either` e transformadores de mônadas [Wadler, 1995];
- Combinadores de parser Megaparsec: `MonadParsec`, `makeExprParser`,
  `L.lexeme`, `L.symbol`, e o módulo `Text.Megaparsec.Char.Lexer` [Leijen e
  Meijer, 2001];
- Juízes online e avaliação automática: CodeBench [Oliveira et al., 2021], URI
  Online Judge [Bez et al., 2014], Codeforces [Mirzayanov et al., 2020] e a
  abordagem de correção semântica do trabalho de referência [opCoders, 2026].

Serão lidos e fichados todos os trabalhos de referência. Um protótipo mínimo do
parser de StructLang para expressões aritméticas será desenvolvido ao final
desta etapa como exercício de aprendizado do Megaparsec.

**Etapa 2: Definição formal de StructLang e implementação do frontend (meses
2–5)**

Com base nos fundamentos estudados na Etapa 1:

- Especificação da gramática completa de StructLang como PEG, cobrindo todos os
  construtores da linguagem: tipos primitivos e compostos, atribuição simples e
  composta, leitura e impressão, condicionais, laços, `switch`, funções e
  arranjos;
- Verificação das propriedades da gramática: ausência de recursão à esquerda,
  determinismo do operador de escolha, linearidade do tempo de reconhecimento;
- Definição dos ADTs Haskell para a AST de StructLang, com campos de posição
  para mensagens de erro precisas;
- Implementação do lexer e parser usando Megaparsec, com separação entre o
  módulo de lexemas (`TCGen.Lexer`) e o módulo de regras gramaticais
  (`TCGen.Parser`);
- Implementação da análise semântica: verificação de tipos via `inferType` e
  coleta das variáveis de entrada (alvos de `read` antes de qualquer definição)
  via `collectInputs`, usando `StateT SymTable (Either String)`;
- Desenvolvimento de uma suíte de testes unitários do parser (HSpec) cobrindo
  todos os construtores e casos de erro esperados.

**Etapa 3: Construção e análise do CFG (meses 4–7)**

Com base na AST produzida na Etapa 2:

- Definição dos tipos `BasicBlock`, `Guard`, `CFG` e `CFGState` em Haskell;
- Implementação da função `buildCFG :: Block -> CFG`, usando `State CFGState`
  para gerenciar o contador de nós e o mapa de blocos, e traduzindo cada
  construção de StructLang no padrão de nós e arestas correspondente:
  `if`/`else` com guardas acumuladas; `while` com header, back-edge e aresta de
  saída; `for` desdobrado em `while`; `switch` com guardas de igualdade e
  exclusão;
- Implementação da função `enumeratePaths :: CFG -> Int -> [Path]`, usando busca
  em profundidade com limite de iterações em back-edges para controle da
  explosão de caminhos em laços;
- Implementação de `cyclomaticComplexity :: CFG -> Int` e de
  `extractConstraints :: [InputVar] -> [Path] -> PathConstraints`;
- Testes unitários do CFG com exemplos de programas StructLang conhecidos
  (triângulo, fatorial, busca linear), verificando a contagem correta de
  caminhos e a extração das guardas esperadas.

**Etapa 4: Síntese dos geradores QuickCheck (meses 5–8)**

Com base nas restrições extraídas na Etapa 3:

- Implementação de `synthesizeInt`, `synthesizeReal`, `synthesizeBool`,
  `synthesizeChar`, `synthesizeString` e `synthesizeArray`, cada um recebendo a
  lista de guardas do caminho e retornando um `Gen GenValue`;
- Implementação de `extractIntBounds`: análise das guardas para inferência de
  intervalo `[lo, hi]` a partir de restrições lineares do tipo `x > k`,
  `x <= k`, com tratamento separado de restrições residuais não lineares via
  `suchThat`;
- Implementação de `topoSortInputs`: ordenação topológica das variáveis de
  entrada pelo grafo de dependências entre restrições, para encadeamento correto
  via `do`-notation de `Gen`;
- Implementação de
  `synthesizePathGen :: SynthConfig -> [InputVar] -> [VarConstraint] -> Gen TestCase`
  e de `synthesizeFinalGen`, que combina os geradores de todos os caminhos via
  `frequency`, ponderado pelo tamanho dos intervalos;
- Implementação de `boundaryTestCases`, produzindo casos fixos nos valores de
  fronteira identificados nas restrições (e.g., para `x > k`: os valores `k`,
  `k+1` e `k-1`);
- Testes de integração verificando que os casos gerados para o programa do
  triângulo cobrem os cinco tipos de classificação esperados.

**Etapa 5: Interface de linha de comando e formatos de saída (meses 7–9)**

- Implementação da CLI com optparse-applicative: parsing dos argumentos
  `<gabarito>`, `<n>`, `--json`, `--seed`, `--coverage` e `--quiet`;
- Implementação de `emitConsole`: formatação de cada caso de teste como uma
  sequência de linhas, uma por variável de entrada, na ordem de leitura do
  programa;
- Implementação de `emitJson`: serialização dos casos via Aeson, produzindo um
  array JSON de objetos com o nome de cada variável como chave;
- Implementação de `printDiagnostics`: emissão no stderr das variáveis de
  entrada detectadas, complexidade ciclomática, número de caminhos identificados
  e número total de casos produzidos;
- Testes de integração end-to-end: execução da ferramenta sobre os programas de
  exemplo (`triangulo.sl`, `soma_array.sl`, `fatorial.sl`, `bubble_sort.sl`) e
  verificação manual dos casos gerados.

**Etapa 6: Validação experimental (meses 8–11)**

- Seleção de um conjunto de 10 a 20 exercícios reais de disciplinas
  introdutórias de programação, cobrindo diferentes conteúdos: variáveis e
  expressões, condicionais simples e aninhados, laços `while` e `for`, funções e
  vetores;
- Aplicação do TCGen a cada exercício, gerando casos de teste com os três
  critérios de cobertura (`base`, `full`, `boundary`);
- Avaliação da discriminação dos casos gerados: para cada exercício, coleta de
  soluções incorretas típicas de alunos (operador errado, condição invertida,
  off-by-one em laços) e verificação de que os casos gerados pelo TCGen rejeitam
  essas soluções;
- Comparação com os casos de teste definidos manualmente pelo professor: análise
  da sobreposição de cobertura e dos caminhos adicionais cobertos pelo TCGen;
- Análise da taxa de rejeição dos geradores `suchThat` para restrições não
  lineares, como indicador de onde a integração com solucionadores SMT seria
  mais impactante.

**Etapa 7: Escrita e disseminação de resultados (meses 10–12)**

- Elaboração de relatório técnico detalhado contendo a especificação formal de
  StructLang, os algoritmos de construção do CFG e síntese de geradores, e a
  documentação da implementação Haskell;
- Escrita e submissão de artigo científico descrevendo a ferramenta, sua
  fundamentação teórica e os resultados experimentais, direcionado a evento ou
  periódico da área (e.g., SBIE, WEI, SIGCSE, ICST);
- Disponibilização pública da implementação de referência e do conjunto de
  exercícios usados na validação em repositório aberto (GitHub e Zenodo);
- Apresentação dos resultados em seminários e eventos acadêmicos nacionais.

# Referências Bibliográficas

[1] CLAESSEN, K.; HUGHES, J. QuickCheck: A Lightweight Tool for Random Testing
of Haskell Programs. In: _5th ACM SIGPLAN International Conference on Functional
Programming (ICFP '00)_. ACM, 2000. p. 268–279.
https://doi.org/10.1145/351240.351266

[2] McCABE, T. J. A Complexity Measure. _IEEE Transactions on Software
Engineering_, v. SE-2, n. 4, p. 308–320, 1976.
https://doi.org/10.1109/TSE.1976.233837

[3] ANAND, S.; BURKE, E. K.; CHEN, T. Y.; CLARK, J.; COHEN, M. B.; GRIESKAMP,
W.; HARMAN, M.; HARROLD, M. J.; McMINN, P. An Orchestrated Survey of
Methodologies for Automated Software Test Case Generation. _Journal of Systems
and Software_, v. 86, n. 8, p. 1978–2001, 2013.
https://doi.org/10.1016/j.jss.2013.02.061

[4] WADLER, P. Monads for Functional Programming. In: JEURING, J.; MEIJER, E.
(eds.). _Advanced Functional Programming_. Lecture Notes in Computer Science,
v. 925. Springer, 1995. p. 24–52. https://doi.org/10.1007/3-540-59451-5_2

[5] HUGHES, J. Why Functional Programming Matters. _The Computer Journal_, v.
32, n. 2, p. 98–107, 1989. https://doi.org/10.1093/comjnl/32.2.98

[6] LEIJEN, D.; MEIJER, E. Parsec: Direct Style Monadic Parser Combinators for
the Real World. Technical Report UU-CS-2001-27, Department of Information and
Computing Sciences, Utrecht University, 2001.
https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/parsec-paper-letter.pdf

[7] FORD, B. Parsing Expression Grammars: A Recognition-Based Syntactic
Foundation. In: _31st ACM SIGPLAN-SIGACT Symposium on Principles of Programming
Languages (POPL '04)_. ACM, 2004. p. 111–122.
https://doi.org/10.1145/964001.964011

[8] BALL, T. The Concept of Dynamic Analysis. In: NIERSTRASZ, O.; LEMOINE, M.
(eds.). _Software Engineering — ESEC/FSE '99_. Lecture Notes in Computer
Science, v. 1687. Springer, 1999. p. 216–234.
https://doi.org/10.1007/3-540-48166-4_14

[9] MESSER, M.; BROWN, N. C. C.; KÖLLING, M.; SHI, M. Automated Grading and
Feedback Tools for Programming Education: A Systematic Review. _ACM Transactions
on Computing Education_, v. 24, n. 1, p. 1–43, 2024.
https://doi.org/10.1145/3636515

[10] KURNIAWAN, O.; POSKITT, C. M.; AL HOQUE, I.; LEE, N. T. S.; JÉGOUREL, C.;
SOCKALINGAM, N. How Helpful Do Novice Programmers Find the Feedback of an
Automated Repair Tool? In: _2023 IEEE International Conference on Teaching,
Assessment and Learning for Engineering (TALE)_. IEEE, 2023. p. 1–6.
https://doi.org/10.1109/TALE56641.2023.10398393

[11] BEZ, J. L.; TONIN, N. A.; RODEGHERI, P. R. URI Online Judge Academic: A
Tool for Algorithms and Programming Classes. In: _9th International Conference
on Computer Science & Education (ICCSE 2014)_. IEEE, 2014. p. 149–152.
https://doi.org/10.1109/ICCSE.2014.6926445

[12] MIRZAYANOV, M.; PAVLOVA, O.; MAVRIN, P.; MELNIKOV, R.; PLOTNIKOV, A.;
PARFENOV, V.; STANKEVICH, A. Codeforces as an Educational Platform for Learning
Programming in Digitalization. _Olympiads in Informatics_, v. 14, p. 133–142,
2020. https://doi.org/10.15388/ioi.2020.10

[13] CODEBENCH. CodeBench: Plataforma de Apoio ao Ensino de Programação
Estruturada. Instituto de Computação, Universidade Federal do Amazonas (UFAM),
2024. Disponível em: https://codebench.icomp.ufam.edu.br. Acesso em: jun. 2026.

[14] MEGAPARSEC. Industrial-strength monadic parser combinator library for
Haskell. Hackage, versão 9.7.1, 2024.
https://hackage.haskell.org/package/megaparsec

[15] OPTPARSE-APPLICATIVE. Utilities and combinators for parsing command line
options in Haskell. Hackage, versão 0.18.1, 2024.
https://hackage.haskell.org/package/optparse-applicative

[16] opCoders. Incorporando Tolerância Numérica e Padrões Textuais Dinâmicos na
Correção Automática de Exercícios de Programação. In: _Simpósio Brasileiro de
Informática na Educação (SBIE 2026)_. SBC, 2026. [submetido para revisão]
