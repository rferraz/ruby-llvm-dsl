require "test_helper"

class CallTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_nested_call
    test_module = simple_module "test" do |m|
      m.function [], :int, :f1 do |f|
        f.returns(int(1))
      end
      m.function [], :int, :f2 do |f|
        f.returns(f.call(:f1))
      end
    end
    assert_equal 1, run_default_function(test_module).to_i
  end

  def test_recursive_call
    test_module = simple_module "test" do |m|
      m.function [:int], :int, :f1 do |f|
        f.entry { f.condition(f.icmp(:uge, f.arg(0), int(5)), :exit, :recurse) }
        f.block(:recurse) {
          f.set_bookmark(:result, f.call(:f1, f.add(f.arg(0), LLVM::Int(1))))
          f.branch(:exit)
        }
        f.exit { 
          f.returns {
            f.phi :int,
              { :on => f.arg(0), :return_from => :entry },
              { :on => f.get_bookmark(:result), :return_from => :recurse }
          }
        }
      end
    end
    assert_equal 5, run_default_function(test_module, 1).to_i
  end

  def test_external
    test_module = simple_module "test" do |m|
      m.external :abs, [:int32], :int32
      m.function [:int32], :int32 do |f|
        f.returns(f.call(:abs, f.arg(0)))
      end
    end
    assert_equal -10.abs, run_default_function(test_module, 10).to_i
  end

  def test_external_string
    test_module = simple_module "test" do |m|
      m.global :path, [:int8] * 5 do
        m.constant("PATH")
      end
      m.external :getenv, [pointer_type(:int8)], pointer_type(:int8)
      m.function [], pointer_type(:int8) do |f|
        f.returns {
          f.call(:getenv, m.get_global(:path))
        }
      end
    end
    assert_equal ENV["PATH"], run_default_function(test_module).to_ptr.read_pointer.read_string_to_null
  end
  
  def test_function_pointer
    test_module = simple_module "test" do |m|
      m.function [:int], :int, :f1 do |f|
        f.returns f.arg(0)
      end
      m.function [:int], :int, :f2 do |f|
        pointer = f.allocate(pointer_type(function_type([:int], :int)))
        f.store(m.get_function(:f1), pointer)
        pointer = f.load(pointer)
        f.returns {
          f.call(pointer, f.arg(0))
        }
      end
    end
    assert_equal 1, run_default_function(test_module, 1).to_i
  end

end
