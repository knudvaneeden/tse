// Project Euler - Problem 107: Minimal Network
// Find maximum saving = original network weight minus MST weight.
// Algorithm: Kruskal's MST using Union-Find, edges sorted ascending by weight.
// Network: 40 vertices, stored as 40x40 adjacency matrix.
// Place 0107_network.txt at c:\temp\p107_network.txt before running.
//
// TSE SAL conventions:
//   - No arrays; all collections stored in temp buffers (one value per line)
//   - No floats; INTEGER and STRING only
//   - Reserved words never used as variable names (val, pos, left, right, etc.)
//   - return() always has parentheses
//   - Output via Warn() and CopyToWinClip() of final answer only
//   - Global vars prefixed with g, uppercase last letter
//   - Proc names: noun-verb style
//   - version: <version>1.0.0.0.2</version>

// --------------------------------------------------------------------------
// Globals
// --------------------------------------------------------------------------
integer gEdgeBufG   = 0
integer gParentBufG = 0
integer gRankBufG   = 0
integer gNumVertsG  = 40

// --------------------------------------------------------------------------
// Read integer stored at line (nNode+1) in the given buffer
// --------------------------------------------------------------------------
integer proc BufLineRead( integer nBufId, integer nNode )
    string sTmp[20]
    GotoBufferId( nBufId )
    GotoLine( nNode + 1 )
    sTmp = GetText( 1, CurrLineLen() )
    return( Val( sTmp ) )
end

// --------------------------------------------------------------------------
// Write integer to line (nNode+1) in the given buffer
// --------------------------------------------------------------------------
proc BufLineWrite( integer nBufId, integer nNode, integer nNewVal )
    GotoBufferId( nBufId )
    GotoLine( nNode + 1 )
    BegLine()
    KillToEol()
    InsertText( Str( nNewVal ) )
end

// --------------------------------------------------------------------------
// Union-Find: find root (iterative, clean two-phase)
// --------------------------------------------------------------------------
integer proc UfFind( integer nNode )
    integer nCur
    integer nParent
    integer nRoot
    // Phase 1: walk up to root
    nCur = nNode
    loop
        nParent = BufLineRead( gParentBufG, nCur )
        if nParent == nCur
            break
        endif
        nCur = nParent
    endloop
    nRoot = nCur
    // Phase 2: path compression - point every node on path to root
    nCur = nNode
    while nCur <> nRoot
        nParent = BufLineRead( gParentBufG, nCur )
        BufLineWrite( gParentBufG, nCur, nRoot )
        nCur = nParent
    endwhile
    return( nRoot )
end

// --------------------------------------------------------------------------
// Union-Find: union by rank
// Returns 1 if merged (different components), 0 if already same component
// --------------------------------------------------------------------------
integer proc UfUnion( integer nA, integer nB )
    integer nRootA
    integer nRootB
    integer nRankA
    integer nRankB
    nRootA = UfFind( nA )
    nRootB = UfFind( nB )
    if nRootA == nRootB
        return( 0 )
    endif
    nRankA = BufLineRead( gRankBufG, nRootA )
    nRankB = BufLineRead( gRankBufG, nRootB )
    if nRankA < nRankB
        BufLineWrite( gParentBufG, nRootA, nRootB )
    elseif nRankA > nRankB
        BufLineWrite( gParentBufG, nRootB, nRootA )
    else
        BufLineWrite( gParentBufG, nRootB, nRootA )
        BufLineWrite( gRankBufG,   nRootA, nRankA + 1 )
    endif
    return( 1 )
end

// --------------------------------------------------------------------------
// Main
// --------------------------------------------------------------------------
proc Main()
    integer nRow
    integer nCol
    integer nW
    integer nTotalWeight
    integer nMstWeight
    integer nSaving
    integer nEdgeCount
    integer nMstEdges
    integer nAdded
    integer nLineBuf
    integer nIdx
    integer nTok
    string  sLine[255]
    string  sToken[20]
    string  sEdgeLine[30]
    string  sResult[20]

    // ----- Create Union-Find and edge buffers -----
    gParentBufG = CreateTempBuffer()
    gRankBufG   = CreateTempBuffer()
    gEdgeBufG   = CreateTempBuffer()

    // Initialise: parent[i] = i, rank[i] = 0  for i = 0..39
    GotoBufferId( gParentBufG )
    nIdx = 0
    while nIdx < gNumVertsG
        AddLine( Str( nIdx ) )
        nIdx = nIdx + 1
    endwhile

    GotoBufferId( gRankBufG )
    nIdx = 0
    while nIdx < gNumVertsG
        AddLine( "0" )
        nIdx = nIdx + 1
    endwhile

    // ----- Load network file -----
    nLineBuf = CreateTempBuffer()
    GotoBufferId( nLineBuf )
    if not InsertFile( "p107_network.txt", _DONT_PROMPT_ )
        Warn( "ERROR: Cannot open p107_network.txt" )
        AbandonFile( nLineBuf )
        AbandonFile( gEdgeBufG )
        AbandonFile( gParentBufG )
        AbandonFile( gRankBufG )
        return()
    endif

    // ----- Parse matrix, collect edges (upper triangle only) -----
    nTotalWeight = 0
    nEdgeCount   = 0

    nRow = 0
    while nRow < gNumVertsG
        GotoBufferId( nLineBuf )
        GotoLine( nRow + 1 )
        sLine = GetText( 1, CurrLineLen() )

        nCol = 0
        nTok = 1
        while nCol < gNumVertsG
            sToken = GetToken( sLine, ",", nTok )
            nTok   = nTok + 1
            if sToken <> "-"
                nW = Val( sToken )
                if nCol > nRow
                    // upper triangle only: each undirected edge counted once
                    nTotalWeight = nTotalWeight + nW
                    // zero-pad weight (5 digits) so lexicographic sort = numeric sort
                    sEdgeLine = Format( nW:5:"0" ) + " " +
                                Format( nRow:2:"0" ) + " " +
                                Format( nCol:2:"0" )
                    GotoBufferId( gEdgeBufG )
                    AddLine( sEdgeLine )
                    nEdgeCount = nEdgeCount + 1
                endif
            endif
            nCol = nCol + 1
        endwhile

        nRow = nRow + 1
    endwhile

    // ----- Sort edge buffer ascending by weight -----
    GotoBufferId( gEdgeBufG )
    BegFile()
    MarkLine()
    EndFile()
    Sort( _IGNORE_CASE_ )
    UnMarkBlock()

    // ----- Kruskal's MST -----
    nMstWeight = 0
    nMstEdges  = 0
    nIdx       = 1

    while nMstEdges < ( gNumVertsG - 1 ) and nIdx <= nEdgeCount
        GotoBufferId( gEdgeBufG )
        GotoLine( nIdx )
        sLine  = GetText( 1, CurrLineLen() )

        sToken = GetToken( sLine, " ", 1 )
        nW     = Val( sToken )
        sToken = GetToken( sLine, " ", 2 )
        nRow   = Val( sToken )
        sToken = GetToken( sLine, " ", 3 )
        nCol   = Val( sToken )

        nAdded = UfUnion( nRow, nCol )
        if nAdded
            nMstWeight = nMstWeight + nW
            nMstEdges  = nMstEdges + 1
        endif

        nIdx = nIdx + 1
    endwhile

    nSaving = nTotalWeight - nMstWeight
    sResult = Str( nSaving )

    CopyToWinClip( sResult )

    Warn( "P107 Minimal Network"                + Chr(13) +
          "Total weight : " + Str( nTotalWeight ) + Chr(13) +
          "MST weight   : " + Str( nMstWeight )   + Chr(13) +
          "MST edges    : " + Str( nMstEdges )     + Chr(13) +
          "Max saving   : " + sResult )

    AbandonFile( nLineBuf )
    AbandonFile( gEdgeBufG )
    AbandonFile( gParentBufG )
    AbandonFile( gRankBufG )
end
