require "test_helper"

class BranchTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_branching
    assert_equal 0, run_default_function(direct_jump_function).to_i
    assert_equal 0, run_default_function(conditional_jump_function).to_i
    assert_equal 0, run_default_function(switched_jump_function).to_i
  end

  def direct_jump_function
    function [], :int do |f|
      f.entry { f.branch(:branch_2) }
      f.block(:branch_1) { f.returns int(1) }
      f.block(:branch_2) { f.returns int(0) }
    end
  end

  def conditional_jump_function
    function [], :int do |f|
      f.entry { f.condition(f.icmp(:eq, int(1), int(2)), :branch_1, :branch_2) }
      f.block(:branch_1) { f.returns int(1) }
      f.block(:branch_2) { f.returns int(0) }
    end
  end

  def switched_jump_function
    function [], :int do |f|
      f.entry { 
        f.switch int(1), :branch_1,
          { :on => int(2), :go_to => :branch_2 },
          { :on => int(3), :go_to => :branch_3 }
      }
      f.block(:branch_1) { f.returns int(0) }
      f.block(:branch_2) { f.returns int(1) }
      f.block(:branch_3) { f.returns int(2) }
    end
  end

end
