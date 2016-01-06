# This module contains the methods necessary to perform the logical operations
# on various 32-bit words.
module WordOperations
  def circular_left_shift(binary, n)
    binary.chars.rotate!(n).join
  end

  def bitwise_exclusive_or(arr)
    num_bits = (arr.first||"").length
    result   = arr.inject(0) { |result, binary| result ^ binary.to_i(2) }
    pad_front_with_zeros num_bits, result.to_s(2)
  end

  def bitwise_and(a, b)
    str = (a.to_i(2) & b.to_i(2)).to_s(2)
    pad_front_with_zeros(a.length, str)
  end

  def bitwise_complement(binary)
    binary.chars.map { |n| flip_zero_and_one(n) }.join
  end

  def flip_zero_and_one(n)
    n == '0' ? 1 : 0
  end

  def addition_modulo_2(integers)
    binary = (integers.reduce(:+) % (2**32)).to_s(2)
    pad_front_with_zeros(32, binary)
  end

  def pad_front_with_zeros(length, str)
    str.rjust(length, '0')
  end
end
