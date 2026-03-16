// Project Euler - Problem 59: XOR Decryption
//
// TSE/32
//
// Key = 3 lowercase letters, repeated cyclically.
// Brute-force all 26^3 = 17576 keys.
//
// Cipher file: p059_cipher.txt
//
// Output:
//   best-scoring key
//   sum of ASCII values in decrypted text
//
// Correct result for the supplied cipher file:
//   Key    : exp
//   Answer : 129448

string CIPHER_FILE[255] = "p059_cipher.txt"


integer proc IsGoodAscii(integer c)
    if c == 9
        return(TRUE)
    endif
    if c == 10
        return(TRUE)
    endif
    if c == 13
        return(TRUE)
    endif
    if c >= 32 and c <= 126
        return(TRUE)
    endif
    return(FALSE)
end


integer proc ScoreChar(integer c)
    if not IsGoodAscii(c)
        return(-50)
    endif

    if c == 32
        return(6)
    endif

    if c >= 97 and c <= 122
        return(4)
    endif

    if c >= 65 and c <= 90
        return(2)
    endif

    if c >= 48 and c <= 57
        return(1)
    endif

    if c == 44 return(1) endif   // ,
    if c == 46 return(1) endif   // .
    if c == 39 return(1) endif   // '
    if c == 34 return(1) endif   // "
    if c == 59 return(1) endif   // ;
    if c == 58 return(1) endif   // :
    if c == 33 return(1) endif   // !
    if c == 63 return(1) endif   // ?
    if c == 45 return(1) endif   // -
    if c == 40 return(1) endif   // (
    if c == 41 return(1) endif   // )
    if c == 91 return(1) endif   // [
    if c == 93 return(1) endif   // ]
    if c == 47 return(1) endif   // /
    if c == 38 return(1) endif   // &
    if c == 42 return(1) endif   // *
    if c == 37 return(1) endif   // %
    if c == 43 return(1) endif   // +
    if c == 61 return(1) endif   // =
    if c == 95 return(1) endif   // _
    if c == 9  return(0) endif
    if c == 10 return(0) endif
    if c == 13 return(0) endif

    return(-5)
end


integer proc ScoreLetterFrequency(integer c)
    if c == 101 return(3) endif   // e
    if c == 116 return(3) endif   // t
    if c == 97  return(2) endif   // a
    if c == 111 return(2) endif   // o
    if c == 105 return(2) endif   // i
    if c == 110 return(2) endif   // n
    if c == 115 return(2) endif   // s
    if c == 104 return(2) endif   // h
    if c == 114 return(2) endif   // r
    if c == 100 return(2) endif   // d
    if c == 108 return(2) endif   // l
    if c == 117 return(2) endif   // u
    return(0)
end


integer proc DecodeByte(integer enc, integer ka, integer kb, integer kc, integer position_mod3)
    if position_mod3 == 0
        return(enc ^ ka)
    endif
    if position_mod3 == 1
        return(enc ^ kb)
    endif
    return(enc ^ kc)
end


proc SplitCipherIntoLines()
    BegFile()
    while lFind(",", "g")
        DelChar()
        SplitLine()
    endwhile
end


proc Main()
    integer cipher_id
    integer n
    integer ka
    integer kb
    integer kc
    integer best_ka
    integer best_kb
    integer best_kc
    integer i
    integer enc
    integer dec
    integer score
    integer best_score
    integer total
    integer posmod
    integer line_len
    integer preview_len

    string ln[255]
    string keystr[10]
    string result[255]
    string preview[255]

    if not FileExists(CIPHER_FILE)
        Warn("File not found: " + CIPHER_FILE)
        return()
    endif

    cipher_id = CreateTempBuffer()
    if cipher_id == 0
        Warn("Cannot create temp buffer")
        return()
    endif

    GotoBufferId(cipher_id)
    InsertFile(CIPHER_FILE)

    SplitCipherIntoLines()

    n = NumLines()
    if n <= 0
        AbandonFile(cipher_id)
        Warn("Cipher file empty")
        return()
    endif

    best_score = -2147480000
    best_ka    = 97
    best_kb    = 97
    best_kc    = 97

    ka = 97
    while ka <= 122
        kb = 97
        while kb <= 122
            kc = 97
            while kc <= 122

                score = 0
                GotoBufferId(cipher_id)
                BegFile()

                i = 1
                while i <= n
                    line_len = CurrLineLen()
                    if line_len > 0
                        ln = GetText(1, line_len)
                        enc = Val(ln)

                        posmod = (i - 1) mod 3
                        dec = DecodeByte(enc, ka, kb, kc, posmod)

                        score = score + ScoreChar(dec)
                        score = score + ScoreLetterFrequency(dec)
                    else
                        score = score - 100
                    endif

                    if i < n
                        Down()
                    endif
                    i = i + 1
                endwhile

                if score > best_score
                    best_score = score
                    best_ka    = ka
                    best_kb    = kb
                    best_kc    = kc
                endif

                kc = kc + 1
            endwhile
            kb = kb + 1
        endwhile
        ka = ka + 1
    endwhile

    total = 0
    preview = ""
    preview_len = 0

    GotoBufferId(cipher_id)
    BegFile()

    i = 1
    while i <= n
        line_len = CurrLineLen()
        if line_len > 0
            ln = GetText(1, line_len)
            enc = Val(ln)

            posmod = (i - 1) mod 3
            dec = DecodeByte(enc, best_ka, best_kb, best_kc, posmod)

            total = total + dec

            if preview_len < 200
                preview = preview + Chr(dec)
                preview_len = preview_len + 1
            endif
        endif

        if i < n
            Down()
        endif
        i = i + 1
    endwhile

    AbandonFile(cipher_id)

    keystr = Chr(best_ka) + Chr(best_kb) + Chr(best_kc)

    result = "PE059 XOR Decryption" + Chr(13) +
             "Key   : " + keystr + Chr(13) +
             "Answer: " + Str(total) + Chr(13) +
             "Preview: " + preview

    CopyToWinClip(result)
    Warn(result)
end
