require "active_attr"
require "httpclient"
require "json"
require "atrium/paginate"

require "atrium/account"
require "atrium/client"
require "atrium/credential"
require "atrium/error"
require "atrium/institution"
require "atrium/member"
require "atrium/transaction"
require "atrium/user"
require "atrium/version"

module Atrium
  BASE_URL_DEVELOPMENT = "https://vestibule.mx.com".freeze
  BASE_URL_PRODUCTION = "https://atrium.mx.com".freeze
  ##
  # mx-api-key and mx-client-id are required for Atrium
  #
  # Atrium.configure do |config|
  #   config.mx_api_key = generated_api_key
  #   config.mx_client_id = generated_client_id
  # end
  #
  class << self
    attr_reader :client

    # def configure
      # @client = ::Atrium::Client.new
      # yield @client
    # end

    def config(mx_api_key:, mx_client_id:, environment: 'development')
      base_url = BASE_URL_DEVELOPMENT 
      base_url = BASE_URL_PRODUCTION if environment.to_s.downcase == 'production'
      @client = ::Atrium::Client.new(mx_api_key, mx_client_id, base_url)
    end
  end
end
