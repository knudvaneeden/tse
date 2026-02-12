/**********************************************************************

        an rpn expression evaluator for TSE
        by rick vannorman
           rt 1 box 294
           glenwood, wv 25520

        released into the public domain

        tokens must be separated by at least one space (ala FORTH)

        examples:

                9 8 +           add 9 to 8
                21 7 -          subtract 7 from 21
                81 10 /         divide 81 by 10
                0x10 3 -        subtract 3 from 16 (10H)
                2 4 <           shift 2 left 4 bits
                $100 2 >        shift 256 right 2 bits

        complex expressions are allowed

                9 8 + 10 * 21 + 2 >

        evaluation is from left to right, with numbers going onto
        the "stack" and operators using the top two items.  no
        parens are needed as the evaluation order is non-ambiguous

        this resembles an HP calculator

        operators:      function

        + - * /         add subtract multiply divide
        %               mod, remainder from division
        < >             (shift) left right
        & | ^           (logical bit-wise) and or xor
        0x 0b 0o        (specifiy base) hex binary octal

**********************************************************************/
// rpn expression evaluator

string inputline[80]
integer col
integer span

integer accum
integer base
integer digits

integer tos
integer stack0
integer stack1
integer stack2
integer stack3
integer stack4
integer stack5
integer stack6
integer stack7

// -----


integer proc pop()
        integer temp = stack0
        stack0 = stack1
        stack1 = stack2
        stack2 = stack3
        stack3 = stack4
        stack4 = stack5
        stack5 = stack6
        stack6 = stack7
        return(temp)
end

proc push(integer temp)
        stack7 = stack6
        stack6 = stack5
        stack5 = stack4
        stack4 = stack3
        stack3 = stack2
        stack2 = stack1
        stack1 = stack0
        stack0 = temp
end


// -----

proc syntax()
        if (digits<>0)
                warn("Bad expression")
                halt
        endif
end

proc number()
        if (digits<>0)
                push(tos)
                tos=accum
                accum=0
                base=10
                digits=0
        endif
end

proc accumulate(integer digit)
        if (digit > base)
                warn("Bad number ")
                halt
        endif
        accum = accum * base + digit
        digits = digits + 1
end

proc based(integer newbase)
        if (accum==0)
                base=newbase
        else
                warn("Bad number")
        endif
end

// -----

proc evalch()
        case substr(inputline,col,1)
                when " "   number()
                when "+"   syntax()  tos = pop() +   tos
                when "-"   syntax()  tos = pop() -   tos
                when "*"   syntax()  tos = pop() *   tos
                when "/"   syntax()  tos = pop() /   tos
                when "%"   syntax()  tos = pop() mod tos
                when "&"   syntax()  tos = pop() &   tos
                when "|"   syntax()  tos = pop() |   tos
                when "^"   syntax()  tos = pop() ^   tos
                when "<"   syntax()  tos = pop() shl tos
                when ">"   syntax()  tos = pop() shr tos

                when "$"   syntax()  base = 16
                when "x"   based(16)
                when "b"   based(2)
                when "o"   based(8)

                when "0"   accumulate(0)
                when "1"   accumulate(1)
                when "2"   accumulate(2)
                when "3"   accumulate(3)
                when "4"   accumulate(4)
                when "5"   accumulate(5)
                when "6"   accumulate(6)
                when "7"   accumulate(7)
                when "8"   accumulate(8)
                when "9"   accumulate(9)
                when "A"   accumulate(10)
                when "B"   accumulate(11)
                when "C"   accumulate(12)
                when "D"   accumulate(13)
                when "E"   accumulate(14)
                when "F"   accumulate(15)
                when "a"   accumulate(10)
                when "b"   accumulate(11)
                when "c"   accumulate(12)
                when "d"   accumulate(13)
                when "e"   accumulate(14)
                when "f"   accumulate(15)
        endcase
        col=col+1
end

// -----

proc eval()
        accum=0
        digits=0
        push(0)
        tos=0
        base=10
        while (col<=span)
                evalch()
        endwhile
        number()
end

proc rpnexpr()

        while ask("Enter RPN Expression",inputline) and length(inputline)
                col=1
                span=length(inputline)
                eval()
                message("result is ",tos,",   ", str(tos,16)," hex      ")
        endwhile
end

<alt f9> rpnexpr()

