require 'securerandom'

module PayPal::SDK::Subscriptions
  # API error: returned as 200 + "error" key in response.
  class UnsuccessfulApiCall < RuntimeError
    attr_reader :api_error

    def initialize(api_error)
      super(api_error['message'])
      @api_error = api_error
    end
  end

  class RequestBase < PayPal::SDK::Core::API::DataTypes::Base
    include RequestDataType

    attr_accessor :error
    attr_writer   :header, :request_id

    def header
      @header ||= {}
    end

    def request_id
      @request_id ||= SecureRandom.uuid
    end

    def http_header
      { "PayPal-Request-Id" => request_id.to_s }.merge(header)
    end

    def success?
      @error.nil?
    end

    def merge!(values)
      @error = nil
      super
    end

    def raise_error!
      raise UnsuccessfulApiCall, error if error
    end

    def self.raise_on_api_error(*methods)
      methods.each do |symbol|
        define_method("#{symbol}!") {|*arg|
          raise_error! unless send(symbol, *arg)
        }
      end
    end
  end
end
