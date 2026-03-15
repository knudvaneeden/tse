 // Main process
 Proc Main()
     string doors[100]
     integer i, j

     // Initialize all doors to '0' (closed)
     for i = 1 to 100
         doors[i] = '0'
     endfor

     // Iterate through the doors for each pass
     for i = 1 to 100
         j = i
         while (j <= 100)
             // Toggle the door state
             if (doors[j] == '0')
                 doors[j] = '1'  // Open the door
             else
                 doors[j] = '0'  // Close the door
             endif

             j = j + i  // Increment by the step value (i)
         endwhile
     endfor

     // Output the final state of the doors
     for i = 1 to 100
         if (doors[i] == '1')
             Warn("Door " + Str(i) + ": Open")
         else
             Warn
             ("Door " + Str(i) + ": Closed")
         endif
     endfor

     End
