# prototypen

**Prototipagem autônoma de produto no canvas do [Pencil (pen.dev)](https://pen.dev).**
Entra uma ideia com requisitos; sai um protótipo navegável, um sistema de design
completo e os documentos que fazem o handoff para a implementação.

Um plugin para o [Claude Code](https://claude.com/claude-code).

---

## O problema

Design gerado por IA tem uma cara reconhecível: Inter, azul `#3b82f6`, card
branco com sombra suave, hero centralizado com dois CTAs, gradiente roxo, ícone
em círculo pastel.

Não é que os modelos sejam ruins de design — é que isso é o centro estatístico de
tudo que eles viram. E pedir criatividade não move: "seja ousado" devolve o mesmo
resultado com outros adjetivos.

## A abordagem

O `prototypen` ataca por dois lados:

**Restrição declarada antes da geração.** Três fases produzem zero pixels e são
onde está quase todo o valor: pesquisa mapeia o que a categoria já ocupa, a marca
toma posição contra isso, e a direção de design escolhe entre três alternativas
reais e escreve a especificação. Quando o primeiro elemento é desenhado, o espaço
de designs aceitáveis já é pequeno o bastante para o default genérico estar fora
dele.

**Auditoria em contexto separado.** Quem julga não é quem desenhou. Um agente
revisando o próprio trabalho no mesmo contexto já se convenceu de cada decisão
uma vez — ele não re-deriva o julgamento, ele recupera a justificativa. Um
contexto novo tem só o artefato, a rubrica e os arquivos de restrição.

Isso também é o que torna a auditoria possível: *"esse design está bom?"* não tem
resposta verificável, mas *"isso bate com a frase de personalidade escrita na
direção, e a escolha comprometida está visível?"* tem.

---

## Como funciona

```
/prototypen:discover     opcional, interativo, coleta os requisitos
        ↓
/prototypen:prototype    dez fases, sem supervisão, commit a cada fase
```

| Fase | Saída | Quem faz |
|---|---|---|
| Intake | personas, jobs, inventário de telas e estados | a skill |
| Pesquisa | concorrentes, convenções, antipadrões, território de marca ocupado | `researcher` |
| Marca *(condicional)* | nome, posicionamento, tom, paleta, logo em SVG | `brand-designer` |
| Direção | 3 direções em eixos opostos, a escolha e o porquê | a skill |
| Estrutura do canvas | a grade de caixas nomeadas, vazia, antes de qualquer elemento | `designer` |
| Sistema | tokens como variáveis do `.pen`, componentes base | `designer` |
| Telas | um subagente por fluxo, em paralelo | `designer` |
| Revisão de layout | alinhamento, distribuição e uso do espaço, por geometria | `layout-reviewer` |
| Auditoria | veredito binário por critério, em loop de correção | `auditor` |
| Organização | varredura final do canvas, obrigatória | `auditor` |
| Handoff | o mapa de tokens e componentes para o código | a skill |

A rodada inteira roda sem supervisão. Não existem gates de aprovação — as fases
de auditoria são o controle de qualidade, não a sua atenção.

## O que você recebe

```
design/
├── product-spec.md      personas, jobs, alvos, inventário de telas e estados
├── research.md          concorrentes, convenções, antipadrões, fontes
├── brand.md             nome, posicionamento, tom, paleta, regras do logo
├── brand/logo/*.svg     cinco variações
├── design-direction.md  três direções, a escolha e por que as outras caíram
├── design-spec.md       o handoff: tokens → código, componentes, regras
└── audits/<data>.md     cada critério, PASS ou FAIL
```

Mais o arquivo `.pen`, organizado em uma região de sistema de design, uma de
marca e uma por fluxo, com as telas em ordem de navegação.

---

## Decisões de projeto

Algumas escolhas que explicam por que o plugin tem o formato que tem.

**A ban list é explícita.** Inter, `#3b82f6`, o gradiente roxo-azul, o card com
sombra difusa, o hero centralizado, o ícone em círculo pastel — cada item é
proibido a menos que a direção de design justifique pelo nome, por escrito, antes
da geração. Uma justificativa escrita durante a auditoria para desculpar algo já
desenhado não conta.

**Ela restringe o visual, nunca a interação.** Usuários aprenderam onde fica o
filtro, o que é um botão de salvar, que ação destrutiva confirma antes. Isso é
pesquisa que todo mundo já pagou. Quebrar produz um protótipo original e
inusável. Originalidade vai em *como parece*; convenção fica em *onde as coisas
estão e como se comportam*.

**O `designer` não pode escrever arquivos.** Um agente que esbarra num token
faltando e *pode* editar a direção adiciona o token e segue — a rodada passa e a
restrição deixou de existir em silêncio. Sem permissão de escrita, ele só tem uma
saída: parar e reportar. Esse relatório é a única forma do arquivo de direção ser
corrigido em vez de violado.

**O `auditor` não conserta nada.** Um agente que pode consertar o que encontra
tende a encontrar o que é fácil consertar.

**Viewport duplica telas; tema não.** Desktop e mobile são designs diferentes, não
o mesmo design em duas larguras. Já tema vai por variável temática do pen.dev — a
mesma tela renderiza em ambos, *desde que nenhuma cor seja literal*. Um hex
cravado é o defeito que quebra um tema inteiro em silêncio.

**Perguntar tem hora.** O `discover` pergunta porque nada foi gerado ainda: uma
pergunta custa uma troca e pode redirecionar a rodada toda. O pipeline não
pergunta porque geração está em curso e uma pergunta custa a autonomia da rodada.
O que o `discover` nunca pergunta é como você quer que fique — essa pergunta
devolve "clean, modern, professional" de quase todo mundo, que é a descrição
literal do default que o plugin existe para escapar.

**Idioma.** O plugin é escrito em inglês; tudo que ele produz acompanha o seu
idioma — documentos, relatórios de auditoria e a copy dentro do protótipo. Nomes
de arquivo e de camadas do canvas continuam em inglês, para ficarem estáveis
entre rodadas.

---

## Começando

Pré-requisitos: pen.dev rodando, o servidor MCP `pencil` conectado, e o projeto
alvo sendo um repositório git. O canvas é sempre `design/prototype.pen` — se ele
não estiver aberto, o pipeline pede uma única vez, no início, que você crie e
abra o arquivo, e a partir daí roda até o fim sem parar.

```bash
claude plugin marketplace add ./prototypen-plugin
claude plugin install prototypen@prototypen
```

Ou, para desenvolver o próprio plugin sem instalar:

```bash
cd ~/projetos/meu-produto
claude --plugin-dir /caminho/para/prototypen-plugin
```

Depois é só descrever o que você quer construir — não precisa dizer "protótipo"
nem nomear a skill:

> Projete um app para uma transportadora pequena acompanhar fretes: uma lista dos
> fretes ativos com status, transportadora, custo e previsão, uma visão de
> detalhe por frete e um relatório semanal de custo. Três operadores usam o dia
> inteiro no desktop.

Se a ideia ainda está solta, rode `/prototypen:discover` antes — ele faz as
perguntas que valem a pena, em no máximo três rodadas, e escreve o
`product-spec.md` que o pipeline consome.

O passo a passo completo está em **[docs/usage.md](docs/usage.md)**, e a
instalação e o desenvolvimento do plugin em
**[docs/development.md](docs/development.md)**.

## Documentação

| | |
|---|---|
| [docs/usage.md](docs/usage.md) | como rodar, ler uma auditoria, retomar uma rodada interrompida |
| [docs/development.md](docs/development.md) | pré-requisitos, carregamento, validação, regras estruturais |
| [docs/architecture.md](docs/architecture.md) | as peças, o que cada uma decide, por que a auditoria é isolada |
| [docs/pipeline.md](docs/pipeline.md) | as dez fases em detalhe, artefatos, condicionais, pontos de commit |
| [docs/contributing.md](docs/contributing.md) | como evoluir o plugin sem piorá-lo |
| [docs/decisions.md](docs/decisions.md) | cada decisão tomada na construção, com o motivo |
| [evals/README.md](evals/README.md) | os casos de referência para rodar após qualquer mudança grande |

> A documentação em `docs/` é escrita em inglês, seguindo a convenção interna do
> plugin. Este README é a exceção deliberada: é a apresentação do projeto.

## Licença

MIT
