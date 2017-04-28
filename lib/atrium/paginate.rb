require "uri"

module Atrium
  module Paginate
    DEFAULT_RECORDS_PER_PAGE = 100
    INITIAL_PAGE = 1

    attr_accessor :current_page, :endpoint, :total_pages

    def endpoint_name(url: nil, query_params: nil)
      @endpoint = if query_params.present?
        url + "?" + URI.encode_www_form(query_params) + "&"
      else
        url + "?"
      end
    end

    def get_total_pages
      @current_page = INITIAL_PAGE

      paginated_endpoint = endpoint + "page=#{current_page}&records_per_page=#{records_per_page}"
      response = ::Atrium.client.make_request(:get, paginated_endpoint)

      pagination = response["pagination"]
      @total_pages  = pagination["total_pages"]
    end

    def simple_class_name
      @simple_class_name ||= self.name.gsub("Atrium::", "").downcase.pluralize
    end

    def class_name
      @class_name ||= self
    end

    def paginate_endpoint(url: nil, class_name: nil, query_params: nil, limit: nil)
      unless url
        raise "url is required"
      end
      
      if class_name
        @simple_class_name = class_name.name.gsub("Atrium::", "").downcase.pluralize
        @class_name = class_name
      end
      
      endpoint_name(url: url, query_params: query_params)
      get_total_pages
      response_list(limit: limit)
    end

    def paginate_endpoint_in_batches(query_params: nil, limit: nil, &block)
      return "method requires block to be passed" unless block_given?

      endpoint_name(query_params: query_params)
      get_total_pages
      response_list_in_batches(limit: limit, &block)
    end

    def records_per_page
      @records_per_page ||= DEFAULT_RECORDS_PER_PAGE
    end

    def response_list(limit: nil)
      # "total_pages > 1" check exists since some query_params only return 1 page
      @total_pages = limit / records_per_page if limit.present? && total_pages > 1
      list = []

      until current_page > total_pages
        paginated_endpoint =  endpoint + "page=#{current_page}&records_per_page=#{records_per_page}"
        response = ::Atrium.client.make_request(:get, paginated_endpoint)
        # Add new objects to the list
        response["#{simple_class_name}"].each do |params|
          list << class_name.new(params)
        end
        @current_page += 1
      end
      list
    end

    def response_list_in_batches(limit: nil, &block)
      # "total_pages > 1" check exists since some query_params only return 1 page
      @total_pages = limit / records_per_page if limit.present? && total_pages > 1

      until current_page > total_pages
        paginated_endpoint =  endpoint + "page=#{current_page}&records_per_page=#{records_per_page}"
        response = ::Atrium.client.make_request(:get, paginated_endpoint)
        list = []

        response["#{simple_class_name}"].each do |params|
          list << self.new(params)
        end
        @current_page += 1
        yield list
      end
    end
  end
end
