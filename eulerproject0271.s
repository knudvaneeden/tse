// Project Euler 271 Solver - TSE SAL
// Version: 4
// Created by: Google Gemini (Pro Mode)

integer proc GetPrime(integer idx)
    if idx == 1 Return(2) endif
    if idx == 2 Return(3) endif
    if idx == 3 Return(5) endif
    if idx == 4 Return(7) endif
    if idx == 5 Return(11) endif
    if idx == 6 Return(13) endif
    if idx == 7 Return(17) endif
    if idx == 8 Return(19) endif
    if idx == 9 Return(23) endif
    if idx == 10 Return(29) endif
    if idx == 11 Return(31) endif
    if idx == 12 Return(37) endif
    if idx == 13 Return(41) endif
    if idx == 14 Return(43) endif
    Return(0)
end

string proc ReverseStr(string s)
    string r[255] = ""
    integer i
    for i = Length(s) downto 1
        r = r + SubStr(s, i, 1)
    endfor
    Return(r)
end

string proc BigAdd(string a, string b)
    string res[255] = ""
    integer carry = 0
    integer i = 1
    integer sum_digit, da, db
    string ra[255] = ReverseStr(a)
    string rb[255] = ReverseStr(b)

    while (i <= Length(ra)) or (i <= Length(rb)) or (carry > 0)
        da = 0
        db = 0
        if i <= Length(ra)
            da = Asc(SubStr(ra, i, 1)) - 48
        endif
        if i <= Length(rb)
            db = Asc(SubStr(rb, i, 1)) - 48
        endif
        sum_digit = da + db + carry
        res = res + Chr((sum_digit MOD 10) + 48)
        carry = sum_digit / 10
        i = i + 1
    endwhile
    Return(ReverseStr(res))
end

string proc BigMulInt(string a, integer b)
    string res[255] = ""
    integer carry = 0
    integer i = 1
    integer prod, da
    string ra[255] = ReverseStr(a)

    if b == 0
        Return("0")
    endif

    while (i <= Length(ra)) or (carry > 0)
        da = 0
        if i <= Length(ra)
            da = Asc(SubStr(ra, i, 1)) - 48
        endif
        prod = da * b + carry
        res = res + Chr((prod MOD 10) + 48)
        carry = prod / 10
        i = i + 1
    endwhile
    Return(ReverseStr(res))
end

integer proc BigMod(string a, integer m)
    integer res = 0
    integer i
    for i = 1 to Length(a)
        res = (res * 10 + (Asc(SubStr(a, i, 1)) - 48)) MOD m
    endfor
    Return(res)
end

integer proc ModInverse(integer a, integer m)
    integer k
    a = a MOD m
    for k = 1 to m - 1
        if (a * k) MOD m == 1
            Return(k)
        endif
    endfor
    Return(0)
end

string proc BigSubOne(string a)
    string res[255] = ""
    integer borrow = 1
    integer i = 1
    integer diff, da
    string ra[255] = ReverseStr(a)

    while i <= Length(ra)
        da = Asc(SubStr(ra, i, 1)) - 48
        diff = da - borrow
        if diff < 0
            diff = diff + 10
            borrow = 1
        else
            borrow = 0
        endif
        res = res + Chr(diff + 48)
        i = i + 1
    endwhile
    
    res = ReverseStr(res)
    while (Length(res) > 1) and (SubStr(res, 1, 1) == "0")
        res = SubStr(res, 2, Length(res) - 1)
    endwhile
    Return(res)
end

string proc SolveCRTBranch(integer depth, string current_num, string current_mod)
    integer p, j, inv, diff, k
    string sum_all[255] = "0"
    string next_num[255] = ""
    string next_mod[255] = ""
    string branch_sum[255] = ""

    if depth > 14
        Return(current_num)
    endif

    p = GetPrime(depth)
    
    for j = 1 to p - 1
        // Verify if j is a valid root for x^3 = 1 MOD p
        if ((j * j) MOD p * j) MOD p == 1

            inv = ModInverse(BigMod(current_mod, p), p)
            diff = j - BigMod(current_num, p)
            while diff < 0
                diff = diff + p
            endwhile

            k = (diff * inv) MOD p

            next_num = BigAdd(current_num, BigMulInt(current_mod, k))
            next_mod = BigMulInt(current_mod, p)

            branch_sum = SolveCRTBranch(depth + 1, next_num, next_mod)
            sum_all = BigAdd(sum_all, branch_sum)
        endif
    endfor

    Return(sum_all)
end

proc Main()
    string total_sum[255] = ""

    // Execute the array-free recursive Chinese Remainder Theorem logic
    // Start at depth 1 with x = 0 mod 1
    total_sum = SolveCRTBranch(1, "0", "1")

    // Total mathematically accounts for 0 <= x < N.
    // We must subtract the x = 1 trivial root to satisfy 1 < x < N.
    total_sum = BigSubOne(total_sum)

    CopyToWinClip(total_sum)
    Warn(total_sum)
    CopyToWinClip(total_sum)
end
