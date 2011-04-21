require "test_helper"

class VectorTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_vector_elements
    assert_equal 2 + 3, run_default_function(vector_elements, 2, 3).to_i
  end

  def test_vector_shuffle
    assert_equal 1 + 4, run_default_function(vector_shuffle, 1, 2, 3, 4).to_i
  end

  def vector_elements
    function [:int, :int], :int do |f|
      pointer = f.load(f.allocate(vector_type(:int, 2)))
      pointer = f.insert_element(pointer, f.arg(0), 0)
      pointer = f.insert_element(pointer, f.arg(1), 1)
      f.returns {
        f.add(f.extract_element(pointer, 0),
              f.extract_element(pointer, 1))
      }
    end
  end

  def vector_shuffle(*values)
    function [:int, :int, :int, :int], :int do |f|
      vector1 = f.load(f.allocate(vector_type(:int, 2)))
      vector1 = f.insert_element(vector1, f.arg(0), 0)
      vector1 = f.insert_element(vector1, f.arg(1), 1)
      vector2 = f.load(f.allocate(vector_type(:int, 2)))
      vector2 = f.insert_element(vector2, f.arg(2), 0)
      vector2 = f.insert_element(vector2, f.arg(3), 1)
      vector3 = f.shuffle_vector(vector1, vector2, LLVM::ConstantVector.const([int(0), int(3)]))
      f.returns {
        f.add(f.extract_element(vector3, 0),
              f.extract_element(vector3, 1))
      }
    end
  end

end
