// eulerproject0245py.s
// Project Euler Problem 245: Coresilience
//
// Generates pe245.py (ddd.py algorithm) from within TSE via AddLine(),
// runs it via DOS() with stdout redirected to pe245result.txt.
//
// Algorithm: Pollard rho factoring of p^2-p+1 for semiprime phase,
// DFS with try_last_prime for multi-prime phase.
// Correct answer: 288084712410001
//
// <version>1.0.0.0.7</version>
// LLM: Claude claude-sonnet-4-6 (Anthropic) - v7
//
// History:
//   1.0.0.0.1..6  2026-04-04  Various incorrect attempts
//   1.0.0.0.7     2026-04-04  Use ddd.py algorithm (Pollard rho + DFS)

Proc Main()
    Integer bufPy
    Integer bufResult
    String  answerStr[255]  = ""
    String  pyExe[255]      = "g:\language\computer\python\python\python.exe"
    String  pyFile[255]     = "pe245.py"
    String  resultFile[255] = "pe245result.txt"
    String  pyCmd[255]      = ""
    String  i1[8]           = "    "
    String  i2[16]          = "        "
    String  i3[24]          = "            "
    String  i4[32]          = "                "
    String  i5[40]          = "                    "

    // --- Erase old Python script file ---
    PushPosition()
    PushBlock()
    If EditFile(pyFile)
        AbandonFile()
    EndIf
    EraseDiskFile(pyFile)
    PopPosition()
    PopBlock()

    // --- Erase old result file ---
    PushPosition()
    PushBlock()
    If EditFile(resultFile)
        AbandonFile()
    EndIf
    EraseDiskFile(resultFile)
    PopPosition()
    PopBlock()

    // -------------------------------------------------------
    // Build pe245.py (= ddd.py) line by line.
    // Lines with double quotes use Chr(34); backslash uses Chr(92).
    // -------------------------------------------------------
    bufPy = CreateTempBuffer()
    GotoBufferId(bufPy)
    BegFile()

    AddLine("from __future__ import annotations")                                // 1
    AddLine("")                                                                  // 2
    AddLine("import math")                                                       // 3
    AddLine("import random")                                                     // 4
    AddLine("from typing import Dict, List")                                     // 5
    AddLine("")                                                                  // 6
    AddLine("")                                                                  // 7
    AddLine("LIMIT = 2 * 10**11")                                                // 8
    AddLine("")                                                                  // 9
    AddLine("")                                                                  // 10
    AddLine("def sieve(n: int) -> List[int]:")                                   // 11
    AddLine("bs = bytearray(b" + Chr(34) + Chr(92) + "x01" + Chr(34) + ") * (n + 1)")  // 12 i1
    AddLine("bs[0:2] = b" + Chr(34) + Chr(92) + "x00" + Chr(92) + "x00" + Chr(34))    // 13 i1
    AddLine("primes: List[int] = []")                                            // 14 i1
    AddLine("for i in range(2, n + 1):")                                         // 15 i1
    AddLine("if bs[i]:")                                                         // 16 i2
    AddLine("primes.append(i)")                                                  // 17 i3
    AddLine("if i * i <= n:")                                                    // 18 i3
    AddLine("bs[i * i : n + 1 : i] = b" + Chr(34) + Chr(92) + "x00" + Chr(34) + " * (((n - i * i) // i) + 1)")  // 19 i4
    AddLine("return primes")                                                     // 20 i1
    AddLine("")                                                                  // 21
    AddLine("")                                                                  // 22
    AddLine("def is_probable_prime(n: int) -> bool:")                            // 23
    AddLine("if n < 2:")                                                         // 24 i1
    AddLine("return False")                                                      // 25 i2
    AddLine("small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]")     // 26 i1
    AddLine("for p in small_primes:")                                            // 27 i1
    AddLine("if n % p == 0:")                                                    // 28 i2
    AddLine("return n == p")                                                     // 29 i3
    AddLine("d = n - 1")                                                         // 30 i1
    AddLine("s = 0")                                                             // 31 i1
    AddLine("while d % 2 == 0:")                                                 // 32 i1
    AddLine("s += 1")                                                            // 33 i2
    AddLine("d //= 2")                                                           // 34 i2
    AddLine("for a in [2, 3, 5, 7, 11, 13]:")                                   // 35 i1
    AddLine("if a >= n:")                                                        // 36 i2
    AddLine("continue")                                                          // 37 i3
    AddLine("x = pow(a, d, n)")                                                  // 38 i2
    AddLine("if x == 1 or x == n - 1:")                                         // 39 i2
    AddLine("continue")                                                          // 40 i3
    AddLine("for _ in range(s - 1):")                                            // 41 i2
    AddLine("x = pow(x, 2, n)")                                                  // 42 i3
    AddLine("if x == n - 1:")                                                    // 43 i3
    AddLine("break")                                                             // 44 i4
    AddLine("else:")                                                             // 45 i2
    AddLine("return False")                                                      // 46 i3
    AddLine("return True")                                                       // 47 i1
    AddLine("")                                                                  // 48
    AddLine("")                                                                  // 49
    AddLine("def pollard_rho(n: int) -> int:")                                   // 50
    AddLine("if n % 2 == 0:")                                                    // 51 i1
    AddLine("return 2")                                                          // 52 i2
    AddLine("if n % 3 == 0:")                                                    // 53 i1
    AddLine("return 3")                                                          // 54 i2
    AddLine("while True:")                                                       // 55 i1
    AddLine("c = random.randrange(1, n - 1)")                                    // 56 i2
    AddLine("x = random.randrange(2, n - 1)")                                    // 57 i2
    AddLine("y = x")                                                             // 58 i2
    AddLine("d = 1")                                                             // 59 i2
    AddLine("while d == 1:")                                                     // 60 i2
    AddLine("x = (pow(x, 2, n) + c) % n")                                       // 61 i3
    AddLine("y = (pow(y, 2, n) + c) % n")                                       // 62 i3
    AddLine("y = (pow(y, 2, n) + c) % n")                                       // 63 i3
    AddLine("d = math.gcd(abs(x - y), n)")                                      // 64 i3
    AddLine("if d != n:")                                                        // 65 i2
    AddLine("return d")                                                          // 66 i3
    AddLine("")                                                                  // 67
    AddLine("")                                                                  // 68
    AddLine("def factor(n: int, res: List[int]) -> None:")                       // 69
    AddLine("if n == 1:")                                                        // 70 i1
    AddLine("return")                                                            // 71 i2
    AddLine("if is_probable_prime(n):")                                          // 72 i1
    AddLine("res.append(n)")                                                     // 73 i2
    AddLine("return")                                                            // 74 i2
    AddLine("d = pollard_rho(n)")                                                // 75 i1
    AddLine("factor(d, res)")                                                    // 76 i1
    AddLine("factor(n // d, res)")                                               // 77 i1
    AddLine("")                                                                  // 78
    AddLine("")                                                                  // 79
    AddLine("def divisors_from_factors(factors: List[int]) -> List[int]:")       // 80
    AddLine("counts: Dict[int, int] = {}")                                       // 81 i1
    AddLine("for p in factors:")                                                 // 82 i1
    AddLine("counts[p] = counts.get(p, 0) + 1")                                 // 83 i2
    AddLine("divs = [1]")                                                        // 84 i1
    AddLine("for p, exp in counts.items():")                                     // 85 i1
    AddLine("cur = list(divs)")                                                  // 86 i2
    AddLine("mult = 1")                                                          // 87 i2
    AddLine("for _ in range(exp):")                                              // 88 i2
    AddLine("mult *= p")                                                         // 89 i3
    AddLine("for d in divs:")                                                    // 90 i3
    AddLine("cur.append(d * mult)")                                              // 91 i4
    AddLine("divs = cur")                                                        // 92 i2
    AddLine("return divs")                                                       // 93 i1
    AddLine("")                                                                  // 94
    AddLine("")                                                                  // 95
    AddLine("def int_root(n: int, k: int) -> int:")                              // 96
    AddLine("if k == 1:")                                                        // 97 i1
    AddLine("return n")                                                          // 98 i2
    AddLine("if k == 2:")                                                        // 99 i1
    AddLine("return int(math.isqrt(n))")                                         // 100 i2
    AddLine("x = int(n ** (1.0 / k))")                                          // 101 i1
    AddLine("while (x + 1) ** k <= n:")                                          // 102 i1
    AddLine("x += 1")                                                            // 103 i2
    AddLine("while x**k > n:")                                                   // 104 i1
    AddLine("x -= 1")                                                            // 105 i2
    AddLine("return x")                                                          // 106 i1
    AddLine("")                                                                  // 107
    AddLine("")                                                                  // 108
    AddLine("def main() -> None:")                                               // 109
    AddLine("random.seed(0)")                                                    // 110 i1
    AddLine("max_p = int(math.isqrt(LIMIT)) + 1")                               // 111 i1
    AddLine("primes = [p for p in sieve(max_p) if p >= 3]")                     // 112 i1
    AddLine("solutions = set()")                                                 // 113 i1
    AddLine("")                                                                  // 114
    AddLine("# k = 2 (semiprime) case via divisors of p^2 - p + 1")             // 115 i1
    AddLine("for p in primes:")                                                  // 116 i1
    AddLine("s = p * p - p + 1")                                                 // 117 i2
    AddLine("fac: List[int] = []")                                               // 118 i2
    AddLine("factor(s, fac)")                                                    // 119 i2
    AddLine("divs = divisors_from_factors(fac)")                                 // 120 i2
    AddLine("for d in divs:")                                                    // 121 i2
    AddLine("if d < 2 * p - 1:")                                                 // 122 i3
    AddLine("continue")                                                          // 123 i4
    AddLine("q = d - p + 1")                                                     // 124 i3
    AddLine("if q <= p:")                                                        // 125 i3
    AddLine("continue")                                                          // 126 i4
    AddLine("if p * q > LIMIT:")                                                 // 127 i3
    AddLine("continue")                                                          // 128 i4
    AddLine("if is_probable_prime(q):")                                          // 129 i3
    AddLine("solutions.add(p * q)")                                              // 130 i4
    AddLine("")                                                                  // 131
    AddLine("# compute max possible number of prime factors")                    // 132 i1
    AddLine("prod = 1")                                                          // 133 i1
    AddLine("max_k = 0")                                                         // 134 i1
    AddLine("for p in primes:")                                                  // 135 i1
    AddLine("if prod * p > LIMIT:")                                              // 136 i2
    AddLine("break")                                                             // 137 i3
    AddLine("prod *= p")                                                         // 138 i2
    AddLine("max_k += 1")                                                        // 139 i2
    AddLine("")                                                                  // 140
    AddLine("def try_last_prime(A: int, B: int, last_p: int) -> None:")          // 141 i1
    AddLine("D = A - B")                                                         // 142 i2
    AddLine("if D <= 0:")                                                        // 143 i2
    AddLine("return")                                                            // 144 i3
    AddLine("r_max = LIMIT // A")                                                // 145 i2
    AddLine("if r_max <= last_p:")                                               // 146 i2
    AddLine("return")                                                            // 147 i3
    AddLine("num_min = B * (last_p - 1) - 1")                                   // 148 i2
    AddLine("den_min = B + last_p * D")                                          // 149 i2
    AddLine("u_min = num_min // den_min + 1")                                    // 150 i2
    AddLine("if u_min < 1:")                                                     // 151 i2
    AddLine("u_min = 1")                                                         // 152 i3
    AddLine("num_max = B * (r_max - 1) - 1")                                    // 153 i2
    AddLine("den_max = B + r_max * D")                                           // 154 i2
    AddLine("if num_max < 0:")                                                   // 155 i2
    AddLine("return")                                                            // 156 i3
    AddLine("u_max = num_max // den_max")                                        // 157 i2
    AddLine("u_max = min(u_max, (B - 1) // D)")                                 // 158 i2
    AddLine("if u_max < u_min:")                                                 // 159 i2
    AddLine("return")                                                            // 160 i3
    AddLine("for u in range(u_min, u_max + 1):")                                // 161 i2
    AddLine("denom = B - u * D")                                                 // 162 i3
    AddLine("if denom <= 0:")                                                    // 163 i3
    AddLine("break")                                                             // 164 i4
    AddLine("numer = B * (u + 1) + 1")                                          // 165 i3
    AddLine("if numer % denom != 0:")                                            // 166 i3
    AddLine("continue")                                                          // 167 i4
    AddLine("r = numer // denom")                                                // 168 i3
    AddLine("if r <= last_p or A * r > LIMIT:")                                 // 169 i3
    AddLine("continue")                                                          // 170 i4
    AddLine("if is_probable_prime(r):")                                          // 171 i3
    AddLine("n = A * r")                                                         // 172 i4
    AddLine("phi = B * (r - 1)")                                                 // 173 i4
    AddLine("if (n - 1) % (n - phi) == 0:")                                     // 174 i4
    AddLine("solutions.add(n)")                                                  // 175 i5
    AddLine("")                                                                  // 176
    AddLine("def dfs(idx: int, remaining: int, A: int, B: int, last_p: int) -> None:")  // 177 i1
    AddLine("if remaining == 0:")                                                // 178 i2
    AddLine("try_last_prime(A, B, last_p)")                                     // 179 i3
    AddLine("return")                                                            // 180 i3
    AddLine("max_p_local = int_root(LIMIT // A, remaining + 1)")                // 181 i2
    AddLine("for i in range(idx, len(primes)):")                                // 182 i2
    AddLine("p = primes[i]")                                                     // 183 i3
    AddLine("if p > max_p_local:")                                               // 184 i3
    AddLine("break")                                                             // 185 i4
    AddLine("dfs(i + 1, remaining - 1, A * p, B * (p - 1), p)")                // 186 i3
    AddLine("")                                                                  // 187
    AddLine("for k in range(3, max_k + 1):")                                    // 188 i1
    AddLine("m = k - 1")                                                         // 189 i2
    AddLine("if m < 2:")                                                         // 190 i2
    AddLine("continue")                                                          // 191 i3
    AddLine("dfs(0, m, 1, 1, 2)")                                               // 192 i2
    AddLine("")                                                                  // 193
    AddLine("print(sum(solutions))")                                             // 194 i1
    AddLine("")                                                                  // 195
    AddLine("")                                                                  // 196
    AddLine("if __name__ == " + Chr(34) + "__main__" + Chr(34) + ":")           // 197
    AddLine("main()")                                                            // 198 i1

    // -------------------------------------------------------
    // Insert Python indentation.
    // -------------------------------------------------------
    GotoBufferId(bufPy)

    GotoLine(12)  BegLine()  InsertText(i1, _INSERT_)   // sieve body
    GotoLine(13)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(14)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(15)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(16)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(17)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(18)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(19)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(20)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(24)  BegLine()  InsertText(i1, _INSERT_)   // is_probable_prime body
    GotoLine(25)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(26)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(27)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(28)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(29)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(30)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(31)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(32)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(33)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(34)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(35)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(36)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(37)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(38)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(39)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(40)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(41)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(42)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(43)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(44)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(45)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(46)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(47)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(51)  BegLine()  InsertText(i1, _INSERT_)   // pollard_rho body
    GotoLine(52)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(53)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(54)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(55)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(56)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(57)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(58)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(59)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(60)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(61)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(62)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(63)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(64)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(65)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(66)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(70)  BegLine()  InsertText(i1, _INSERT_)   // factor body
    GotoLine(71)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(72)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(73)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(74)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(75)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(76)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(77)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(81)  BegLine()  InsertText(i1, _INSERT_)   // divisors_from_factors body
    GotoLine(82)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(83)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(84)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(85)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(86)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(87)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(88)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(89)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(90)  BegLine()  InsertText(i3, _INSERT_)
    GotoLine(91)  BegLine()  InsertText(i4, _INSERT_)
    GotoLine(92)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(93)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(97)  BegLine()  InsertText(i1, _INSERT_)   // int_root body
    GotoLine(98)  BegLine()  InsertText(i2, _INSERT_)
    GotoLine(99)  BegLine()  InsertText(i1, _INSERT_)
    GotoLine(100) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(101) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(102) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(103) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(104) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(105) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(106) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(110) BegLine()  InsertText(i1, _INSERT_)   // main body
    GotoLine(111) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(112) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(113) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(115) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(116) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(117) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(118) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(119) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(120) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(121) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(122) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(123) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(124) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(125) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(126) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(127) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(128) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(129) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(130) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(132) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(133) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(134) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(135) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(136) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(137) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(138) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(139) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(141) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(142) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(143) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(144) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(145) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(146) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(147) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(148) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(149) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(150) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(151) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(152) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(153) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(154) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(155) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(156) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(157) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(158) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(159) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(160) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(161) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(162) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(163) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(164) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(165) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(166) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(167) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(168) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(169) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(170) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(171) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(172) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(173) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(174) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(175) BegLine()  InsertText(i5, _INSERT_)
    GotoLine(177) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(178) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(179) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(180) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(181) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(182) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(183) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(184) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(185) BegLine()  InsertText(i4, _INSERT_)
    GotoLine(186) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(188) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(189) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(190) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(191) BegLine()  InsertText(i3, _INSERT_)
    GotoLine(192) BegLine()  InsertText(i2, _INSERT_)
    GotoLine(194) BegLine()  InsertText(i1, _INSERT_)
    GotoLine(198) BegLine()  InsertText(i1, _INSERT_)

    // --- Save Python script to disk ---
    SaveAs(pyFile, _OVERWRITE_)
    AbandonFile(bufPy)

    // --- Run Python, redirect stdout to result file ---
    pyCmd = pyExe + " " + pyFile + " > " + resultFile
    DOS(pyCmd, _DEFAULT_ | _DEFAULT_ | _DONT_CLEAR_)

    // --- Read result ---
    bufResult = CreateTempBuffer()
    InsertFile(resultFile)
    BegFile()
    answerStr = GetText(1, CurrLineLen())
    AbandonFile(bufResult)

    // --- Show answer ---
    CopyToWinClip(answerStr)
    Warn("Project Euler 245 - Coresilience" + Chr(13) +
         "Sum of composite n<=2E11 with unit C(n):" + Chr(13) +
         answerStr)
    CopyToWinClip(answerStr)

End
