# 💳 Sberbank::Acquiring

[![Gem Version](https://badge.fury.io/rb/sberbank-acquiring.svg)](https://badge.fury.io/rb/sberbank-acquiring)
[![Build Status](https://travis-ci.org/panasyuk/sberbank-acquiring.svg?branch=master)](https://travis-ci.org/panasyuk/sberbank-acquiring)

🔻Ruby Version 2.1 - 2.6 (+ JRuby)  
🎈Никаких сторонних зависимостей

## Основная функциональность
- Выполнение всех запросов к API эквайринга Сбербанка согласно документации (создание заказов, проверка их статуса и т.д)
- Выполнение любых запросов к API эквайринга Сбербанка
- Проверка контрольной суммы callback-уведомлений с симметричной и асимметричной криптографией

**В разработке:**
- Поддержка ФФД 1.05

## Описание

GEM sberbank-acquiring предоставляет функциональность для взаимодействия с API эквайринга банка Сбербанк. Он использует RESTful API эквайринга Сбербанка.

Перед тем, как приступить к использованию этого гема, автор настоятельно рекомендует (хотя бы бегло) ознакомиться с официальной [документацией к JSON API эквайринга Сбербанка](https://securepayments.sberbank.ru/wiki/doku.php/integration:api:start#%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D1%84%D0%B5%D0%B9%D1%81_rest), а так же [Wiki](https://github.com/panasyuk/sberbank-acquiring/wiki), кому интересно

## Установка

```ruby
# Gemfile
gem 'sberbank-acquiring', github: 'panasyuk/sberbank-acquiring'
# или
gem 'sberbank-acquiring', '~> 0.2.0'
```

## Использование

### SBRF::Acquiring::Client

```ruby
# client отправляет запросы на боевой сервер эквайринга
client = SBRF::Acquiring::Client.new(username: 'username', password: 'password')

# test_client отправляет запросы на тестовый сервер эквайринга
test_client = SBRF::Acquiring::Client.new(token: 'token', test: true)
```

Клиент может выполнять следующие вызовы к API:

| Название метода                  | Путь API                                |
| -------------------------------- | --------------------------------------- |
| deposit                          | /payment/rest/deposit.do                |
| get_order_status_extended        | /payment/rest/getOrderStatusExtended.do |
| payment                          | /payment/rest/payment.do                |
| payment_sber_pay                 | /payment/rest/paymentSberPay.do         |
| refund                           | /payment/rest/refund.do                 |
| register                         | /payment/rest/register.do               |
| register_pre_auth                | /payment/rest/registerPreAuth.do        |
| reverse                          | /payment/rest/reverse.do                |
| verify_enrollment                | /payment/rest/verifyEnrollment.do       |

Все методы ожидают в качестве агрумента `Hash`, с ключами в **underscore**.
При подготовке параметров к отправке, эта структура претерпит следующие изменения:

1. Все ключи рекурсивно будут сконвертированы в **camelCase**
2. Все значения класса `Hash` будут переданы в виде JSON

Например этот код:

```ruby
client.register(
  amount: 1000,
  order_number: 'order#1',
  return_url: 'https://example.com/sberbank/success',
  json_params: { user_email: 'test@example.com' }
)
```

сначала приведет параметры к следующему виду:

```ruby
{
  'amount' => 1000,
  'orderNumber' => 'order#1',
  'returnUrl' => 'https://example.com/sberbank/success',
  'jsonParams' => '{"userEmail":"test@example.com"}'
}
```

a затем превратит их в параметры запроса:
`amount=1000&orderNumber=order%231&returnUrl=https%3A%2F%2Fexample.com%2Fsberbank%2Fsuccess&jsonParams=%7B%22userEmail%22%3A%22test%40example.com%22%7D`

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
В случае обработки уведомления с контрольной суммой, алгоритм проверки включает в себя выполнение запроса 'getOrderStatusExtended' к API эквайринга для проверки действительного статуса платежа. В остальных случаях требуется проверка параметра `checksum` с использованием [симметричной или асимметричной криптографии](https://securepayments.sberbank.ru/wiki/doku.php/integration:api:callback:start).

#### Симметричная криптография

```ruby
# params = {}
key = '20546026a3675994185a132875efe41a'

callback_params = params.dup
checksum = callback_params.delete('checksum')

validator = Sberbank::Acquiring::SymmetricKeyChecksumValidator.new(key)
if validator.validate(checksum, callback_params)
  # запрос успешно прошел валидацию, контрольная сумма верна
else
  # запрос не может быть обработан, так как контрольная сумма неверна
end
```

#### Асимметричная криптография

```ruby
# params = {}
pem = File.read('< путь до файла сертификата >')

callback_params = params.dup
checksum = callback_params.delete('checksum')

validator = Sberbank::Acquiring::AsymmetricKeyChecksumValidator.new(pem)
if validator.validate(checksum, callback_params)
  # запрос успешно прошел валидацию, контрольная сумма верна
else
  # запрос не может быть обработан, так как контрольная сумма неверна
end
```

## Разработка

- После клонирования репозитория, выполните `bin/setup` чтобы установить зависимости.
- Затем выполните `rake test`, чтобы запустить тесты.
- Так же можно запустить интерактивную консоль для экспериментов, выполнив `bin/console`.

## TODO

1. Добавить API для того чтобы сделать удобнее отправку заказов по ФФД 1.05. Примерный API:
```ruby
sberbank_order = SBRF::Acquiring::Order.new(
  number: 'order#1',
  amount: 1,
  amount_cents: 100,
  return_url: 'https://',
  fail_url: 'https://',
  params: { email: 'email@example.com' },
  tax_system: SBRF::USN_INCOME
)

item =
  SBRF::Acquiring::Item.new(
  name: 'item#1',
  quantity: 2,
  measure: 'pcs',
  price: 1,
  code: 'item#1',
  tax: SBRF::VAT0)

item.tax = SBRF::VAT18

item.to_h #=> { name: '', quantity: 2. ... amount: 200, tax: { tax_type: 3, tax_sum: 36 } }

sberbank_order.items << item
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/panasyuk/sberbank-acquiring.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
