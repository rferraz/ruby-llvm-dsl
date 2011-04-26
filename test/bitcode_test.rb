require "test_helper"
require "tempfile"

class BitcodeTestCase < Test::Unit::TestCase
  
  def setup
    LLVM.init_x86
  end
  
  def test_bitcode
    test_module = simple_module "test" do |m|
      m.function [], :int, :f1 do |f|
        f.returns(int(1))
      end
    end
    Tempfile.open("bitcode") do |tmp|
      assert test_module.write_bitcode(tmp)
      new_module = LLVM::Module.parse_bitcode(tmp.path)
      result = run_function_on_module(new_module, new_module.functions.first).to_i
      assert_equal 1, result
    end
  end
end
