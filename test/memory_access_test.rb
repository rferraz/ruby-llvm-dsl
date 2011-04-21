require "test_helper"

class MemoryAccessTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_memory_access
    assert_equal 1 + 2, run_default_function(simple_heap_memory_access_function, 1, 2).to_i
    assert_equal 3 + 4, run_default_function(array_memory_access_function, 3, 5, 4).to_i
    assert_in_delta 1.3 + 2.9, run_default_function(simple_memory_access_function, 1.3, 2.9).to_f, 0.001
  end

  def simple_heap_memory_access_function
    function [:int, :int], :int do |f|
      p1, p2 = f.allocate(:int), f.allocate(:int)
      f.store(f.arg(0), p1)
      f.store(f.arg(1), p2)
      f.returns { 
        f.add(f.load(p1), f.load(p2))
      }
    end
  end

  def simple_memory_access_function
    simple_module "test" do |m|
      m.external "malloc", [:int], pointer_type(:int8)
      m.external "free", [pointer_type(:void)], :void
      m.function [:float, :float], :float do |f|
        p1 = f.cast(f.call("malloc", int(4)), pointer_type(:float))
        p2 = f.cast(f.call("malloc", int(4)), pointer_type(:float))
        f.store(f.arg(0), p1)
        f.store(f.arg(1), p2)
        f.returns { 
          fa = f.load(p1)
          fb = f.load(p2)
          f.call("free", p1)
          f.call("free", p2)
          f.fadd(fa, fb)
        }
      end
    end
  end

  def array_memory_access_function
    function [:int, :int, :int], :int do |f|
      pointer = f.allocate(:int, :size => 3)
      f.store(f.arg(0), f.gep(pointer, int(0)))
      f.store(f.arg(1), f.gep(pointer, int(1)))
      f.store(f.arg(2), f.gep(pointer, int(2)))
      f.returns {
        f.add(f.load(f.gep(pointer, int(0))),
              f.load(f.gep(pointer, int(2))))
      }
    end
  end

end
