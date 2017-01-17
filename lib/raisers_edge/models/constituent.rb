module RaisersEdge
  class Constituent
    include RaisersEdge::Base

    parse_root_in_json false

    def initialize(actiontype)
      super(actiontype: actiontype)
    end
  end
end
