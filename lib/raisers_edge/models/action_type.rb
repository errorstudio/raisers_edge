module RaisersEdge
  class ActionType
    include RaisersEdge::Base
    parse_root_in_json false
    # https://api.sky.blackbaud.com/constituent/v1/actiontypes
    collection_path "/constituent/v1/actiontypes"

    def initialize(actiontype)
      super(actiontype: actiontype)
    end
  end
end
