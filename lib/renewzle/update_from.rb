module Renewzle
  module UpdateFrom
    def update_from(params)
      self.attributes = params
      save!
    end
  end
end