module BSON
  class ObjectId
    def to_json(options={})
      to_s
    end
    def as_json(options={})
      to_s
    end
    def ==(other)
      to_s == other.to_s
    end
  end
end
module Mongoid
  module Document
    def serializable_hash(options = nil)
      h = super(options)
      h['id'] = h.delete('_id') if(h.has_key?('_id'))
      h
    end
  end
end