# prototypen

Um plugin para o [Claude Code](https://claude.com/claude-code) que transforma
uma ideia com requisitos num protótipo navegável no canvas do
[Pencil (pen.dev)](https://pen.dev), com sistema de design, marca e os
documentos que fazem o handoff para a implementação.

Ele existe porque design gerado por IA tem uma cara reconhecível (Inter,
azul `#3b82f6`, card branco com sombra suave, hero centralizado), e pedir
criatividade não muda isso. O plugin declara restrições antes de desenhar
qualquer coisa (pesquisa, marca, uma direção de design escrita e escolhida
entre três) e audita o resultado contra essas restrições num contexto
separado. O raciocínio completo está em
[docs/architecture.md](docs/architecture.md).

## Requisitos

- [Claude Code](https://claude.com/claude-code).
- O CLI do pen.dev, instalado e logado: `npm install -g @pen.dev/cli`, depois
  `pen login`. É por ele que o plugin salva o canvas, e é por ele que roda
  quando nenhum editor está aberto. (O comando `pencil` no seu PATH pode
  ser o app desktop; o CLI é `pen`.)
- Um repositório git no projeto que vai receber o design. O plugin commita
  ao fim de cada fase, só dentro de `design/`, numa branch `design/<data>`
  quando você está na branch principal.
- Para acompanhar o canvas ao vivo: o pen.dev desktop ou a extensão do VS
  Code, com o servidor MCP `pencil` conectado ao Claude Code. Opcional; veja
  "App aberto ou headless" abaixo.

## Instalação

```bash
claude plugin marketplace add leonextlevel/prototypen-plugin
claude plugin install prototypen@prototypen
```

Ou a partir de um clone local: `claude --plugin-dir /caminho/para/prototypen-plugin`.

O pipeline faz centenas de chamadas de ferramenta sem parar, então
pré-aprove: rode o Claude Code em modo auto, ou adicione a allowlist de
[docs/usage.md](docs/usage.md#permissions-for-an-unattended-run) ao
`.claude/settings.json` do projeto.

## Uso

Descreva o que quer construir, no idioma em que você trabalha:

> Projete um app para uma transportadora pequena acompanhar fretes: uma lista
> dos fretes ativos com status, transportadora, custo e previsão, uma visão de
> detalhe por frete e um relatório semanal de custo. Três operadores usam o
> dia inteiro no desktop.

Isso aciona o `/prototypen:prototype`. Ele faz uma pergunta no início (por
qual caminho acessar o canvas, qual branch recebe os commits, se explora a
marca antes) e depois roda até o handoff sem parar: intake, pesquisa,
marca, direção, sistema de design, telas, revisão de layout, auditoria com
ciclo de correção, exports e a spec de handoff. Tudo que ele produz
acompanha o seu idioma; nomes de arquivo e de camadas do canvas ficam em
inglês.

As cinco skills, na ordem em que você as usaria:

| Skill | O que faz |
|---|---|
| `/prototypen:discover` | Opcional. Faz as perguntas que valem a pena, em no máximo três rodadas, e escreve `design/product-spec.md`. Se você pular, o pipeline escreve a spec sozinho e registra cada palpite em Assumptions. |
| `/prototypen:brand` | Opcional. Põe três candidatos de marca lado a lado no canvas (nome, símbolo, paleta, um espécime), refina o que você escolher e escreve `design/brand.md`. Para quando a identidade importa e você quer ver opções. |
| `/prototypen:prototype` | O pipeline. Também é a porta de entrada das rodadas seguintes: "adicione ações em lote na lista de fretes" roda de forma incremental sobre o design existente. |
| `/prototypen:finalize` | Quando o design terminou: consolida `design/` numa pasta padrão com um `README.md` de entrada, dobra as emendas nos documentos e refaz os exports. |
| `/prototypen:roadmap` | A partir de um design finalizado: um roadmap de negócio em `docs/`, com cada tela em exatamente um marco e os estados como critérios de aceite. |

### App aberto ou headless

Toda skill que desenha começa com essa pergunta, uma vez, com um padrão
sugerido:

- **Headless** (sugerido para a rodada completa): o plugin usa o motor do
  pen.dev pelo CLI, sem editor aberto. Salva sozinho e não consegue escrever
  no arquivo errado. Mantenha `design/prototype.pen` fechado no Pencil
  enquanto roda; quando ele avisar que terminou, abra o arquivo.
- **App aberto** (sugerido para rodadas incrementais, `brand` e `finalize`):
  o pen.dev está aberto com `design/prototype.pen` como editor ativo e você
  vê o canvas mudando. O plugin salva antes de cada commit; você nunca
  precisa do Ctrl+S.

O resultado é o mesmo nos dois. O app desktop não salva sozinho um `.pen`
existente nem recarrega um arquivo alterado no disco, e é por isso que os
dois modos são mantidos separados e o runner headless se recusa a escrever
enquanto o arquivo estiver aberto no app.

### Quanto ele desenha

Por padrão uma rodada desenha o **caminho principal**: o core loop de ponta
a ponta, as telas secundárias que o tipo de aplicação exige (404, sessão
expirada, permissões e afins) e os estados que só aquelas telas têm. Os
estados que toda tela compartilha (carregando, vazio, erro, lista longa,
texto longo, primeiro uso, permissão negada) são construídos uma vez por
arquétipo de tela, como exemplares no sistema de design, e toda tela os
herda. O que os trabalhos implicam além disso fica listado em Backlog na
spec, para a próxima rodada. Peça `full` no discover para desenhar o
inventário inteiro de uma vez.

### Ajustando um protótipo existente

Qualquer pedido depois de uma rodada concluída é aplicado sob um protocolo
de verificação: o pedido vira checks com números antes de tocar no canvas,
a tela recebe um snapshot antes e depois para o diff mostrar o que se
moveu, e o relatório lista cada check como PASS ou FAIL. Se o pedido
conflitar com uma regra que o projeto já tem (uma cor fora da paleta, um
delete sem confirmação, uma tela sem a navegação), você é perguntado antes
de qualquer mudança: emendar a regra em todo lugar, abrir uma exceção
nomeada naquela tela, ou manter a regra e fazer o mais próximo dentro dela.

## O que você recebe

```
design/
├── README.md            depois do finalize: a porta de entrada
├── product-spec.md      personas, jobs, alvos, inventário de telas, estados, mapa de navegação, backlog
├── research.md          concorrentes, convenções, antipadrões, fontes
├── brand.md             nome, posicionamento, tom, paleta, regras do logo
├── brand/logo/*.svg     cinco variações do logo
├── design-direction.md  a direção escolhida, o inventário de tokens, a lista de componentes
├── changes.md           cada decisão que a rodada tomou em vez de perguntar, e o porquê
├── audits/<data>.md     cada critério, PASS ou FAIL
├── design-spec.md       o handoff: tokens para código, componentes, telas, regras, rotas
├── tokens.json          todas as variáveis, formato W3C Design Tokens, todos os temas
├── tokens.css           o mesmo como custom properties, por tema
├── prototype.pen        o canvas
└── screens/             um PNG por versão de tela e estado, cada fluxo em HTML (não versionado)
```

O canvas tem uma região `Design System` (tokens, componentes, os
exemplares de estado), uma região `Brand` e uma região por fluxo. Dentro do
fluxo, um grupo em coluna por tela, na ordem da navegação; a primeira linha
do grupo traz as versões da tela lado a lado (desktop, mobile, a cópia em
dark), e cada estado específico e overlay ganha uma linha abaixo.

## Custo

O modelo caro é gasto onde o julgamento decide o resultado (direção,
marca, a auditoria visual) e o mais barato na execução (o designer, a
auditoria estrutural, a revisão de layout). Qual agente roda em qual
modelo, e onde trocar, é uma tabela em
[docs/usage.md](docs/usage.md#which-model-does-what). Uma primeira rodada
completa num produto real ainda é longa; inicie e volte depois.

## Documentação

A documentação em `docs/` é escrita em inglês, seguindo a convenção interna
do plugin; este README é a exceção deliberada.

| | |
|---|---|
| [docs/usage.md](docs/usage.md) | como rodar, permissões, ler uma auditoria, retomar, troubleshooting |
| [docs/pipeline.md](docs/pipeline.md) | as fases em detalhe, artefatos, pontos de commit |
| [docs/architecture.md](docs/architecture.md) | as peças, o que cada uma decide, por que a auditoria é isolada |
| [docs/development.md](docs/development.md) | instalação a partir do código, hooks, scripts, validação, layout do repositório |
| [docs/contributing.md](docs/contributing.md) | como evoluir o plugin sem piorá-lo |
| [docs/decisions.md](docs/decisions.md) | cada decisão tomada na construção, com o motivo |
| [evals/README.md](evals/README.md) | os casos de referência para rodar após qualquer mudança grande |

## Licença

[MIT](LICENSE)
