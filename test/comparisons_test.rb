require "test_helper"

class ComparisonsTestCase < Test::Unit::TestCase

  def setup
    LLVM.init_x86
  end

  def test_integer_comparison
    integer_comparison_assertion(:eq, 1, 1, LLVM_SIGNED, true)
    integer_comparison_assertion(:ne, 1, 1, LLVM_SIGNED, false)
    integer_comparison_assertion(:ugt, 2, 2, LLVM_UNSIGNED, false)
    integer_comparison_assertion(:uge, 2, 1, LLVM_UNSIGNED, true)
    integer_comparison_assertion(:ult, 1, 1, LLVM_UNSIGNED, false)
    integer_comparison_assertion(:ule, 1, 2, LLVM_UNSIGNED, true)
    integer_comparison_assertion(:sgt, -2, 2, LLVM_SIGNED, false)
    integer_comparison_assertion(:sge, -2, 1, LLVM_SIGNED, false)
    integer_comparison_assertion(:slt, -1, 2, LLVM_SIGNED, true)
    integer_comparison_assertion(:sle, -1, 2, LLVM_SIGNED, true)
  end

  def test_float_comparison
    float_comparison_assertion(:oeq, 1.0, 1.0, true)
    float_comparison_assertion(:one, 1.0, 1.0, false)
    float_comparison_assertion(:ogt, 2.0, 2.0, false)
    float_comparison_assertion(:oge, 2.0, 1.0, true)
    float_comparison_assertion(:olt, 1.0, 1.0, false)
    float_comparison_assertion(:ole, 1.0, 2.0, true)
    float_comparison_assertion(:ord, 1.0, 2.0, true)
    float_comparison_assertion(:ueq, 1.0, 1.0, true)
    float_comparison_assertion(:une, 1.0, 1.0, false)
    float_comparison_assertion(:ugt, 2.0, 2.0, false)
    float_comparison_assertion(:uge, 2.0, 1.0, true)
    float_comparison_assertion(:ult, 1.0, 1.0, false)
    float_comparison_assertion(:ule, 1.0, 2.0, true)
    float_comparison_assertion(:uno, 1.0, 2.0, false)
  end

  def integer_comparison_assertion(operation, operand1, operand2, signed, expected_result)
    result = run_comparison_operation(:icmp, operation, int(operand1, :signed => signed), int(operand2, :signed => signed), :bool).to_b
    assert_equal expected_result, result
  end

  def float_comparison_assertion(operation, operand1, operand2, expected_result)
    result = run_comparison_operation(:fcmp, operation, float(operand1), float(operand2), :bool).to_b
    assert_equal expected_result, result
  end

  def run_comparison_operation(comparison_operation, comparison_operator,
                               operand1, operand2, return_type)
     run_default_function(simple_function(return_type) do |f|
       f.returns(f.send(comparison_operation, comparison_operator, operand1, operand2))
     end)
  end

end
