integer total_1 = 0
integer total_2 = 0
integer total_3 = 0
integer total_4 = 0
integer total_5 = 0
integer fmn_1 = 0
integer fmn_2 = 0
integer fmn_3 = 0
integer fmn_4 = 0
integer fmn_5 = 0
integer term_1 = 0
integer term_2 = 0
integer term_3 = 0
integer term_4 = 0
integer term_5 = 0
proc TermSet(integer v)
 term_1 = v
 term_2 = 0
 term_3 = 0
 term_4 = 0
 term_5 = 0
end
proc TermMul(integer v)
 integer carry = 0
 integer prod = 0
 if v == 1
  return()
 endif
 prod = (term_1 * v) + carry
 term_1 = prod MOD 10000
 carry = prod / 10000
 prod = (term_2 * v) + carry
 term_2 = prod MOD 10000
 carry = prod / 10000
 prod = (term_3 * v) + carry
 term_3 = prod MOD 10000
 carry = prod / 10000
 prod = (term_4 * v) + carry
 term_4 = prod MOD 10000
 carry = prod / 10000
 prod = (term_5 * v) + carry
 term_5 = prod MOD 10000
 carry = prod / 10000
end
proc TermDiv(integer v)
 integer rem = 0
 integer curr = 0
 if v == 1
  return()
 endif
 curr = term_5 + (rem * 10000)
 term_5 = curr / v
 rem = curr MOD v
 curr = term_4 + (rem * 10000)
 term_4 = curr / v
 rem = curr MOD v
 curr = term_3 + (rem * 10000)
 term_3 = curr / v
 rem = curr MOD v
 curr = term_2 + (rem * 10000)
 term_2 = curr / v
 rem = curr MOD v
 curr = term_1 + (rem * 10000)
 term_1 = curr / v
 rem = curr MOD v
end
proc FmnClear()
 fmn_1 = 0
 fmn_2 = 0
 fmn_3 = 0
 fmn_4 = 0
 fmn_5 = 0
end
proc FmnAddTerm()
 integer carry = 0
 integer sum = 0
 sum = fmn_1 + term_1 + carry
 fmn_1 = sum MOD 10000
 carry = sum / 10000
 sum = fmn_2 + term_2 + carry
 fmn_2 = sum MOD 10000
 carry = sum / 10000
 sum = fmn_3 + term_3 + carry
 fmn_3 = sum MOD 10000
 carry = sum / 10000
 sum = fmn_4 + term_4 + carry
 fmn_4 = sum MOD 10000
 carry = sum / 10000
 sum = fmn_5 + term_5 + carry
 fmn_5 = sum MOD 10000
 carry = sum / 10000
end
proc FmnDiv(integer v)
 integer rem = 0
 integer curr = 0
 if v == 1
  return()
 endif
 curr = fmn_5 + (rem * 10000)
 fmn_5 = curr / v
 rem = curr MOD v
 curr = fmn_4 + (rem * 10000)
 fmn_4 = curr / v
 rem = curr MOD v
 curr = fmn_3 + (rem * 10000)
 fmn_3 = curr / v
 rem = curr MOD v
 curr = fmn_2 + (rem * 10000)
 fmn_2 = curr / v
 rem = curr MOD v
 curr = fmn_1 + (rem * 10000)
 fmn_1 = curr / v
 rem = curr MOD v
end
proc TotalAddFmn()
 integer carry = 0
 integer sum = 0
 sum = total_1 + fmn_1 + carry
 total_1 = sum MOD 10000
 carry = sum / 10000
 sum = total_2 + fmn_2 + carry
 total_2 = sum MOD 10000
 carry = sum / 10000
 sum = total_3 + fmn_3 + carry
 total_3 = sum MOD 10000
 carry = sum / 10000
 sum = total_4 + fmn_4 + carry
 total_4 = sum MOD 10000
 carry = sum / 10000
 sum = total_5 + fmn_5 + carry
 total_5 = sum MOD 10000
 carry = sum / 10000
end
string proc PadChunk(integer c)
 string s[4] = ""
 s = Format(c)
 while Length(s) < 4
  s = "0" + s
 endwhile
 return(s)
end
string proc TotalToStr()
 string s[255] = ""
 if total_5 > 0
  s = Format(total_5) + PadChunk(total_4) + PadChunk(total_3) + PadChunk(total_2) + PadChunk(total_1)
 elseif total_4 > 0
  s = Format(total_4) + PadChunk(total_3) + PadChunk(total_2) + PadChunk(total_1)
 elseif total_3 > 0
  s = Format(total_3) + PadChunk(total_2) + PadChunk(total_1)
 elseif total_2 > 0
  s = Format(total_2) + PadChunk(total_1)
 else
  s = Format(total_1)
 endif
 return(s)
end
integer proc FmnExceedsLimit()
 if fmn_5 > 0
  return(1)
 endif
 if fmn_4 > 1000
  return(1)
 endif
 if fmn_4 == 1000
  if fmn_3 > 0
   return(1)
  endif
  if fmn_2 > 0
   return(1)
  endif
  if fmn_1 > 0
   return(1)
  endif
 endif
 return(0)
end
integer proc Phi(integer n)
 integer res = n
 integer i = 2
 integer temp_n = n
 while i * i <= temp_n
  if temp_n MOD i == 0
   while temp_n MOD i == 0
    temp_n = temp_n / i
   endwhile
   res = res - (res / i)
  endif
  i = i + 1
 endwhile
 if temp_n > 1
  res = res - (res / temp_n)
 endif
 return(res)
end
proc CalcTerm(integer m, integer nd)
 integer i = 0
 integer j = 0
 TermSet(1)
 for j = 1 to m
  for i = 1 to nd
   TermMul(j * nd - nd + i)
   TermDiv(i)
  endfor
 endfor
end
proc CalcFmn(integer m, integer n)
 integer d = 0
 FmnClear()
 for d = 1 to n
  if n MOD d == 0
   CalcTerm(m, n / d)
   TermMul(Phi(d))
   FmnAddTerm()
  endif
 endfor
 FmnDiv(m * n)
end
string proc SolveEuler281()
 integer m = 2
 integer n = 1
 integer continue_m = 1
 integer continue_n = 1
 string final_sum[255] = ""
 total_1 = 0
 total_2 = 0
 total_3 = 0
 total_4 = 0
 total_5 = 0
 while continue_m
  n = 1
  continue_n = 1
  while continue_n
   CalcFmn(m, n)
   if FmnExceedsLimit()
    continue_n = 0
    if n == 1
     continue_m = 0
    endif
   else
    TotalAddFmn()
    n = n + 1
   endif
  endwhile
  m = m + 1
 endwhile
 final_sum = TotalToStr()
 return(final_sum)
end
proc main()
 string res[255] = ""
 res = SolveEuler281()
 CopyToWinClip(res)
 Warn(res)
 CopyToWinClip(res)
 AddLine("Project Euler 281 Result: " + res)
 AddLine("LLM: Google Gemini")
 AddLine("Version: 4")
end
