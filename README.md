# Desafio técnico e-commerce

Projeto foi feito com docker, rodando no terminal ubuntu

SETUP
======
URL de acesso ao projeto caso necessário -> http://localhost:3000
- Execução para rodar os containers -> <strong>docker-compose build --no-cache<strong>
- Subir o principal docker-compose run web bundle exec rails db:create db:migrate
- Subir container web docker-compose up web
- Subir o sidekiq docker-compose up sidekiq
- Subir o rails console docker-compose exec web bundle exec rails c
  
-----

Caso ocorra alguma divergência de PID do docker
docker-compose run --rm web rm -f tmp/pids/server.pid

Caso seja necessário remover os containers
docker-compose down --remove-orphans

-----

Cadastros
======
Cadastrar 1 produto para requests, pode ser feito via API ou usar a factory.
- curl -X GET http://localhost:3000/products -> Consulta os produtos
- curl -X GET http://localhost:3000/products/1 -> Retorna o produto de ID 1
- curl -X POST http://localhost:3000/products -H "Content-Type: application/json" -d '{"name": "Produto 1", "price": 5.5}' -> Cadastra um produto
- curl -X PATCH http://localhost:3000/products/1  -H "Content-Type: application/json"  -d '{"product": {"name": "Produto novo", "price": 99.0}}' -> Atualiza um produto
- curl -X DELETE http://localhost:3000/products/1 -> Remove um produto

FactoryBot no rails C, seguir o comando informado no SETUP

FactoryBot.create(:product) -> Cria 1 produto
FactoryBot.create_list(:product, 10) -> Cria 10 produtos

-----

Teste do carrinho
======
- curl -X GET http://localhost:3000/cart -> Consulta carrinho atual
- curl -X POST http://localhost:3000/cart -H "Content-Type: application/json" -d '{"product_id": 1}' -> Insere um item no carrinho, se não for informado a quantidade o padrão é 1
- curl -X PATCH http://localhost:3000/cart/add_item -H "Content-Type: application/json" -d '{"product_id": 3, "quantity": 1}' -> Atualiza o carrinho, se o ID do produto já existir, atualiza quantidade somando, do contrário incluir o item.
- curl -X DELETE http://localhost:3000/cart/1 -> Remove do carrinho atual o item (Produto), para a request é necessário passar o ID do produto

-----

Teste do sidekiq
======

No rails C
Cart.last.update(updated_at: 4.hours.ago) -> Irá marcar como abandonado
Forçar a tarefa -> MarkCartAsAbandonedJob.perform_in(5.seconds)

No rails C
Cart.last.update(updated_at: 8.days.ago) -> Irá remover o carrinho que foi marcado como abandonado
RemoveCartAbandonedJob.perform_in(5.seconds)

-----

Testar specs
======

- docker-compose exec web bundle exec rspec spec/models/cart_item_spec.rb
- docker-compose exec web bundle exec rspec spec/models/cart_spec.rb
- docker-compose exec web bundle exec rspec spec/requests/carts_spec.rb
- docker-compose exec web bundle exec rspec spec/requests/products_spec.rb
- docker-compose exec web bundle exec rspec spec/routing/carts_routing_spec.rb
- docker-compose exec web bundle exec rspec spec/routing/products_routing_spec.rb
- docker-compose exec web bundle exec rspec spec/sidekiq/mark_cart_as_abandoned_job_spec.rb
- docker-compose exec web bundle exec rspec spec/sidekiq/remove_cart_abandoned_job_spec.rb

-----

Pontos possíveis para melhoriaa
======

- 1 - O ideal para controlar melhor os carrinhos, no payload informar o ID do carrinho, tratar na requisição
- 2 - Tirar mensagens hardcode, usar I18n para tratamento
- 3 - Tratamento das foreign keys com mensagens customizadas, melhorias no model
- 4 - Automatização no docker de todos os comandos
- 5 - Criar helper para chamadas da API
- 6 - Ajustar specs, simplificar lógica
