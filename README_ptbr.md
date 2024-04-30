# pipeline-apiops-template

## Getting started

O processo de APIOps consistem em ... @Americo

Para isso, esse template de pipeline foi criado como base para uso dos usuários do Sensedia CLI (ssd) em seu(s) gateways.

### Fluxo da pipeline

A pipeline é dividida em duas etapas:
- Build stage
- Deploy stage

Build stage contempla as seguintes ações:
1. **Checkout**: prepara o ambiente do GitHub actions clonando o repositório.
2. **Filter differences**: filtra os arquivos modificados/novos da ultima execução da pipeline em relação a execução corrente
3. **Test/Lint**: verifica e aponta problemas de escrita nos YAMLs
4. **Save Build Artifact**: salva um artefato contendo o ambiente de Build Stage para uso na etapa de Deploy Stage

Deploy stage contempla as seguintes ações:
1. **Download Build Artifact**: recupera o artefato da etapa de Build e mapeia no ambiente de execução corrente
2. **Load env vars**: carrega algumas variáveis de ambiente utilizadas na pipeline para o ambiente corrente e prepara para a execução do Sensedia CLI (ssd)
3. **Setup cli**: Configura o ambiente corrente para execução do comando `ssd` (Sensedia CLI)
4. **ssd apply CRDs**: executa os diversos CRDs escritos em YAML pelo comando `ssd apply` em ordem de manipulação dos recursos no Gateway Sensedia. A ordem dos kinds aplicação são:
    1. RestAPI (arquivo com prefixo `restapi-`)
    2. Environment (arquivo com prefixo `env-`)
    3. ApiEnvironmentLink (arquivo com prefixo `apienvlink-`)
    4. Deployment (arquivo com prefixo `deployment`)
    5. Plan (arquivo com prefixo `plan-`)
    6. App (arquivo com prefixo `app-`)

*Os kinds suportados pela pipeline são os apresentados acima*.

### Acionadores da pipeline

Os acionadores para a pipeline executar são as seguintes branchs:
- main
- dev
- hml

## Configurando pipeline

### Variáveis e segredos do ambiente

Para execução da pipeline de APIOps, é preciso configurar a variável de ambiente **SENSEDIA_CLI_MANAGER_URL** e o segredo **SENSEDIA_CLI_TOKEN**.

|Nome|Tipo|Obrigatoriedade|Exemplo|Descrição|
|-|-|-|-|-|
|SENSEDIA_CLI_MANAGER_URL|Variável|Sim|https://manager.sensedia.com|URL base do Gateway Sensedia|
|SENSEDIA_CLI_TOKEN|Segredo|Sim|d3c2ebf8-8d10-473d-8cf7-a1ce3ac5b7ab|Token do Sensedia CLI|

A pipeline está configurada para puxar as variaveis e as secrets configuradas no repo do GitHub de acordo com o nome da branch. Por exemplo: Se o processo de APIOps for em cima da branch **main** contendo todos os ambientes do gateway Sensedia, é necessário criar um **Environment** com o nome **main** e adicionar as variáveis e segredos de acordo com a tabela acima.

## Estruturação do repo

A seguinte estrutura é recomendada:

```
.
├── .github
│   └── workflows
|       └── pipeline.yaml
├── apis
|   └── <api-name>
|       ├── apienvlink-<name>.yaml
|       ├── deployment-<name>.yaml
|       ├── plan-<name>.yaml
|       └── restapi-<name>.yaml
├── environments
|   └── env-<name>.yaml
└── apps
    └── app-<name>.yaml
```

## API Exemplo: Pokemon

```
.
├── .github
│   └── workflows
|       └── pipeline.yaml
├── apis
|   └── pokemon-v1
|       ├── apienvlink-pokemon-v1.yaml
|       ├── deployment-pokemon-v1.yaml
|       ├── plan-pokemon-v1.yaml
|       └── restapi-pokemon-v1.yaml
├── environments
|   └── env-dev.yaml
└── apps
    └── app-dev-pokemon-v1.yaml
```

- apis/pokemon-v1/restapi-pokemon-v1.yaml
```yaml
apiVersion: api-management.sensedia.com/v1
kind: RestAPI
spec:
  name: pokemon-v1
  version: 1.0.0
  basePath: /pokemon/v1
  stageRef:
    name: Draft
  description: API 
  resources:
  - name: pokemon
    operations:
    - method: GET
      path: pokemon
  flow:
    destination: $poke-url
    requestInterceptors:
    - custom:
      name: "Bearer Token - RFC6750 (client)"
    - oauth:
        allowedGrantTypes: ["ClientCredentials"]
    - log:
        encryptContent: false
        encryptParams: false
    - spikeArrest:
        interval: Minute
        limit: 10
    responseInterceptors:
    - log:
        encryptContent: false
        encryptParams: false
```
