# Criando um Pipeline de Deploy de uma Aplicação Utilizando GitLab, Docker e Kubernetes

Este projeto é um exemplo simples de CI/CD. Ele mostra a viagem do código até o Kubernetes:

`push na main` → `testes` → `imagem Docker` → `registro de imagens` → `Kubernetes`

## Arquivos importantes

- `.gitlab-ci.yml`: pipeline para o GitLab.
- `.github/workflows/ci.yml`: pipeline equivalente para o GitHub Actions.
- `Dockerfile`: receita da imagem que contém a aplicação.
- `kubernetes/aplicacao.yml`: instruções básicas para o Kubernetes manter uma cópia da aplicação rodando.

Os comentários desses arquivos explicam cada parte com palavras simples.

## Primeiro: só testes e imagem

Depois de enviar o projeto para a branch `main` no GitHub, o workflow testa a aplicação e publica uma imagem em GitHub Packages (GHCR). A etapa de Kubernetes fica desligada inicialmente para não tentar acessar um cluster que você ainda não configurou.

Para o cluster conseguir baixar a imagem de forma simples, deixe o pacote de container público no GitHub: abra o pacote criado, entre em **Package settings** e escolha **Change visibility → Public**.

No GitLab, a mesma ideia vale para o Container Registry: para este exemplo simples, deixe a imagem disponível para o cluster. Em projetos reais, normalmente usamos um segredo chamado `imagePullSecret`; ele foi deixado de fora para o primeiro contato com Kubernetes não ficar complicado.

## Depois: ativar o Kubernetes

Quando você já tiver um cluster, configure estes valores no repositório GitHub em **Settings → Secrets and variables → Actions**:

- Variável `DEPLOY_ENABLED` com o valor `true`: liga a última etapa do pipeline.
- Segredo `KUBE_CONFIG_DATA`: seu arquivo `kubeconfig` convertido em Base64. No PowerShell, use:

  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("$env:USERPROFILE\.kube\config"))
  ```

O segredo dá acesso ao cluster. Nunca o coloque no código ou em commits.

Para testar a aplicação localmente em um cluster que já esteja configurado no seu computador, use:

```powershell
kubectl apply -f kubernetes/
kubectl -n curso-cicd port-forward service/aplicacao-node 3000:80
```

Depois abra `http://localhost:3000`. O primeiro comando cria os objetos; o segundo cria um túnel temporário até a aplicação.

## Variáveis equivalentes no GitLab

No GitLab, a imagem é enviada ao Container Registry do próprio projeto. Para ativar o deploy, cadastre a variável protegida `KUBE_CONFIG_DATA` em **Settings → CI/CD → Variables**, usando a mesma conversão Base64 descrita acima.

Para a etapa Docker funcionar no GitLab, o runner precisa permitir Docker-in-Docker (a opção costuma se chamar **privileged**). Os runners compartilhados ou o administrador do GitLab normalmente já definem isso; se aparecer uma mensagem dizendo que o Docker daemon não pode ser acessado, este é o primeiro item para conferir.
