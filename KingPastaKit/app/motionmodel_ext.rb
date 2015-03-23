module MotionModel
  module ArrayModelAdapter
    module PublicClassMethods
      alias_method :array, :all
    end
  end

  class ArrayFinderQuery
    alias_method :array, :all
  end

  module Model
    def try(*a, &b)
      if a.empty? && block_given?
        yield self
      else
        public_send(*a, &b) if respond_to?(a.first)
      end
    end
  end
end

# def count
#   self.array.count
# end