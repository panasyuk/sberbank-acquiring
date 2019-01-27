# frozen_string_literal: true

require 'openssl'
require 'sberbank/acquiring/version'
require 'sberbank/acquiring/response'
require 'sberbank/acquiring/request'
require 'sberbank/acquiring/command_parameters_convertor'
require 'sberbank/acquiring/command_response_decorator'
require 'sberbank/acquiring/client'
require 'sberbank/acquiring/abstract_checksum_validator'
require 'sberbank/acquiring/symmetric_key_checksum_validator'
require 'sberbank/acquiring/asymmetric_key_checksum_validator'

module Sberbank
  module Acquiring
    # Order statuses according to https://securepayments.sberbank.ru/wiki/doku.php/integration:api:rest:requests:getorderstatusextended
    ORDER_NOT_PAID   = 0 # order is registered but not paid
    ORDER_HOLDED     = 1 # pre-auth amount is holded (for 2-step payments)
    ORDER_AUTHORIZED = 2 # order amount is fully authorized
    ORDER_CANCELLED  = 3 # authorization is cancelled
    ORDER_REFUNDED   = 4 # transaction amount was refunded
    ORDER_PENDING    = 5 # authorization pending
    ORDER_REJECTED   = 6 # authorization rejected

    OPERATION_SUCCEEDED = 1
    OPERATION_FAILED    = 0

    OPERATION_APPROVED  = 'approved'.freeze  # amount holded
    OPERATION_DEPOSITED = 'deposited'.freeze # oparation finished
    OPERATION_REVERSED  = 'reversed'.freeze  # operation cancelled
    OPERATION_REFUNDED  = 'refunded'.freeze  # amount refunded
  end
end

SBRF = Sberbank
