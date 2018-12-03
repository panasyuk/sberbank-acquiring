# Sberbank::Acquiring

[![Build Status](https://travis-ci.org/panasyuk/sberbank-acquiring.svg?branch=master)](https://travis-ci.org/panasyuk/sberbank-acquiring)

## Описание

GEM sberbank-acquiring предоставляет функциональность для взаимодействия с API эквайринга банка Сбербанк.

## Установка

```ruby
# Gemfile
gem 'sberbank-acquiring', github: 'panasyuk/sberbank-acquiring'
```

## Использование

### SBRF::Acquiring::Client

```ruby
# client отправляет запросы на боевой сервер эквайринга
client = SBRF::Acquiring::Client.new(username: 'username', password: 'password')

# test_client отправляет запросы на тестовый сервер эквайринга
test_client = SBRF::Acquiring::Client.new(token: 'token', test: true)
```

#### Создание заказа на 10 рублей
```ruby
response = client.register(
  amount: 1000, # в самых мелких долях валюты
  order_number: 'order#1',
  return_url: 'https://example.com/sberbank/success'
)
```

```ruby
response.success? # => true
response.error?   # => false

response.data # => { "orderId" => "f3ced54d-45df-7c1a-f3ce-d54d04b11830", "formUrl" => "https://3dsec.sberbank.ru/payment/merchants/sbersafe/payment_ru.html?mdOrder=f3ced54d-45df-7c1a-f3ce-d54d04b11830" }

response.order_id # => "f3ced54d-45df-7c1a-f3ce-d54d04b11830"
response.form_url # => "https://3dsec.sberbank.ru/payment/merchants/sbersafe/payment_ru.html?mdOrder=f3ced54d-45df-7c1a-f3ce-d54d04b11830"

```

#### Проверка состояния заказа
```ruby
response = client.get_order_status_extended(order_id: 'f3ced54d-45df-7c1a-f3ce-d54d04b11830')
```
или

```ruby
response = client.get_order_status_extended(order_number: 'order#1')
```

```ruby
response.data # =>
# {
#   "errorCode" => "0",
#   "errorMessage" => "Успешно",
#   "orderNumber" => "order#2",
#   "orderStatus" => 0,
#   "actionCode" => -100,
#   "actionCodeDescription" => "",
#   "amount" => 1000,
#   "currency" => "643",
#   "date" => 1531643056391,
#   "merchantOrderParams" => [],
#   "attributes" => [{ "name" => "mdOrder", "value" => "aefeb658-48fb-7f37-aefe-b65804b11830" }],
#   "terminalId" => "123456",
#   "paymentAmountInfo" => { "paymentState" => "CREATED", "approvedAmount" => 0, "depositedAmount" => 0,  "refundedAmount" => 0},
#   "bankInfo" => { "bankCountryCode" => "UNKNOWN", "bankCountryName" => "<Неизвестно>" }
# }

response.attributes # => [{ "name" => "mdOrder", "value" => "aefeb658-48fb-7f37-aefe-b65804b11830" }]
response.bank_info # => { "bankCountryCode" => "UNKNOWN", "bankCountryName" => "<Неизвестно>" }
```

Запрос состояния заказа с результатом на английском языке:
```ruby
response = client.get_order_status_extended(language: 'en', order_number: 'order#1')
```

```ruby
response.data # =>
# {
#   "errorCode" => "0",
#   "errorMessage" => "Success",
#   "orderNumber" => "order#2",
#   "orderStatus" => 0,
#   "actionCode" => -100,
#   "actionCodeDescription" => "",
#   "amount" => 1000,
#   "currency" => "643",
#   "date" => 1531643056391,
#   "merchantOrderParams" => [],
#   "attributes" => [{ "name" => "mdOrder", "value" => "aefeb658-48fb-7f37-aefe-b65804b11830" }],
#   "terminalId" => "123456",
#   "paymentAmountInfo" => { "paymentState" => "CREATED", "approvedAmount" => 0, "depositedAmount" => 0, "refundedAmount" => 0},
#   "bankInfo" => { "bankCountryCode" => "UNKNOWN", "bankCountryName" => "<Unknown>" }
# }

response.terminal_id # => "123456"
```

### Проверка контрольной суммы callback-уведомлений

API эквайринга Сбербанка поддерживает два вида callback-уведомлений: без контрольной суммы и с контрольной суммой.
В случае обработки уведомления с контрольной суммой, алгоритм проверки включает в себя выполнение запроса 'getOrderStatusExtended' к API эквайринга для проверки действительного статуса платежа. В остальных случаях требуется проверка параметра `checksum` с использованием симметричного или асимметричного ключа.

#### Симметричный ключ

```ruby
# params = {}
symmetric_key = '20546026a3675994185a132875efe41a'

callback_params = params.dup
checksum = callback_params.delete('checksum')

validator = Sberbank::Acquiring::SymmetricKeyChecksumValidator.new(symmetric_key)
if validator.validate(checksum, callback_params)
  # запрос успешно прошел валидацию, контрольная сумма верна
else
  # запрос не может быть обработан, так как контрольная сумма неверна
end
```

## Разработка

После клонирования репозитория, выполните `bin/setup` чтобы установить зависимости. Затем выполните `rake test`, чтобы запустить тесты. Так же можно запустить интерактивную консоль для экспериментов, выполнив `bin/console`.

## TODO

1. Добавить проверку Callback-уведомлений для асимметричного ключа
2. Добавить в документацию примерный код обработки Callback для симметричного и асимметричного ключей для Rails, Sinatra, и проч. rack-based apps.
3. v0.1.0

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/panasyuk/sberbank-acquiring.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
