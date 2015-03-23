module MotionModel
  module ArrayModelAdapter
    module PublicClassMethods
      alias_method :array, :all
    end
  end

  class ArrayFinderQuery
    alias_method :array, :all
  end
end

# def count
#   self.array.count
# end