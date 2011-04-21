require "test_helper"

class SelectTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_select
    assert_equal 0, run_default_function(select_function, 1).to_i
    assert_equal 1, run_default_function(select_function, 0).to_i
  end

  def select_function
    function([:int], :int) do |f|
      f.returns(f.select(f.arg(0), int(0), int(1)))
    end
  end

end
