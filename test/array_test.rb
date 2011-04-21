require "test_helper"

class ArrayTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_array_values
    assert_equal 2 + 3, run_default_function(array_values, 2, 3).to_i
  end

  def array_values
    function [:int, :int], :int do |f|
      pointer = f.load(f.allocate([:int] * 2))
      pointer = f.insert_value(pointer, f.arg(0), 0)
      pointer = f.insert_value(pointer, f.arg(1), 1)
      f.returns {
        f.add(f.extract_value(pointer, 0),
              f.extract_value(pointer, 1))
      }
    end
  end

end
