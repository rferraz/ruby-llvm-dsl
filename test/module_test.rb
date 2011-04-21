require "test_helper"

class ModuleTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_simple_module
    assert_equal 1, run_default_function(define_simple_function).to_i
  end

  def define_simple_function
    simple_function :int do |f|
      f.returns int(1)
    end
  end
  
  def test_multiple_definition
    test_module = simple_module "test" do |m|
      m.function [], :int, :f1
      m.function [], :int, :f2
      m.function [], :int, :f1 do |f|
        f.returns(int(1))
      end
      m.function [], :int, :f2 do |f|
        f.returns(f.call(:f1))
      end
      m.with(:f1) { }
      m.with(:f2) { }
    end
    assert_equal 1, run_default_function(test_module).to_i
  end

end
