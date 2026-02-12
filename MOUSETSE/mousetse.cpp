// https://learn.microsoft.com/en-us/windows/win32/learnwin32/mouse-clicks
//
// These macros are defined in the header file
//
//  WindowsX.h
//
// So include this in your C++ program.
//
// ===
//
// WM_LBUTTONDOWN  // Left button down
// WM_LBUTTONUP	   // Left button up
//
// WM_MBUTTONDOWN  // Middle button down
// WM_MBUTTONUP	   // Middle button up
//
// WM_RBUTTONDOWN  // Right button down
// WM_RBUTTONUP	   // Right button up
//
// WM_XBUTTONDOWN  // XBUTTON1 or XBUTTON2 down
// WM_XBUTTONUP	   // XBUTTON1 or XBUTTON2 up
//
// ===
//
// Note:  Recall that the client area is the portion of the window that
//        excludes the frame.
//
// For more information about client areas, see
//
//  What Is a Window?
//
//   https://learn.microsoft.com/en-us/windows/win32/learnwin32/what-is-a-window-
//
// ===
//
// Mouse Coordinates
//
// ===
//
// In all of these messages, the
//
//  lParam
//
//  parameter contains
//
//   the x-coordinates of the mouse pointer
//
//  and the
//
//   the y-coordinates of the mouse pointer.
//
// ===
//
// The lowest 16 bits of lParam contain the x-coordinate
// and the next 16 bits contain the y-coordinate.
//
// ===
//
// Use the macros
//
//  GET_X_LPARAM
// and
//
//  GET_Y_LPARAM
//
//  to unpack
// the coordinates from lParam.
//
// ===
//
// int xPos = GET_X_LPARAM( lParam );
//
// int yPos = GET_Y_LPARAM( lParam );
//
// ===
//
// On 64-bit Windows, lParam is 64-bit value.
//
// The upper 32 bits of lParam are not used.
//
// The MSDN documentation mentions the
//
//  "low-order word" of lParam.
//
// and
//
//  "high-order word" of lParam.
//
// In the 64-bit case, this means the
//
//  low-order of the lower 32 bits
//
// and
//
//  high-order words of the lower 32 bits.
//
// The macros extract the right values,
// so if you use them, you will be safe.
//
// Mouse coordinates are given in pixels, not device-independent pixels
// (DIPs), and are measured relative to the client area of the window.
//
// Coordinates are signed values (plus + or minus -).
//
// Positions above and to the left of the client area have negative coordinates,
// which is important if you track the mouse position outside the window.
//
// We will see how to do that in a later topic, in
//
// 'Capturing Mouse Movement Outside the Window'
//
//  https://learn.microsoft.com/en-us/windows/win32/learnwin32/mouse-movement
//
// ===
//
// Additional Flags
//
// The parameter
//
//  wParam
//
// contains a bitwise OR of flags, indicating the
// state of
//
//  1. -the other mouse buttons and
//  2. -the SHIFT keys and
//  3. -the CTRL keys.
//
//  Flag    Meaning
//  --------------------------------------------
//  MK_CONTROL    The CTRL key is down.
//  --------------------------------------------
//  MK_LBUTTON    The left mouse button is down.
//  --------------------------------------------
//  MK_MBUTTON    The middle mouse button is down.
//  --------------------------------------------
//  MK_RBUTTON    The right mouse button is down.
//  --------------------------------------------
//  MK_SHIFT      The SHIFT key is down.
//  --------------------------------------------
//  MK_XBUTTON1   The XBUTTON1 button is down.
//  MK_XBUTTON2   The XBUTTON2 button is down.
//  --------------------------------------------
//
// The absence of a flag means the corresponding button or key was NOT pressed.
// For example, to test whether the CTRL key is down:
//
// if ( wParam & MK_CONTROL ) {
//  printf( "the CTRL key is down\n";
// }
// else {
//  printf( "the CTRL key is not down (=up)\n";
// }
// //
// if ( wParam & MK_LBUTTON ) {
//  printf( "the LEFT MOUSE BUTTON is down\n";
// }
// else {
//  printf( "the LEFT MOUSE BUTTON is not down (=up)\n";
// }
// //
// if ( wParam & MK_RBUTTON ) {
//  printf( "the RIGHT MOUSE BUTTON is down\n";
// }
// else {
//  printf( "the RIGHT MOUSE BUTTON is not down (=up)\n";
// }
// //
// if ( wParam & MK_MBUTTON ) {
//  printf( "the MIDDLE MOUSE BUTTON is down\n";
// }
// else {
//  printf( "the MIDDLE MOUSE BUTTON is not down (=up)\n";
// }
// //
// if ( wParam & MK_SHIFT ) {
//  printf( "the SHIFT BUTTON is down\n";
// }
// else {
//  printf( "the SHIFT BUTTON is not down (=up)\n";
// }
// //
// if ( wParam & MK_XBUTTON1 ) {
//  printf( "the XBUTTON1 MOUSE BUTTON is down\n";
// }
// else {
//  printf( "the XBUTTON1 MOUSE BUTTON is not down (=up)\n";
// }
// if ( wParam & MK_XBUTTON2 ) {
//  printf( "the XBUTTON2 MOUSE BUTTON is down\n";
// }
// else {
//  printf( "the XBUTTON2 MOUSE BUTTON is not down (=up)\n";
// }
// //
// UINT button = GET_XBUTTON_WPARAM( wParam );
// //
// if ( button == XBUTTON1 ) {
//  printf( "the XBUTTON1 MOUSE BUTTON is clicked\n";
// }
// if ( button == XBUTTON2 ) {
//  printf( "the XBUTTON2 MOUSE BUTTON is clicked\n";
// }
//
// Double clicks
//
// A window does not receive double-click notifications by default.
//
// To receive double clicks, set the flag
//
//  CS_DBLCLKS flag
//
// in the structure
//
//  WNDCLASS
//
// when you register the window class.
//
//  WNDCLASS wc = { };
//
//  wc.style = CS_DBLCLKS;
//
//  /* Set other structure members. */
//
//  RegisterClass( &wc );
//
// If you set the flag
//
//  CS_DBLCLKS
//
// as shown, the window will receive
// double-click notifications.
//
// A double click is indicated by a window
// message with in the name
//
//  "DBLCLK"
//
// In effect, the second WM_LBUTTONDOWN message that would normally be
// generated becomes a WM_LBUTTONDBLCLK message. Equivalent messages are
// defined for right, middle, and XBUTTON buttons.
//
// ===
//
// For example:
//
// A double click on the LEFT mouse button
// produces the following sequence of messages:
//
// 1. WM_LBUTTONDOWN
// 2. WM_LBUTTONUP
// 3. WM_LBUTTONDBLCLK
// 4. WM_LBUTTONUP
//
// ===
//
// For example:
//
// A double click on the RIGHT mouse button
// produces the following sequence of messages:
//
// 1. WM_RBUTTONDOWN
// 2. WM_RBUTTONUP
// 3. WM_RBUTTONDBLCLK
// 4. WM_RBUTTONUP
//
// For example:
//
// A double click on the CEMTER mouse button
// produces the following sequence of messages:
//
// 1. WM_MBUTTONDOWN
// 2. WM_MBUTTONUP
// 3. WM_MBUTTONDBLCLK
// 4  WM_MBUTTONUP
//
// ===
//
// For example:
//
// A double click on the XBUTTON1 mouse button
// produces the following sequence of messages:
//
// 1. WM_XBUTTON1DOWN
// 2. WM_XBUTTON1UP
// 3. WM_XBUTTON1DBLCLK
// 4  WM_XBUTTON1UP
//
// ===
//
// For example:
//
// A double click on the XBUTTON2 mouse button
// produces the following sequence of messages:
//
// 2. WM_XBUTTON2DOWN
// 2. WM_XBUTTON2UP
// 3. WM_XBUTTON2DBLCLK
// 4  WM_XBUTTON2UP
//
// ===
//
// Until you get the double-click message, there is no way to tell that
// the first mouse click is the start of a double click. Therefore, a
// double-click action should continue an action that begins with the
// first mouse click.
//
//  For example, in the Windows Shell, a single click
// selects a folder, while a double click opens the folder.
//
// Mouse Wheel
//
// The following function checks if a mouse wheel is present.
//
// BOOL IsMouseWheelPresent() {
//  return ( GetSystemMetrics(SM_MOUSEWHEELPRESENT ) != 0 );
// }
//
// If the user rotates the mouse wheel, the window with focus receives a message
//
//  WM_MOUSEWHEEL
//
// The wParam parameter of this message contains an integer value
// called the
//
//    delta
//
//   that measures how far the wheel was rotated.
//
// The delta uses arbitrary units, where 120 units is defined as the
// rotation needed to perform one "action."
//
// Of course, the definition of an action depends on your program.
//
//  For example, if the mouse wheel is used to scroll text,
//  each 120 units of rotation would scroll one line of text.
//
//
// The sign (that is a '+' or a '-') of the delta indicates
// the direction of rotation:
//
//  1. -Positive: Rotate forward, away from the user.
//
//  2. -Negative: Rotate backward, toward the user.
//
// The value of the delta is placed in wParam along with some
// additional flags.
//
// Use the macro
//
//  GET_WHEEL_DELTA_WPARAM
//
// to get the value of the delta.
//
// For example:
//
// int delta = GET_WHEEL_DELTA_WPARAM( wParam );
//
// If the mouse wheel has a high resolution, the absolute value of the
// delta might be less than 120. In that case, if it makes sense for the
// action to occur in smaller increments, you can do so. For example, text
// could scroll by increments of less than one line. Otherwise, accumulate
// the total delta until the wheel rotates enough to perform the action.
// Store the unused delta in a variable, and when 120 units accumulate
// (either positive or negative), perform the action.
//
// ===
//
// See: Click Simulation & Detection in C/C++ || Mouse Programming || Easy Programming
//      https://www.youtube.com/watch?v=_FEnCQOl7X0
//
// ===
//
// command line used to compile this mousetse.cpp program:
//
// g:\borland\bcc55\bin Tue 20-12-22 01:23:07>copy f:\bbc\taal\mousetse.cpp & bcc32.exe -Ig:\borland\bcc55\include -Lg:\borland\bcc55\lib mousetse.cpp
//
// ===
//
// compile, then run it using
//
//  start mousetse.exe
//
// ===
//
#include <windows.h>
//
#include <windowsx.h>
//
#include <winuser.h>
//
#include <iostream>
//
#include <conio.h>
//
#include <stdio.h>
//
// ===
//
// https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
//
#define VK_LBUTTON     0x01 // left mouse button
#define VK_RBUTTON     0x02 // right mouse button
#define VK_MBUTTON     0x04 // middle / center mouse button
#define VK_XBUTTON1    0x05 // backward / down mouse button
#define VK_XBUTTON2    0x06 // forward / up mouse button
//
#define VK_CAMCEL      0x03 // cancel
#define VK_BACK        0x08 // backspace
#define VK_TAB         0x09 // tab
#define VK_CLEAR       0x0C // clear
#define VK_RETURN      0x0D // return
#define VK_SHIFT       0x10 // shift
#define VK_CONTROL     0x11 // control
#define VK_MENU        0x12 // alt
#define VK_PAUSE       0x13 // pause
#define VK_CAPITAL     0x14 // caps lock
#define VK_ESCAPE      0x1B // escape
#define VK_SPACE       0x20 // spacebar
#define VK_PRIOR       0x21 // page up
#define VK_NEXT        0x22 // page down
#define VK_END         0x23 // end
#define VK_HOME        0x24 // home
#define VK_LEFT        0x25 // left arrow
#define VK_UP          0x26 // up arrow
#define VK_RIGHT       0x27 // right arrow
#define VK_DOWN        0x28 // down arrow
#define VK_PRINT       0x2A // print
#define VK_EXECUTE     0x2B // execute
#define VK_SNAPSHOT    0x2C // print screen
#define VK_INSERT      0x2D // insert
#define VK_DELETE      0x2E // delete
#define VK_LWIN        0x5B // left windows logo key
#define VK_RWIN        0x5C // right windows logo key
//
// ===
//
int main() {
 //
 // while true
 //
 while ( 1 ) {
  //
  // This function GetAsyncKeyState() can detect the button press from and the keyboard and from the mouse
  // and returns 'true' or 'false'.
  //
  if      ( GetAsyncKeyState( VK_LBUTTON  ) ) { printf( "Left mouse button pressed\n" );  }
  else if ( GetAsyncKeyState( VK_RBUTTON  ) ) { printf( "Right mouse button pressed\n" ); }
  else if ( GetAsyncKeyState( VK_MBUTTON  ) ) { printf( "Middle / Center mouse button pressed\n" ); }
  else if ( GetAsyncKeyState( VK_XBUTTON1 ) ) { printf( "XBUTTON1 / down / backwards mouse button pressed\n" ); }
  else if ( GetAsyncKeyState( VK_XBUTTON2 ) ) { printf( "XBUTTON2 / up / forwards mouse button pressed\n" ); }
  else if ( GetAsyncKeyState( VK_BACK     ) ) { printf( "BACKSPACE key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_CANCEL   ) ) { printf( "CANCEL key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_TAB      ) ) { printf( "TAB key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_RETURN   ) ) { printf( "RETURN key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_SHIFT    ) ) { printf( "SHIFT key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_CONTROL  ) ) { printf( "CONTROL key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_MENU     ) ) { printf( "ALT key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_ESCAPE   ) ) { printf( "ESCAPE LOCK key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_SPACE    ) ) { printf( "SPACEBAR key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_PRIOR    ) ) { printf( "PAGE UP key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_NEXT     ) ) { printf( "PAGE DOWN key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_END      ) ) { printf( "END key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_HOME     ) ) { printf( "HOME key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_LEFT     ) ) { printf( "LEFT ARROW key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_UP       ) ) { printf( "UP ARROW key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_RIGHT    ) ) { printf( "RIGHT ARROW key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_DOWN     ) ) { printf( "DOWN ARROW key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_PRINT    ) ) { printf( "PRINT key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_EXECUTE  ) ) { printf( "EXECUTE key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_SNAPSHOT ) ) { printf( "PRINT SCREEN key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_INSERT   ) ) { printf( "INSERT key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_DELETE   ) ) { printf( "DELETE key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_LWIN     ) ) { printf( "LEFT WINDOWS LOGO key pressed\n" ); }
  else if ( GetAsyncKeyState( VK_RWIN     ) ) { printf( "RIGHT WINDOWS LOGO key pressed\n" ); }
  //
 }
 getch();
 //
}
