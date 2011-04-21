require "test_helper"

class PhiTest < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_phi
    assert_equal 1, run_default_function(define_phi_function, 0).to_i
    assert_equal 0, run_default_function(define_phi_function, 1).to_i
  end

  def define_phi_function
    function [:int], :int do |f|
      f.entry { f.condition(f.icmp(:eq, f.arg(0), int(0)), :block_1, :block_2) }
      f.block(:block_1) {
        f.set_bookmark(:result_1, f.add(f.arg(0), int(1)))
        f.branch(:exit)
      }
      f.block(:block_2) {
        f.set_bookmark(:result_2, f.sub(f.arg(0), int(1)))
        f.branch(:exit)
      }
      f.exit {
        f.returns { 
          f.phi :int, 
            { :on => f.get_bookmark(:result_1), :return_from => :block_1 },
            { :on => f.get_bookmark(:result_2), :return_from => :block_2 }
        }
      }
    end
  end

end
