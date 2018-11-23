# frozen_string_literal: true

module Sberbank
  module Acquiring
    class Client
      COMMAND_PATH_MAPPING = {
        deposit:                   'deposit',
        get_order_status_extended: 'getOrderStatusExtended',
        payment:                   'payment',
        payment_sber_pay:          'paymentSberPay',
        refund:                    'refund',
        register:                  'register',
        register_pre_auth:         'registerPreAuth',
        reverse:                   'reverse',
        verify_enrollment:         'verifyEnrollment'
      }.freeze

      attr_reader :test
      alias test? test

      def initialize(username: nil, password: nil, token: nil, test: false)
        @test = !!test

        # TODO: more informative exception on nil credentials
        credentials_data = if token.nil?
                           { username: username, password: password }
                           else
                           { token: token }
                           end

        @credentials = Sberbank::Acquiring::Credentials.new(credentials_data)
      end

      COMMAND_PATH_MAPPING.each do |command, path|
        define_method command do |params|
          Sberbank::Acquiring::Request.new(
            path: path,
            credentials: @credentials,
            params: params,
            test: test
          ).perform
        end
      end
    end
  end
end
