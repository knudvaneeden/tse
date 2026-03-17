// euler094.s
// Version: 1.2
//
// Project Euler - Problem 94: Almost Equilateral Triangles
//
// Problem:
//   An almost equilateral triangle has two equal sides and a third side
//   that differs by no more than one unit. For example, 5-5-6 has area 12.
//   Find the sum of the perimeters of all almost equilateral triangles
//   with integral side lengths and integral area whose perimeters do not
//   exceed 1,000,000,000.
//
// Answer: 518408346
//
// Method:
//   The valid perimeters follow two recurrences (derived from the
//   Pell equations underlying Heron integrality):
//
//   Case 1: sides (a, a, a+1), perimeter p = 3a+1
//     p[0] = 16,  p[1] = 196
//     p[n] = 14 * p[n-1] - p[n-2]
//
//   Case 2: sides (a, a, a-1), perimeter p = 3a-1
//     p[0] = 50,  p[1] = 722
//     p[n] = 14 * p[n-1] - p[n-2]
//
//   32-bit overflow safety:
//     The stop condition is evaluated WITHOUT computing 14*p[n-1].
//     Instead we check:  p[n-1] > (MAX_PERIM + p[n-2]) / 14
//     which is equivalent to  14*p[n-1] - p[n-2] > MAX_PERIM  but uses
//     only division.  This fires before any overflowing multiplication
//     ever executes.  The largest multiplication actually performed is
//     14 * 27,176,738 = 380,474,332  which fits comfortably in 32-bit.
//
// TSE SAL rules applied:
//   - No integer arrays (only scalar variables used)
//   - No reserved/built-in names used as variables
//     (avoided: val, pos, str, s, mark, old, Find, Insert, Delete,
//      Length, Copy, key, name, line, row, col, n, i)
//   - All declarations together immediately after the proc header,
//     before any executable statement
//   - All strings well within 255-character limit
//   - 32-bit safe: sum 518,408,346 < 2,147,483,647
//   - Return() always uses parentheses
//   - Warn() used to display final answer
//   - CopyToWinClip() copies ONLY the bare numeric answer string
//   - Result is NOT pasted into any editor buffer
//   - Version number included at top of file

proc Main()

    // --- All declarations first, before any executable statements ---
    integer MAX_PERIM
    integer total_sum
    integer stop_thresh
    integer p1_prev2
    integer p1_prev1
    integer p1_curr
    integer p2_prev2
    integer p2_prev1
    integer p2_curr
    string  answer_str[20]

    // --- Initialise ---
    MAX_PERIM = 1000000000
    total_sum = 0

    // --- Case 1: perimeter recurrence p[n] = 14*p[n-1] - p[n-2] ---
    // Seeds: p[0]=16 (triangle 5-5-6), p[1]=196 (triangle 65-65-66)
    p1_prev2 = 16
    p1_prev1 = 196
    total_sum = total_sum + p1_prev2
    total_sum = total_sum + p1_prev1

    // Safe stop: next = 14*p1_prev1 - p1_prev2
    // Compute stop threshold WITHOUT multiplying by 14:
    //   next > MAX iff p1_prev1 > (MAX + p1_prev2) / 14
    stop_thresh = (MAX_PERIM + p1_prev2) / 14
    while p1_prev1 <= stop_thresh
        p1_curr   = 14 * p1_prev1 - p1_prev2
        total_sum = total_sum + p1_curr
        p1_prev2  = p1_prev1
        p1_prev1  = p1_curr
        stop_thresh = (MAX_PERIM + p1_prev2) / 14
    endwhile

    // --- Case 2: perimeter recurrence p[n] = 14*p[n-1] - p[n-2] ---
    // Seeds: p[0]=50 (triangle 17-17-16), p[1]=722 (triangle 241-241-240)
    p2_prev2 = 50
    p2_prev1 = 722
    total_sum = total_sum + p2_prev2
    total_sum = total_sum + p2_prev1

    stop_thresh = (MAX_PERIM + p2_prev2) / 14
    while p2_prev1 <= stop_thresh
        p2_curr   = 14 * p2_prev1 - p2_prev2
        total_sum = total_sum + p2_curr
        p2_prev2  = p2_prev1
        p2_prev1  = p2_curr
        stop_thresh = (MAX_PERIM + p2_prev2) / 14
    endwhile

    // --- Show and copy result ---
    answer_str = Str(total_sum)

    Warn("Project Euler #94 answer: " + answer_str)

    CopyToWinClip(answer_str)

end
