# pipeline-apiops-template

## Getting started

O processo de APIOps é uma abordagem moderna para gerenciar APIs de forma automatizada e eficiente. Neste repositorio existem processos e ferramentas para todo o ciclo de vida de uma API, desde a criação e desenvolvimento até a implantação, através do Sensedia API Plartform.

### Fluxo da pipeline

A pipeline é dividida em duas etapas:
- `Build stage`
- `Deploy stage`

Build stage contempla as seguintes ações:

1. **Checkout**: prepara o ambiente do GitHub actions clonando o repositório.
2. **Filter differences**: filtra os arquivos modificados/novos da ultima execução da pipeline em relação a execução corrente
3. **Test/Lint**: verifica e aponta problemas de escrita nos YAMLs
4. **Save Build Artifact**: salva um artefato contendo o ambiente de Build Stage para uso na etapa de Deploy Stage

Deploy stage contempla as seguintes ações:

1. **Download Build Artifact**: recupera o artefato da etapa de Build e mapeia no ambiente de execução corrente
2. **Setup cli**: Configura o ambiente corrente para execução do comando `ssd` (Sensedia CLI)
3. **ssd apply CRDs**: executa os diversos CRDs escritos em YAML pelo comando `ssd apply` em ordem de manipulação dos recursos no Gateway Sensedia.


### Acionadores da pipeline

Os acionadores para a pipeline executar são as seguintes branchs:
- `main`
- `dev`
- `hml`

## Configurando pipeline

### Variáveis e segredos do ambiente

Para execução da pipeline de APIOps, é preciso configurar a variável de ambiente **SENSEDIA_CLI_MANAGER_URL** e o segredo **SENSEDIA_CLI_TOKEN**.

A pipeline está configurada para puxar as variaveis e as secrets configuradas no repo do GitHub de acordo com o nome da branch. Por exemplo: Se o processo de APIOps for em cima da branch **main** contendo todos os ambientes do gateway Sensedia, é necessário criar um **Environment** com o nome **main** e adicionar as variáveis e segredos de acordo com a tabela acima.

## Estruturação do repo

A seguinte estrutura é recomendada:

```
├── apps
│   └── all-apps.yaml
├── deployment
│   ├── dev
│   │   └── deployment-app-sample.yaml
│   ├── hml
│   │   └── deployment-app-sample.yaml
│   └── main
│       └── deployment-app-sample.yaml
├── environment-link
│   └── dev-cli-sample-link.yaml
├── environments
│   ├── dev
│   │   └── apiops-environment-dev.yaml
│   ├── hml
│   │   └── apiops-environment-hml.yaml
│   └── main
│       └── apiops-environment-main.yaml
├── plans
│   └── all-plans-cli-sample.yaml
└── restapi
    └── cli-sample-api.yaml
```