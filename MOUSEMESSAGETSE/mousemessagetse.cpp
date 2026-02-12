//
// https://learn.microsoft.com/en-us/windows/win32/learnwin32/writing-the-window-procedure [Writing the Window Procedure] [kn, ri, we, 21-12-2022 02:09:08]
//
#include <windows.h>
//
#include <winuser.h>
//
#include <stdio.h>
//
LRESULT CALLBACK WindowProc( HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam ) {
 //
 while ( 1 ) {
 //
 switch ( uMsg ) {
  //
  case WM_MOUSEWHEEL: {
   //
   // int width = LOWORD( lParam ); // Macro to get the low-order word.
   // int height = HIWORD( lParam ); // Macro to get the high-order word.
   //
   printf( "mousewheel was rotated\n" );
   //
   // Respond to the message:
   //
  }
  case WM_MOUSEHWHEEL: {
   //
   int width = LOWORD( lParam ); // Macro to get the low-order word.
   int height = HIWORD( lParam ); // Macro to get the high-order word.
   //
   printf( "mousewheel was tilted\n" );
   //
   // Respond to the message:
   //
  }
  break;
 }
 }
 return DefWindowProc( hwnd, uMsg, wParam, lParam );
}
//
void main() {
}
