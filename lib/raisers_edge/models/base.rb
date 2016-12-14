module RaisersEdge
  module Base
    def self.included(base)
      base.include Her::Model
      base.extend ClassMethods
      base.send(:use_api, -> {RaisersEdge.configuration.connection})
    end

    module ClassMethods

    end

  end
end