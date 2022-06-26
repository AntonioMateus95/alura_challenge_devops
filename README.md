# Alura Challenge Devops: Aluraflix
Este repositório tem como objetivo apresentar uma solução para o primeiro challenge Devops da Alura.

## Rodando o projeto localmente
Certifique-se de que você possui a Docker engine instalada, caso contrário siga os passos deste [link](https://docs.docker.com/desktop/).
Uma vez instalado e habilitado na sua máquina, podemos usar o docker compose para subir a aplicação. Para isso:

1. Na raiz do projeto, crie dois arquivos:

app.env.local:
```
DB_USER=<usuário para acessar o banco de dados postgres>
DB_PASSWORD=<senha do referido usuário>
DJANGO_SUPERUSER_EMAIL=<e-mail do usuário admin da aplicação>
DJANGO_SUPERUSER_USERNAME=<username do usuário admin da aplicação>
DJANGO_SUPERUSER_PASSWORD=<senha do usuário admin da aplicação>
```

db.env.local:
```
POSTGRES_USER=<usuário para acessar o banco de dados postgres>
POSTGRES_PASSWORD=<senha do referido usuário>
```

Lembrando que o par usuário/senha do segundo arquivo deverá corresponder às variáveis DB_USER e DB_PASSWORD do primeiro.

2. Builde a aplicação através do comando
```
docker compose build
```

3. Rode a aplicação
```
docker compose up
```

Feito isso, você poderá acessar a aplicação no seu browser favorito através do endereço [http://localhost:8080/programas](http://localhost:8080/programas)

## Montagem do ambiente na cloud (AWS)

1. Dentro do serviço Elastic Container Service (ECS) crie um cluster a partir do template "EC2 Linux + Networking" de nome alura-challenge-devops. Ao escolher o tipo de instância EC2, selecione a t2.micro pois ela faz parte do [free tier](https://aws.amazon.com/pt/free/). O número de instâncias precisa ser de no mínimo duas por causa do load balancer e permita o passo-a-passo criar uma VPC e um security group para você.
2. Na seção EC2, crie um target group do tipo instância com o nome da sua aplicação (aluraflix, por exemplo). Ele precisará estar dentro da mesma VPC, criada automaticamente no passo anterior.
3. Como eu não usei o Docker Hub para hospedar a imagem do projeto, eu precisei criar um repositório privado no ECR (Elastic Container Registry).
4. Para armazenar as secrets deste repositório (DB_HOST, DB_USER, DB_PASSWORD, DJANGO_SUPERUSER_EMAIL, DJANGO_SUPERUSER_USERNAME, DJANGO_SUPERUSER_PASSWORD e ALLOWED_HOSTS), eu criei parâmetros dentro da Parameter Store do SSM (Systems Manager) da AWS. Ele permite criar parâmetros do tipo String, StringList (valores entre vírgulas) e SecureString (ideal para senhas).
5. Será necessário criar um servidor de banco de dados RDS na mesma VPC do cluster ECS. Como extra, eu criei um security group específico para o DB permitindo acesso a partir do meu IP e dos security groups criados juntos com a VPC do cluster.
6. De volta à seção ECS, configure uma task definition do tipo EC2 via json usando o arquivo .aws/task-definition.json como exemplo. Será necessário mudar a arn dos secrets e das duas roles. Certifique-se primeiro de criar uma role que tenha permissão não só para executar as tasks, como também para pegar os parâmetros da SSM.
7. Crie um application load balancer usando o security group criado junto com o cluster ECS e aponte o listener para o target group do passo 2.
8. Por fim crie uma service dentro do cluster ECS que use a task definition para subir as tasks dinamicamente.

## Continous Integration e Continuous Deployment
Foi utilizado o Github actions para executar os dois processos. O script de CI roda após o push em qualquer branch com exceção da master e o script de CD roda apenas no push feito para a master.
Modifiquei o repositório para não aceitar push feito à branch master sem um Pull Request.
