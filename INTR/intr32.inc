/* INTR32.INC - TSE Pro 4.50 interface for intr32.dll */

dll "intr32.dll"
    integer proc IntrFindFirst()
    integer proc IntrFindNext()
    integer proc IntrGetNameLength()
    integer proc IntrGetNameChar(integer indexI)
    integer proc IntrCloseFind()
    integer proc IntrSetConsoleCursor(integer sizeI, integer visibleI)
end

