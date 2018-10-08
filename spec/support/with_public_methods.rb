# frozen_string_literal: true

# Returns a refiner module to make target methods public
#
# @param [Array<Symbol>] methods Method symbols to be made public
# @example Make Foo#bar public
#     RSpec.describe Foo do
#       using Foo.with_public_methods(:bar)
#     end
class Module
  def with_public_methods(*method_names)
    target = self
    Module.new.tap do |refiner|
      refiner.module_eval do
        refine target do
          public(*method_names)
        end
      end
    end
  end
end
