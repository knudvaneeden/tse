===

1. -To install

     1. -Take the file l_r_align_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalll_r_align.bat

     4. -That will create a new file l_r_align_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          l_r_align.mac

2. -The .ini file is the local file 'l_r_align.ini'
    (thus not using tse.ini)

===

// Author: Zhang Zhao
//
// Published: 10 August 2022
//
// Revision: 14964
//
// ===
//
// Documentation:
//
// ===
//
// Use case: left and right align of a block of lines
//
// ===
//
// Example:
//
// 1. -Mark these 4 lines
//
/*
--- cut here: begin --------------------------------------------------
f=0.0f;sscanf(s,"%f",&f);printf("%f\n",f);//1.234568
lf=0.0;sscanf(s,"%lf",&lf);printf("%.15lf\n",lf);//1.234567890123456
lf=0.0f;sscanf(s,"%f",&lf);printf("%.15lf\n",lf);//0.000000000000000
f=0.0;sscanf(s,"%lf",&f);printf("%f\n",f);//70.175720
 | | |        |     |            |    |   ||  |
 = . ;        ,     ,            %    ,   //  .
--- cut here: end ----------------------------------------------------
*/
//
// 2. -Optionally place the column spacing characters above
//
// 3. -Note the column spacing characters above and make a concatenated string of it
//
//      =.;,,)%,//.
//
// 4. -Please specify that each column is
//
//       'l' (=left aligned)
//       'r' (=right aligned)
//
//     by putting or an 'r' or an 'l' in front of each align character
//
//     From =.;,,)%,// this becomes:
//
//      r=l.l;l,l,r)l%l,r/l/r.l
//
//     Note that an 'l' has been added at the end here.
//
// 5. -Input this last string also
//
// 6. -Then execute the TSE macro l_r_align.s
//
// 7  -Note that each column is left or right aligned after it
//
/*
--- cut here: begin --------------------------------------------------
f =0.0f;sscanf(s,"%f" ,&f );printf("%f\n"    ,f); //1 .234568
lf=0.0 ;sscanf(s,"%lf",&lf);printf("%.15lf\n",lf);//1 .234567890123456
lf=0.0f;sscanf(s,"%f" ,&lf);printf("%.15lf\n",lf);//0 .000000000000000
f =0.0 ;sscanf(s,"%lf",&f );printf("%f\n"    ,f); //70.175720
--- cut here: end ----------------------------------------------------
*/
//
// ===
//
// Yes, very useful:
//
// I used it e.g. with this (simplified) example, to quickly align it more in table like format:
//
// Example:
//
// Before:
//
/*
--- cut here: begin --------------------------------------------------
Option 123: Do something1
Option 4578: Do something2
Option 3: Do something3
Option 1234: Do something4d
--- cut here: end ----------------------------------------------------
*/
//
// Then supply first which character to select:
//
// :
//
// Then supply if it is right or left aligned
//
// :l
//
// That gives as output
//
// After:
//
/*
--- cut here: begin --------------------------------------------------
Option 123 : Do something1
Option 4578: Do something2
Option 3   : Do something3
Option 1234: Do something4
--- cut here: end ----------------------------------------------------
*/
