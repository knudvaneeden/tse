@echo off
colormsg " This utility uses the T/H/C CLOCK program to display the time, then "
colormsg " display how much time it took the rightmost clock to execute, then  "
colormsg " how much time it took to CLOCK the time display, and so on... "
colormsg -c0/7 " THIS MAKES A GOOD BASIC BENCHMARK FOR OVERALL SYSTEM PERFORMANCE "
d /thc
clock clock clock clock clock clock
