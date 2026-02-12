/*
  Include file    BigInt.inc
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.3   -   6 Jan 2020
  Compatibility   TSE Pro v4.0 upwards

  This "include file" provides math functions for signed big integers
  for macro programmers to use in their macros.

  The math functions are divided :-) into safe functions for programmer use
  and internal functions for its own use.

  The safe functions are documented, do input validation, and provide a
  specified result.

  These are the safe functions:
    string  result = add_bigints (string term1, string term2)
    string  result = subtract_bigint_minus_bigint
                                            (string minuend, string subtrahend)
    string  result = multiply_bigints (string factor1, string factor2)
    string  result = divide_bigint_by_bigint (string dividend, string divisor)
    integer result = compare_bigints
                                  (string left_quantity, string right_quantity)

  Only the above safe functions adhere to these specifications:
    Big integers are represented as strings consisting of decimal digits,
    optional leading and trailing signs (plus and mines) and spaces,
    and optional single grouping separators between each digit.
    Valid grouping separators; comma, period, space, apostrophe, underscore.
    An even number of minus signs make a positive, an odd number a negative.
    Negative results have a single leading minus sign, non-negative results
    have no sign.
    Results have no leading zeros.
    Compare_bigints returns the integer values -1, 0, 1 respectively if the
    first parameter is smaller than, equal to, or greater than the second
    parameter, and the integer value MININT if there was an error.
    The functions with a string result return an empty string for an error.
    An error will be caused by an invalid input, by a division by zero, and by
    a result that would have been more than MAXSTRINGLEN characters long.
    Because an empty string result is an invalid input value, errors will not
    disappear unnoticed but will be propagated to following calculations.


  USAGE IN YOUR OWN CODE

  There are two ways to use the functions in this file in your own code:

  1 Include the file in your code at each compilation by adding this statement
    to the start of your own code:
      #Include ['BigInt.inc']
    The advantages are, that you can maintain your application separate of
    these math functions, and that if I release a new version of these math
    functions then you probably can simply replace this file.
    A disadvantage comes when your application becomes dependent on a version
    of the math functions file. This can happen outside of your control as a
    new version is released. There will probably be upgrade documentation,
    but it is a maintenance nightmare to burden end-users with that.

  2 Copy the whole content of the math functions file into the top of your own
    macro. If you copy it as a whole, then no compiler-errors will occur for
    functions you do not use.
    The disadvantage of this method is, that you, the macro programmer, have
    more work if a new version of the math functions file is released.
    The advantages are that your macro remains unchanged by new releases of the
    math functions file, that you decide if and when to integrate and retest it,
    and that end-users are not hassled by a programmer problem.

  My advice to macro programmers is to use the second method.

  The reason I stil also maintain and distribute the math functions in a
  separate file, is that I also a want to have a macro-independent source of
  truth for what the latest version of the math functions are.


  HISTORY

  v1.0 - 1 Jan 2020
    Initial release which implements addition and subtraction.
  v1.1 - 2 Jan 2020
    Added multiplication.
  v1.2 - 3 Jan 2020
    Added multiplication.
  v1.3 - 6 Jan 2020
    Separated the calculator and the math functions into their separate files,
    making each of them version v1.3.
    Renamed variable names to their math names.
    Documented.
*/




forward string  proc add_bigints (string term1, string term2)
forward string  proc subtract_bigint_minus_bigint (string minuend,
                                                   string subtrahend)
forward string  proc multiply_bigints (string factor1, string factor2)
forward string  proc divide_bigint_by_bigint (string dividend, string divisor)
forward integer proc compare_bigints
                                  (string left_quantity, string right_quantity)





// START OF INTERNAL FUNCTIONS - DO NOT CALL THESE

proc standardize_bigint(    string  input_bigint,
                        var string  output_positive_bigint,
                        var integer output_bigint_is_negative)
  integer i = 0
  // Remove surrounding white space and initialize the output sign as positive.
  output_positive_bigint    = Trim(input_bigint)
  output_bigint_is_negative = FALSE
  // Remove leading signs and remaining leading spaces,
  // toggling the output sign for each minus sign.
  while (output_positive_bigint[1] in '+', '-', ' ')
    if output_positive_bigint[1] == '-'
      output_bigint_is_negative = not output_bigint_is_negative
    endif
    output_positive_bigint = output_positive_bigint[2:MAXSTRINGLEN]
  endwhile
  // Remove trailing signs and remaining trailing spaces,
  // toggling the output sign for each minus sign.
  while (   output_positive_bigint[Length(output_positive_bigint)]
         in '+', '-', ' ')
    if output_positive_bigint[Length(output_positive_bigint)] == '-'
      output_bigint_is_negative = not output_bigint_is_negative
    endif
    output_positive_bigint =
      output_positive_bigint[1: Length(output_positive_bigint) - 1]
  endwhile
  // Delete group separators, like thousands separators, but deleting them
  // anywhere between two digits to account for all countries and styles.
  // Any decimal separators (commas or points) are not recognized as such and
  // are deleted when they resemble group separators.
  i = 2
  while i < Length(output_positive_bigint)
    if  (output_positive_bigint[i    ] in ',', '.', ' ', "'", '_')
    and (output_positive_bigint[i - 1] in '0' .. '9'             )
    and (output_positive_bigint[i + 1] in '0' .. '9'             )
      output_positive_bigint = output_positive_bigint[1     : i - 1       ]
                             + output_positive_bigint[i + 1 : MAXSTRINGLEN]
    else
      i = i + 1
    endif
  endwhile
  // Set output to an empty string if an illegal character is found.
  for i = 1 to Length(output_positive_bigint)
    if not (output_positive_bigint[i] in '0' .. '9')
      output_positive_bigint = ''
      break
    endif
  endfor
  // Remove leading zeros except the last one if the output value is zero.
  while output_positive_bigint[1] == '0'
  and   Length(output_positive_bigint) > 1
    output_positive_bigint = output_positive_bigint[2:MAXSTRINGLEN]
  endwhile
  // If the output value is zero, then make it not negative.
  if output_positive_bigint == '0'
    output_bigint_is_negative = FALSE
  endif
end standardize_bigint

integer proc compare_positive_bigints(string left_quantity, string right_quantity)
  integer result = 0
  if Length(left_quantity) > Length(right_quantity)
    result = 1
  elseif Length(left_quantity) < Length(right_quantity)
    result = -1
  elseif left_quantity > right_quantity
    result = 1
  elseif left_quantity < right_quantity
    result = -1
  endif
  return(result)
end compare_positive_bigints

string proc add_positive_bigints(string p_term1, string p_term2)
  integer carry                       = 0
  integer i                           = 0
  integer last_digit                  = 0
  integer len                         = 0
  integer sum_of_two_digits_and_carry = 0
  string  term1        [MAXSTRINGLEN] = p_term1
  string  term2        [MAXSTRINGLEN] = p_term2
  string  total_sum    [MAXSTRINGLEN] = ''
  if  p_term1 <> ''
  and p_term2 <> ''
    if Length(term1) > Length(term2)
      len   = Length(term1)
      term2 = Format(term2:len:'0')
    else
      len   = Length(term2)
      term1 = Format(term1:len:'0')
    endif
    for i = len downto 1
      sum_of_two_digits_and_carry = Val(term1[i]) + Val(term2[i]) + carry
      last_digit                  = sum_of_two_digits_and_carry mod 10
      carry                       = sum_of_two_digits_and_carry  /  10
      total_sum                   = Str(last_digit) + total_sum
    endfor
    if carry
      if Length(total_sum) == MAXSTRINGLEN
        total_sum = ''
      else
        total_sum = Str(carry) + total_sum
      endif
    endif
  endif
  return(total_sum)
end add_positive_bigints

string proc subtract_positive_larger_minus_smaller_bigint(string p_minuend,
                                                          string p_subtrahend)
  string  minuend      [MAXSTRINGLEN] = p_minuend
  string  subtrahend      [MAXSTRINGLEN] = p_subtrahend
  integer i                     = 0
  integer j                     = 0
  integer len                   = 0
  integer keep_borrowing        = FALSE
  string  difference [MAXSTRINGLEN] = ''
  if  p_minuend    <> ''
  and p_subtrahend <> ''
    if Length(minuend) > Length(subtrahend)
      len        = Length(minuend)
      subtrahend = Format(subtrahend:len:'0')
    else
      len     = Length(subtrahend)
      minuend = Format(minuend:len:'0')
    endif
    for i = len downto 1 by 1
      if     minuend[i] > subtrahend[i]
        difference     = Str(Val(minuend[i]) - Val(subtrahend[i]))
                       + difference
      elseif minuend[i] < subtrahend[i]
        difference     = Str(Val(minuend[i]) + 10 - Val(subtrahend[i]))
                       + difference
        j              = i - 1
        keep_borrowing = TRUE
        while j > 0
        and   keep_borrowing
          if minuend[j] == '0'
            minuend[j]     = '9'
          else
            minuend[j]     = Str(Val(minuend[j]) - 1)
            keep_borrowing = FALSE
          endif
          j = j - 1
        endwhile
      else
        difference = '0' + difference
      endif
    endfor
    while difference[1]     == '0'
    and   Length(difference) >  1
      difference = difference[2:MAXSTRINGLEN]
    endwhile
  endif
  return(difference)
end subtract_positive_larger_minus_smaller_bigint

/*
  For multiplying I use an algorith of my own that keeps intermediate results
  small. This turns out to be ideal for TSE's small integer size.

  It is based on this principle:
  Call each right-most digit a ones-digit, each digit to the left of that a
  tens-digit, each digit to the left of that a hundreds-digit, etcetera.
  For this example assume two three-digit factors to multiply to a product.
  The ones-digit of the product is only determined by the multiplication of the
  ones-digits of the two factors, and also results in a carry.
  The tens-digit of the product is determined by adding the carry plus the
  multiplications of the ones-digits of one factor with the tens-digits
  of the other factor, again resulting in a new carry.
  The hundreds-digit of the product is determined by adding the carry plus the
  multiplications of the ones-digits of one factor with the hundreds-digits
  of the other factor plus the multiplication of the tens-digits of both
  factors, again resulting in a new carry.
  The thousands-digit of the product is determined by adding the carry plus the
  multiplications of the tens-digit of one factor with the hundreds-digit of
  the other factor, again resulting in a new carry.
  The ten-thousands-digit of the product is determined by adding the carry plus
  the multiplication of the hundreds-digits of the factors, again resulting in
  a new carry.
  The hundred-thousands-digit of the product is determined by the final carry.

  For example
      123
      456 *
      ---
    56088
  can be calculated as follows
        6 * 3                 = 8 carry 1
    1 + 6 * 2 + 5 * 3         = 8 carry 2
    2 + 6 * 1 + 5 * 2 + 4 * 3 = 0 carry 3
    3 + 5 * 1 + 4 * 2         = 6 carry 1
    1 + 4 * 1                 = 5 carry 0
*/

string proc multiply_positive_bigints(string p_factor1, string p_factor2)
  integer carry                  = 0
  string  factor1 [MAXSTRINGLEN] = p_factor1
  string  factor2 [MAXSTRINGLEN] = p_factor2
  integer factors_left_pos       = 0
  integer factors_right_pos      = 0
  integer factor1_pos            = 0
  integer factor2_pos            = 0
  integer len                    = 0
  string  product [MAXSTRINGLEN] = ''
  integer product_pos_digit      = 0
  integer product_pos_product    = 0
  integer size_error             = FALSE
  if Length(factor1) > Length(factor2)
    len     = Length(factor1)
    factor2 = Format(factor2:len:'0')
  else
    len     = Length(factor2)
    factor1 = Format(factor1:len:'0')
  endif
  factors_left_pos = len
  for factors_right_pos = len downto 1 by 1
    for factors_left_pos = factors_left_pos downto 1
      if Length(product) == MAXSTRINGLEN
        size_error = TRUE
      else
        product_pos_product = 0
        for factor1_pos = factors_right_pos downto factors_left_pos
          factor2_pos         = factors_left_pos
                              + (factors_right_pos - factor1_pos)
          product_pos_product = product_pos_product
                              + Val(factor1[factor1_pos])
                              * Val(factor2[factor2_pos])
        endfor
        product_pos_product = product_pos_product + carry
        carry               = product_pos_product / 10
        product_pos_digit   = product_pos_product mod 10
        product             = Str(product_pos_digit) + product
      endif
    endfor
    factors_left_pos = 1
  endfor
  if carry
    if Length(product) == MAXSTRINGLEN
      size_error = TRUE
    else
      product = Str(carry) + product
    endif
  endif
  if size_error
    product = ''
  endif
  while product[1]     == '0'
  and   Length(product) >  1
    product = product[2:MAXSTRINGLEN]
  endwhile
  return(product)
end multiply_positive_bigints

/*
  The algorithm used is ordinary long division.
  Division is an expensive operation.
  A small performance improvement is realized by storing the results of some
  multiplications that are likely to recur for the same division.
*/

string bigint_pre_multiplied_divisor [MAXSTRINGLEN] = ''
string bigint_divisor_times_0        [MAXSTRINGLEN] = ''
string bigint_divisor_times_1        [MAXSTRINGLEN] = ''
string bigint_divisor_times_2        [MAXSTRINGLEN] = ''
string bigint_divisor_times_3        [MAXSTRINGLEN] = ''
string bigint_divisor_times_4        [MAXSTRINGLEN] = ''
string bigint_divisor_times_5        [MAXSTRINGLEN] = ''
string bigint_divisor_times_6        [MAXSTRINGLEN] = ''
string bigint_divisor_times_7        [MAXSTRINGLEN] = ''
string bigint_divisor_times_8        [MAXSTRINGLEN] = ''
string bigint_divisor_times_9        [MAXSTRINGLEN] = ''
string bigint_divisor_times_10       [MAXSTRINGLEN] = ''

string proc get_bigint_divisor_product(string  p_divisor,
                                       integer p_number_of_times)
  string product [MAXSTRINGLEN] = ''
  if p_divisor <> bigint_pre_multiplied_divisor
    bigint_pre_multiplied_divisor = p_divisor
    bigint_divisor_times_0        = '0'
    bigint_divisor_times_1        = p_divisor
    bigint_divisor_times_2        = ''
    bigint_divisor_times_3        = ''
    bigint_divisor_times_4        = ''
    bigint_divisor_times_5        = ''
    bigint_divisor_times_6        = ''
    bigint_divisor_times_7        = ''
    bigint_divisor_times_8        = ''
    bigint_divisor_times_9        = ''
    if Length(p_divisor) <> MAXSTRINGLEN
      bigint_divisor_times_10     = p_divisor + '0'
    endif
  endif
  case p_number_of_times
    when  0 product = bigint_divisor_times_0
    when  1 product = bigint_divisor_times_1
    when  2 product = bigint_divisor_times_2
    when  3 product = bigint_divisor_times_3
    when  4 product = bigint_divisor_times_4
    when  5 product = bigint_divisor_times_5
    when  6 product = bigint_divisor_times_6
    when  7 product = bigint_divisor_times_7
    when  8 product = bigint_divisor_times_8
    when  9 product = bigint_divisor_times_9
    when 10 product = bigint_divisor_times_10
  endcase
  if product == ''
    product = multiply_positive_bigints(p_divisor, Str(p_number_of_times))
    case p_number_of_times
      when  0 bigint_divisor_times_0  = product
      when  1 bigint_divisor_times_1  = product
      when  2 bigint_divisor_times_2  = product
      when  3 bigint_divisor_times_3  = product
      when  4 bigint_divisor_times_4  = product
      when  5 bigint_divisor_times_5  = product
      when  6 bigint_divisor_times_6  = product
      when  7 bigint_divisor_times_7  = product
      when  8 bigint_divisor_times_8  = product
      when  9 bigint_divisor_times_9  = product
      when 10 bigint_divisor_times_10 = product
    endcase
  endif
  return(product)
end get_bigint_divisor_product

string proc divide_positive_bigint_by_bigint(string p_dividend,
                                             string p_divisor)
  integer dividend_digit_index                     = 0
  string  dividend_part        [MAXSTRINGLEN] = ''
  string  divisor_product      [MAXSTRINGLEN] = ''
  integer number_of_times                     = 0
  string  prev_divisor_product [MAXSTRINGLEN] = ''
  string  quotient             [MAXSTRINGLEN] = ''
  for dividend_digit_index = 1 to Length(p_dividend)
    dividend_part   = iif(dividend_part == '0', '', dividend_part)
                    + p_dividend[dividend_digit_index]
    number_of_times =  0
    divisor_product = '0'
    repeat
      number_of_times      = number_of_times + 1
      prev_divisor_product = divisor_product
      divisor_product      = get_bigint_divisor_product(p_divisor,
                                                        number_of_times)
    until number_of_times                                          == 10
       or compare_positive_bigints(divisor_product, dividend_part) ==  1
    dividend_part = subtract_positive_larger_minus_smaller_bigint(
                                          dividend_part, prev_divisor_product)
    quotient      = quotient + Str(number_of_times - 1)
  endfor
  while quotient[1]     == '0'
  and   Length(quotient) >  1
    quotient = quotient[2:MAXSTRINGLEN]
  endwhile
  return(quotient)
end divide_positive_bigint_by_bigint

proc bigint_compiler_pacifier()
  integer i    = 0
  string  s[1] = ''
  if FALSE
    bigint_compiler_pacifier()
    standardize_bigint(s, s, i)
    compare_positive_bigints(s, s)
    add_positive_bigints(s, s)
    subtract_positive_larger_minus_smaller_bigint(s, s)
    multiply_positive_bigints(s, s)
    get_bigint_divisor_product(s, i)
    divide_positive_bigint_by_bigint(s, s)

    add_bigints(s, s)
    subtract_bigint_minus_bigint(s, s)
    multiply_bigints(s, s)
    divide_bigint_by_bigint(s, s)
    compare_bigints(s, s)
  endif
end bigint_compiler_pacifier

// END OF INTERNAL FUNCTIONS - DO NOT CALL THESE





// START OF SAFE FUNCTIONS - THESE CAN BE CALLED BY YOUR OWN CODE

string proc add_bigints(string p_term1, string p_term2)
  string  sum   [MAXSTRINGLEN] = ''
  string  term1 [MAXSTRINGLEN] = ''
  integer term1_is_negative    = FALSE
  string  term2 [MAXSTRINGLEN] = ''
  integer term2_is_negative    = FALSE
  standardize_bigint(p_term1, term1, term1_is_negative)
  standardize_bigint(p_term2, term2, term2_is_negative)
  if  term1 <> ''
  and term2 <> ''
    if term1_is_negative == term2_is_negative
      sum = add_positive_bigints(term1, term2)
      if  sum <> ''
      and term1_is_negative
        sum = iif(Length(sum) == MAXSTRINGLEN, '', '-' + sum)
      endif
    else
      case compare_positive_bigints(term1, term2)
        when 0
          sum = '0'
        when -1
          sum = subtract_positive_larger_minus_smaller_bigint(term2, term1)
          if  sum <> ''
          and term2_is_negative
            sum = iif(Length(sum) == MAXSTRINGLEN, '', '-' + sum)
          endif
        when 1
          sum = subtract_positive_larger_minus_smaller_bigint(term1, term2)
          if  sum <> ''
          and term1_is_negative
            sum = iif(Length(sum) == MAXSTRINGLEN, '', '-' + sum)
          endif
      endcase
    endif
  endif
  return(sum)
end add_bigints

string proc subtract_bigint_minus_bigint(string p_minuend, string p_subtrahend)
  string  difference [MAXSTRINGLEN] = ''
  string  minuend    [MAXSTRINGLEN] = ''
  integer minuend_is_negative       = FALSE
  string  subtrahend [MAXSTRINGLEN] = ''
  integer subtrahend_is_negative    = FALSE
  standardize_bigint(p_minuend   , minuend   ,    minuend_is_negative)
  standardize_bigint(p_subtrahend, subtrahend, subtrahend_is_negative)
  if  minuend    <> ''
  and subtrahend <> ''
    if Length(Trim(subtrahend)) == MAXSTRINGLEN
      difference = ''
    else
      difference = add_bigints(minuend, '-' + subtrahend)
    endif
  endif
  return(difference)
end subtract_bigint_minus_bigint

string proc multiply_bigints(string p_factor1, string p_factor2)
  string  factor1 [MAXSTRINGLEN] = ''
  integer factor1_is_negative    = FALSE
  string  factor2 [MAXSTRINGLEN] = ''
  integer factor2_is_negative    = FALSE
  string  product [MAXSTRINGLEN] = ''
  standardize_bigint(p_factor1, factor1, factor1_is_negative)
  standardize_bigint(p_factor2, factor2, factor2_is_negative)
  if  factor1 <> ''
  and factor2 <> ''
    product = multiply_positive_bigints(factor1, factor2)
    if  product             <> ''
    and factor1_is_negative <> factor2_is_negative
      product = iif(Length(product) == MAXSTRINGLEN, '', '-' + product)
    endif
  endif
  return(product)
end multiply_bigints

string proc divide_bigint_by_bigint(string p_dividend, string p_divisor)
  string  dividend [MAXSTRINGLEN] = ''
  integer dividend_is_negative    = FALSE
  string  divisor  [MAXSTRINGLEN] = ''
  integer divisor_is_negative     = FALSE
  string  quotient [MAXSTRINGLEN] = ''
  standardize_bigint(p_dividend, dividend, dividend_is_negative)
  standardize_bigint(p_divisor , divisor , divisor_is_negative )
  if  dividend <> ''
  and divisor  <> ''
  and divisor  <> '0'
    quotient = divide_positive_bigint_by_bigint(dividend, divisor)
    if  quotient             <> ''
    and dividend_is_negative <> divisor_is_negative
      quotient = iif(Length(quotient) == MAXSTRINGLEN, '', '-' + quotient)
      quotient = iif(quotient == '-0', '0', quotient)
    endif
  endif
  return(quotient)
end divide_bigint_by_bigint

integer proc compare_bigints(string p_left_quantity, string p_right_quantity)
  integer comparison                    = MININT
  string  left_quantity  [MAXSTRINGLEN] = ''
  integer left_quantity_is_negative     = FALSE
  string  right_quantity [MAXSTRINGLEN] = ''
  integer right_quantity_is_negative    = FALSE
  standardize_bigint(p_left_quantity , left_quantity , left_quantity_is_negative )
  standardize_bigint(p_right_quantity, right_quantity, right_quantity_is_negative)
  if  left_quantity  <> ''
  and right_quantity <> ''
    if left_quantity_is_negative == right_quantity_is_negative
      comparison = compare_positive_bigints(left_quantity, right_quantity)
      comparison = iif(left_quantity_is_negative, comparison * -1, comparison)
    else
      comparison = iif(left_quantity_is_negative, -1, 1)
    endif
  endif
  return(comparison)
end compare_bigints

// END OF SAFE FUNCTIONS - THESE CAN BE CALLED BY YOUR OWN CODE



