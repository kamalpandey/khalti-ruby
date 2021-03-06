# frozen_string_literal: true

module Khalti
  # Handles API calls
  module RequestHelper
    class << self
      SECRET_KEY = ENV['KHALTI_SECRET_KEY']
      def get(path)
        validate_secret_key
        uri = URI.parse(path)
        req = Net::HTTP::Get.new(uri)
        req['authorization'] = "Key #{SECRET_KEY}"
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end
        extract_response(res)
      end

      def post(path, params)
        validate_secret_key
        uri = URI.parse(path)
        req = Net::HTTP::Post.new(uri)
        req['authorization'] = "Key #{SECRET_KEY}"
        req.set_form_data(params)
        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(req)
        end
        extract_response(res)
      end

      private

      def validate_secret_key
        return unless SECRET_KEY.nil? || SECRET_KEY.strip.empty?
        raise Errors::BlankError, 'Ensure KHALTI_SECRET_KEY is not blank.'
      end

      def validate_content_type(content_type)
        return if content_type == 'application/json'
        raise Errors::InvalidResponseError, 'Content-type is not application/json.'
      end

      def extract_response(res)
        case res
        when Net::HTTPSuccess
          validate_content_type(res['content-type'])
          JSON.parse res.body
        else
          raise Errors::KhaltiError, res.message
        end
      end
    end
  end
end
