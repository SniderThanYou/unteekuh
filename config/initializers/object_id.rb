module BSON
  class ObjectId
    def to_json(options={})
      to_s
    end
    def as_json(options={})
      to_s
    end
  end
end
module Mongoid
  module Document
    def as_json(options={})
      attrs = super(options)
      attrs['id'] = self.persisted? ? self.id.to_s : nil
      attrs
    end
    def to_json(options={})
      attrs = super(options)
      attrs['id'] = self.persisted? ? self.id.to_s : nil
      attrs
    end
  end
end