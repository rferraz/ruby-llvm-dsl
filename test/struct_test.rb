require "test_helper"

class StructTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_struct_values
    assert_equal 2 + 3, run_default_function(struct_values, 2, 3).to_i
  end

  def test_struct_access
    assert_in_delta 2 + 3.3, run_default_function(struct_access(:float), 2, 3.3).to_f, 0.001
  end

  def struct_values
    function [:int, :int], :int do |f|
      struct = f.load(f.allocate(struct_type(:int, :int)))
      struct = f.insert_value(struct, f.arg(0), 0)
      struct = f.insert_value(struct, f.arg(1), 1)
      f.returns {
        f.add(f.extract_value(struct, 0),
              f.extract_value(struct, 1))
      }
    end
  end

  def struct_access(return_type)
    function [:int, :float], return_type do |f|
      struct = f.allocate(struct_type(:float, struct_type(:int, :float), :int))
      f.store(f.arg(0), f.gep(struct, int(0), int(1, :size => 32), int(0, :size => 32)))
      f.store(f.arg(1), f.gep(struct, int(0), int(1, :size => 32), int(1, :size => 32)))
      p1 = f.gep(struct, int(0), int(1, :size => 32), int(0, :size => 32))
      p2 = f.gep(struct, int(0), int(1, :size => 32), int(1, :size => 32))
      f.returns {
        f.fadd(f.ui2fp(f.load(p1), type_by_name(return_type)),
               f.load(p2))
      }
    end
  end

end
