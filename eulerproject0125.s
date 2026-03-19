//=============================================================================
//
// Project Euler Problem 125 Solution
// Find the sum of all palindromic numbers less than 10^8 that are
// the sum of consecutive squares of positive integers
//
// Version: 15.0
// LLM: DeepSeek (Claude (Anthropic))
// Date: March 19, 2026
//
//=============================================================================

// FORWARD declarations to make functions known before they're called
// Note: Use PROC instead of FUNCTION in FORWARD declaration
FORWARD STRING PROC AddBigIntegers( STRING a, STRING b )

//=============================================================================
PROC Main()
   INTEGER maxNumber = 100000000     // 10^8 as specified in the problem
   STRING palindromeSumStr[255] = "0"  // Store sum as string for big integer arithmetic
   INTEGER currentNumber
   STRING numberString[255] = ""     // String with explicit size (max 255 chars)
   INTEGER stringLength
   INTEGER leftPos, rightPos
   INTEGER isPalindrome
   INTEGER i, j, squareSum

   // Buffer to simulate flag array (to avoid duplicates)
   INTEGER flagBuffer = 0
   INTEGER currentLine = 0
   INTEGER totalLines = 0
   STRING lineContent[255] = ""      // String with explicit size
   INTEGER numberExists
   INTEGER compareResult
   STRING tempString[255] = ""       // Temporary string for conversions
   STRING currentNumStr[255] = ""    // Current number as string

   // Create a temporary buffer to store numbers we've already counted
   PushPosition()
   flagBuffer = CreateTempBuffer()
   PopPosition()

   // Find all numbers that are sums of consecutive squares
   // Start from i^2 and add consecutive squares until we exceed maxNumber
   i = 1  // Positive integers only (starting from 1^2 as per problem note)

   WHILE i * i < maxNumber
      squareSum = i * i
      j = i + 1

      WHILE (j * j < maxNumber) AND (squareSum + j * j < maxNumber)
         squareSum = squareSum + j * j

         // Check if this sum is palindromic
         currentNumber = squareSum

         // Convert number to string for palindrome checking using Str()
         tempString = Str(currentNumber, 10)
         numberString = tempString
         stringLength = Length(numberString)

         // Check if palindrome
         isPalindrome = 1
         leftPos = 1
         rightPos = stringLength

         WHILE leftPos < rightPos AND isPalindrome == 1
            IF NOT( SubStr(numberString, leftPos, 1) == SubStr(numberString, rightPos, 1) )
               isPalindrome = 0
            ENDIF
            leftPos = leftPos + 1
            rightPos = rightPos - 1
         ENDWHILE

         // If it's a palindrome, check if we've already counted it
         IF isPalindrome == 1
            // Check if this number already exists in our buffer
            numberExists = 0
            PushPosition()
            GotoBufferId(flagBuffer)

            // Get total number of lines in buffer
            totalLines = NumLines()
            currentLine = 1
            
            // Read each line to see if the number already exists
            WHILE currentLine <= totalLines AND numberExists == 0
               GotoLine(currentLine)
               lineContent = Trim( GetText(1, MAXSTRINGLEN) )
               IF Length(lineContent) > 0
                  compareResult = CmpiStr( lineContent, Str(currentNumber, 10) )
                  IF compareResult == 0
                     numberExists = 1
                  ENDIF
               ENDIF
               currentLine = currentLine + 1
            ENDWHILE
            
            PopPosition()
            
            // If number doesn't exist yet, add it to sum and to buffer
            IF numberExists == 0
               // Add current number to palindrome sum using big integer addition
               currentNumStr = Str(currentNumber, 10)
               palindromeSumStr = AddBigIntegers( palindromeSumStr, currentNumStr )
               
               // Add this number to our buffer
               PushPosition()
               GotoBufferId(flagBuffer)
               EndFile()
               AddLine( currentNumStr, flagBuffer )
               PopPosition()
            ENDIF
         ENDIF
         
         j = j + 1
      ENDWHILE
      
      i = i + 1
   ENDWHILE
   
   // Clean up the temporary buffer
   IF NOT( flagBuffer == 0 )
      PushPosition()
      GotoBufferId(flagBuffer)
      AbandonFile(flagBuffer)
      PopPosition()
   ENDIF
   
   // Show the result in a Warn box
   Warn( "The sum of all palindromic numbers less than 100,000,000 that are sums of consecutive squares is: " + palindromeSumStr )
   
   // Copy only the answer to clipboard (just the number)
   CopyToWinClip( palindromeSumStr )
   
   Return()
END

//=============================================================================
// Big integer addition - adds two numbers represented as strings
// Returns the sum as a string
// Note: Use STRING PROC for function definition (PROC instead of FUNCTION)
//=============================================================================
STRING PROC AddBigIntegers( STRING a, STRING b )
   STRING result[255] = ""
   INTEGER carry = 0
   INTEGER i
   INTEGER digitA, digitB, sum
   INTEGER lenA, lenB, maxLen
   STRING temp[255] = ""
   
   lenA = Length(a)
   lenB = Length(b)
   maxLen = lenA
   IF lenB > maxLen
      maxLen = lenB
   ENDIF

   // Process digits from rightmost to leftmost
   i = 1
   WHILE i <= maxLen
      // Get digit from a (from rightmost)
      IF i <= lenA
         digitA = Val( SubStr( a, lenA - i + 1, 1 ) )
      ELSE
         digitA = 0
      ENDIF

      // Get digit from b (from rightmost)
      IF i <= lenB
         digitB = Val( SubStr( b, lenB - i + 1, 1 ) )
      ELSE
         digitB = 0
      ENDIF

      // Add digits with carry
      sum = digitA + digitB + carry
      carry = sum / 10
      sum = sum - (carry * 10)

      // Build result from right to left
      temp = Str(sum, 10) + temp

      i = i + 1
   ENDWHILE

   // Handle final carry
   IF carry > 0
      temp = Str(carry, 10) + temp
   ENDIF

   result = temp
   Return( result )
END
