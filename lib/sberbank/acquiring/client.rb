# frozen_string_literal: true

module Sberbank
  module Acquiring
    class Client
      attr_reader :test
      alias test? test

      def initialize(username: nil, password: nil, token: nil, test: false)
        @test = !!test
        @parameters_convertor = build_parameters_convertor(username: username, password: password, token: token)
      end

      def execute(path:, params:)
        CommandResponseDecorator.new(
          Request.new(path: path, params: @parameters_convertor.convert(params), test: test).perform
        )
      end

      def deposit(params)
        execute(path: '/payment/rest/deposit.do', params: params)
      end

      def get_order_status_extended(params)
        execute(path: '/payment/rest/getOrderStatusExtended.do', params: params)
      end

      def payment(params)
        execute(path: '/payment/rest/payment.do', params: params)
      end

      def payment_sber_pay(params)
        execute(path: '/payment/rest/paymentSberPay.do', params: params)
      end

      def refund(params)
        execute(path: '/payment/rest/refund.do', params: params)
      end

      def register(params)
        execute(path: '/payment/rest/register.do', params: params)
      end

      def register_pre_auth(params)
        execute(path: '/payment/rest/registerPreAuth.do', params: params)
      end

      def reverse(params)
        execute(path: '/payment/rest/reverse.do', params: params)
      end

      def verify_enrollment(params)
        execute(path: '/payment/rest/verifyEnrollment.do', params: params)
      end

      private

      def build_parameters_convertor(username: nil, password: nil, token: nil)
        CommandParametersConvertor.new(
          token &&
          { 'token' => token } ||
          { 'userName' => username, 'password' => password }
        )
      end
    end
  end
end
