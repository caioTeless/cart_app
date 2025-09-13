# Desafio técnico e-commerce

Projeto foi feito com docker, rodando no terminal ubuntu


# SETUP

URL de acesso ao projeto caso necessário -> http://localhost:3000

Execução para rodar/build dos containers
```docker
docker-compose build --no-cache
```
Subir o principal e migrate
```docker
docker-compose run web bundle exec rails db:create db:migrate
```
Subir container web
```docker
docker-compose up web
```
Subir o sidekiq
```docker
docker-compose up sidekiq
```
Subir o rails console
```docker
docker-compose exec web bundle exec rails c
```
-----

Caso ocorra alguma divergência de PID do docker
```docker
docker-compose run --rm web rm -f tmp/pids/server.pid
```
Caso seja necessário remover os containers
```docker
docker-compose down --remove-orphans
```
-----

# Cadastros

Cadastrar 1 produto para requests, pode ser feito via API ou usar a factory.

Consulta os produtos
```linux
curl -X GET http://localhost:3000/products -
```
Retorna o produto de ID 1
```linux
curl -X GET http://localhost:3000/products/1
```
Cadastra um produto
```linux
curl -X POST http://localhost:3000/products -H "Content-Type: application/json" -d '{"name": "Produto 1", "price": 5.5}'
```
Atualiza um produto
```linux
curl -X PATCH http://localhost:3000/products/1  -H "Content-Type: application/json"  -d '{"product": {"name": "Produto novo", "price": 99.0}}'
```
Remove um produto
```linux
curl -X DELETE http://localhost:3000/products/1
```

FactoryBot no rails C, seguir o comando informado no SETUP

Cria 1 produto
```ruby
FactoryBot.create(:product)
```
Cria 10 produtos
```ruby
FactoryBot.create_list(:product, 10)
```
-----

# Teste do carrinho

Consulta carrinho atual
```linux
curl -X GET http://localhost:3000/cart
```
Insere um item no carrinho, se não for informado a quantidade o padrão é 1
```linux
curl -X POST http://localhost:3000/cart -H "Content-Type: application/json" -d '{"product_id": 1}'
curl -X POST http://localhost:3000/cart -H "Content-Type: application/json" -d '{"product_id": 1, "quantity": 3}'
```
Atualiza o carrinho, se o ID do produto já existir, atualiza quantidade somando, do contrário incluir o item.
```linux
curl -X PATCH http://localhost:3000/cart/add_item -H "Content-Type: application/json" -d '{"product_id": 3, "quantity": 1}'
```
Remove do carrinho atual o item (Produto), para a request é necessário passar o ID do produto
```linux
curl -X DELETE http://localhost:3000/cart/1
```

Teste do sidekiq
======

No rails C
Forçar a tarefa | Irá marcar como abandonado
```ruby
Cart.last.update(updated_at: 4.hours.ago)
MarkCartAsAbandonedJob.perform_in(5.seconds)
```

No rails C
Irá remover o carrinho que foi marcado como abandonado
```ruby
Cart.last.update(updated_at: 8.days.ago)
RemoveCartAbandonedJob.perform_in(5.seconds)
```
-----

# Testar specs

```docker
docker-compose exec web bundle exec rspec spec/models/cart_item_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/models/cart_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/requests/carts_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/requests/products_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/routing/carts_routing_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/routing/products_routing_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/sidekiq/mark_cart_as_abandoned_job_spec.rb
```
```docker
docker-compose exec web bundle exec rspec spec/sidekiq/remove_cart_abandoned_job_spec.rb
```
-----

# Pontos possíveis para melhorias

- 1 - O ideal para controlar melhor os carrinhos, no payload informar o ID do carrinho, tratar na requisição
- 2 - Tirar mensagens hardcode, usar I18n para tratamento
- 3 - Tratamento das foreign keys com mensagens customizadas, melhorias no model
- 4 - Automatização no docker de todos os comandos
- 5 - Criar helper para chamadas da API
- 6 - Ajustar specs, simplificar lógica
