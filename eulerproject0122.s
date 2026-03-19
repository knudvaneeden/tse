// TSE/32
// Euler122.s
// Efficient exponentiation - Project Euler problem 122
// <version>1.0.0.0.0</version>
// Created by GPT-5.4 Thinking for statistics/history purposes.
//
// Computes sum_{k=1..200} m(k), where m(k) is the minimum number of
// multiplications needed to compute n^k.
//
// This program uses a Brauer-chain depth-first search:
// every new exponent is formed as the current largest exponent plus an
// earlier exponent from the chain.
// For n <= 2500 this restriction still gives the correct shortest lengths,
// so it is valid for Project Euler 122 with n <= 200.

integer gChain01I = 0
integer gChain02I = 0
integer gChain03I = 0
integer gChain04I = 0
integer gChain05I = 0
integer gChain06I = 0
integer gChain07I = 0
integer gChain08I = 0
integer gChain09I = 0
integer gChain10I = 0
integer gChain11I = 0
integer gChain12I = 0
integer gBest001I = 999
integer gBest002I = 999
integer gBest003I = 999
integer gBest004I = 999
integer gBest005I = 999
integer gBest006I = 999
integer gBest007I = 999
integer gBest008I = 999
integer gBest009I = 999
integer gBest010I = 999
integer gBest011I = 999
integer gBest012I = 999
integer gBest013I = 999
integer gBest014I = 999
integer gBest015I = 999
integer gBest016I = 999
integer gBest017I = 999
integer gBest018I = 999
integer gBest019I = 999
integer gBest020I = 999
integer gBest021I = 999
integer gBest022I = 999
integer gBest023I = 999
integer gBest024I = 999
integer gBest025I = 999
integer gBest026I = 999
integer gBest027I = 999
integer gBest028I = 999
integer gBest029I = 999
integer gBest030I = 999
integer gBest031I = 999
integer gBest032I = 999
integer gBest033I = 999
integer gBest034I = 999
integer gBest035I = 999
integer gBest036I = 999
integer gBest037I = 999
integer gBest038I = 999
integer gBest039I = 999
integer gBest040I = 999
integer gBest041I = 999
integer gBest042I = 999
integer gBest043I = 999
integer gBest044I = 999
integer gBest045I = 999
integer gBest046I = 999
integer gBest047I = 999
integer gBest048I = 999
integer gBest049I = 999
integer gBest050I = 999
integer gBest051I = 999
integer gBest052I = 999
integer gBest053I = 999
integer gBest054I = 999
integer gBest055I = 999
integer gBest056I = 999
integer gBest057I = 999
integer gBest058I = 999
integer gBest059I = 999
integer gBest060I = 999
integer gBest061I = 999
integer gBest062I = 999
integer gBest063I = 999
integer gBest064I = 999
integer gBest065I = 999
integer gBest066I = 999
integer gBest067I = 999
integer gBest068I = 999
integer gBest069I = 999
integer gBest070I = 999
integer gBest071I = 999
integer gBest072I = 999
integer gBest073I = 999
integer gBest074I = 999
integer gBest075I = 999
integer gBest076I = 999
integer gBest077I = 999
integer gBest078I = 999
integer gBest079I = 999
integer gBest080I = 999
integer gBest081I = 999
integer gBest082I = 999
integer gBest083I = 999
integer gBest084I = 999
integer gBest085I = 999
integer gBest086I = 999
integer gBest087I = 999
integer gBest088I = 999
integer gBest089I = 999
integer gBest090I = 999
integer gBest091I = 999
integer gBest092I = 999
integer gBest093I = 999
integer gBest094I = 999
integer gBest095I = 999
integer gBest096I = 999
integer gBest097I = 999
integer gBest098I = 999
integer gBest099I = 999
integer gBest100I = 999
integer gBest101I = 999
integer gBest102I = 999
integer gBest103I = 999
integer gBest104I = 999
integer gBest105I = 999
integer gBest106I = 999
integer gBest107I = 999
integer gBest108I = 999
integer gBest109I = 999
integer gBest110I = 999
integer gBest111I = 999
integer gBest112I = 999
integer gBest113I = 999
integer gBest114I = 999
integer gBest115I = 999
integer gBest116I = 999
integer gBest117I = 999
integer gBest118I = 999
integer gBest119I = 999
integer gBest120I = 999
integer gBest121I = 999
integer gBest122I = 999
integer gBest123I = 999
integer gBest124I = 999
integer gBest125I = 999
integer gBest126I = 999
integer gBest127I = 999
integer gBest128I = 999
integer gBest129I = 999
integer gBest130I = 999
integer gBest131I = 999
integer gBest132I = 999
integer gBest133I = 999
integer gBest134I = 999
integer gBest135I = 999
integer gBest136I = 999
integer gBest137I = 999
integer gBest138I = 999
integer gBest139I = 999
integer gBest140I = 999
integer gBest141I = 999
integer gBest142I = 999
integer gBest143I = 999
integer gBest144I = 999
integer gBest145I = 999
integer gBest146I = 999
integer gBest147I = 999
integer gBest148I = 999
integer gBest149I = 999
integer gBest150I = 999
integer gBest151I = 999
integer gBest152I = 999
integer gBest153I = 999
integer gBest154I = 999
integer gBest155I = 999
integer gBest156I = 999
integer gBest157I = 999
integer gBest158I = 999
integer gBest159I = 999
integer gBest160I = 999
integer gBest161I = 999
integer gBest162I = 999
integer gBest163I = 999
integer gBest164I = 999
integer gBest165I = 999
integer gBest166I = 999
integer gBest167I = 999
integer gBest168I = 999
integer gBest169I = 999
integer gBest170I = 999
integer gBest171I = 999
integer gBest172I = 999
integer gBest173I = 999
integer gBest174I = 999
integer gBest175I = 999
integer gBest176I = 999
integer gBest177I = 999
integer gBest178I = 999
integer gBest179I = 999
integer gBest180I = 999
integer gBest181I = 999
integer gBest182I = 999
integer gBest183I = 999
integer gBest184I = 999
integer gBest185I = 999
integer gBest186I = 999
integer gBest187I = 999
integer gBest188I = 999
integer gBest189I = 999
integer gBest190I = 999
integer gBest191I = 999
integer gBest192I = 999
integer gBest193I = 999
integer gBest194I = 999
integer gBest195I = 999
integer gBest196I = 999
integer gBest197I = 999
integer gBest198I = 999
integer gBest199I = 999
integer gBest200I = 999

integer proc ChainGet( integer indexI )
 case indexI
  when 1 return( gChain01I )
  when 2 return( gChain02I )
  when 3 return( gChain03I )
  when 4 return( gChain04I )
  when 5 return( gChain05I )
  when 6 return( gChain06I )
  when 7 return( gChain07I )
  when 8 return( gChain08I )
  when 9 return( gChain09I )
  when 10 return( gChain10I )
  when 11 return( gChain11I )
  when 12 return( gChain12I )
  otherwise return( 0 )
 endcase
end

proc ChainSet( integer indexI, integer valueI )
 case indexI
  when 1 gChain01I = valueI
  when 2 gChain02I = valueI
  when 3 gChain03I = valueI
  when 4 gChain04I = valueI
  when 5 gChain05I = valueI
  when 6 gChain06I = valueI
  when 7 gChain07I = valueI
  when 8 gChain08I = valueI
  when 9 gChain09I = valueI
  when 10 gChain10I = valueI
  when 11 gChain11I = valueI
  when 12 gChain12I = valueI
 endcase
end

integer proc BestGet( integer exponentI )
 case exponentI
  when 1 return( gBest001I )
  when 2 return( gBest002I )
  when 3 return( gBest003I )
  when 4 return( gBest004I )
  when 5 return( gBest005I )
  when 6 return( gBest006I )
  when 7 return( gBest007I )
  when 8 return( gBest008I )
  when 9 return( gBest009I )
  when 10 return( gBest010I )
  when 11 return( gBest011I )
  when 12 return( gBest012I )
  when 13 return( gBest013I )
  when 14 return( gBest014I )
  when 15 return( gBest015I )
  when 16 return( gBest016I )
  when 17 return( gBest017I )
  when 18 return( gBest018I )
  when 19 return( gBest019I )
  when 20 return( gBest020I )
  when 21 return( gBest021I )
  when 22 return( gBest022I )
  when 23 return( gBest023I )
  when 24 return( gBest024I )
  when 25 return( gBest025I )
  when 26 return( gBest026I )
  when 27 return( gBest027I )
  when 28 return( gBest028I )
  when 29 return( gBest029I )
  when 30 return( gBest030I )
  when 31 return( gBest031I )
  when 32 return( gBest032I )
  when 33 return( gBest033I )
  when 34 return( gBest034I )
  when 35 return( gBest035I )
  when 36 return( gBest036I )
  when 37 return( gBest037I )
  when 38 return( gBest038I )
  when 39 return( gBest039I )
  when 40 return( gBest040I )
  when 41 return( gBest041I )
  when 42 return( gBest042I )
  when 43 return( gBest043I )
  when 44 return( gBest044I )
  when 45 return( gBest045I )
  when 46 return( gBest046I )
  when 47 return( gBest047I )
  when 48 return( gBest048I )
  when 49 return( gBest049I )
  when 50 return( gBest050I )
  when 51 return( gBest051I )
  when 52 return( gBest052I )
  when 53 return( gBest053I )
  when 54 return( gBest054I )
  when 55 return( gBest055I )
  when 56 return( gBest056I )
  when 57 return( gBest057I )
  when 58 return( gBest058I )
  when 59 return( gBest059I )
  when 60 return( gBest060I )
  when 61 return( gBest061I )
  when 62 return( gBest062I )
  when 63 return( gBest063I )
  when 64 return( gBest064I )
  when 65 return( gBest065I )
  when 66 return( gBest066I )
  when 67 return( gBest067I )
  when 68 return( gBest068I )
  when 69 return( gBest069I )
  when 70 return( gBest070I )
  when 71 return( gBest071I )
  when 72 return( gBest072I )
  when 73 return( gBest073I )
  when 74 return( gBest074I )
  when 75 return( gBest075I )
  when 76 return( gBest076I )
  when 77 return( gBest077I )
  when 78 return( gBest078I )
  when 79 return( gBest079I )
  when 80 return( gBest080I )
  when 81 return( gBest081I )
  when 82 return( gBest082I )
  when 83 return( gBest083I )
  when 84 return( gBest084I )
  when 85 return( gBest085I )
  when 86 return( gBest086I )
  when 87 return( gBest087I )
  when 88 return( gBest088I )
  when 89 return( gBest089I )
  when 90 return( gBest090I )
  when 91 return( gBest091I )
  when 92 return( gBest092I )
  when 93 return( gBest093I )
  when 94 return( gBest094I )
  when 95 return( gBest095I )
  when 96 return( gBest096I )
  when 97 return( gBest097I )
  when 98 return( gBest098I )
  when 99 return( gBest099I )
  when 100 return( gBest100I )
  when 101 return( gBest101I )
  when 102 return( gBest102I )
  when 103 return( gBest103I )
  when 104 return( gBest104I )
  when 105 return( gBest105I )
  when 106 return( gBest106I )
  when 107 return( gBest107I )
  when 108 return( gBest108I )
  when 109 return( gBest109I )
  when 110 return( gBest110I )
  when 111 return( gBest111I )
  when 112 return( gBest112I )
  when 113 return( gBest113I )
  when 114 return( gBest114I )
  when 115 return( gBest115I )
  when 116 return( gBest116I )
  when 117 return( gBest117I )
  when 118 return( gBest118I )
  when 119 return( gBest119I )
  when 120 return( gBest120I )
  when 121 return( gBest121I )
  when 122 return( gBest122I )
  when 123 return( gBest123I )
  when 124 return( gBest124I )
  when 125 return( gBest125I )
  when 126 return( gBest126I )
  when 127 return( gBest127I )
  when 128 return( gBest128I )
  when 129 return( gBest129I )
  when 130 return( gBest130I )
  when 131 return( gBest131I )
  when 132 return( gBest132I )
  when 133 return( gBest133I )
  when 134 return( gBest134I )
  when 135 return( gBest135I )
  when 136 return( gBest136I )
  when 137 return( gBest137I )
  when 138 return( gBest138I )
  when 139 return( gBest139I )
  when 140 return( gBest140I )
  when 141 return( gBest141I )
  when 142 return( gBest142I )
  when 143 return( gBest143I )
  when 144 return( gBest144I )
  when 145 return( gBest145I )
  when 146 return( gBest146I )
  when 147 return( gBest147I )
  when 148 return( gBest148I )
  when 149 return( gBest149I )
  when 150 return( gBest150I )
  when 151 return( gBest151I )
  when 152 return( gBest152I )
  when 153 return( gBest153I )
  when 154 return( gBest154I )
  when 155 return( gBest155I )
  when 156 return( gBest156I )
  when 157 return( gBest157I )
  when 158 return( gBest158I )
  when 159 return( gBest159I )
  when 160 return( gBest160I )
  when 161 return( gBest161I )
  when 162 return( gBest162I )
  when 163 return( gBest163I )
  when 164 return( gBest164I )
  when 165 return( gBest165I )
  when 166 return( gBest166I )
  when 167 return( gBest167I )
  when 168 return( gBest168I )
  when 169 return( gBest169I )
  when 170 return( gBest170I )
  when 171 return( gBest171I )
  when 172 return( gBest172I )
  when 173 return( gBest173I )
  when 174 return( gBest174I )
  when 175 return( gBest175I )
  when 176 return( gBest176I )
  when 177 return( gBest177I )
  when 178 return( gBest178I )
  when 179 return( gBest179I )
  when 180 return( gBest180I )
  when 181 return( gBest181I )
  when 182 return( gBest182I )
  when 183 return( gBest183I )
  when 184 return( gBest184I )
  when 185 return( gBest185I )
  when 186 return( gBest186I )
  when 187 return( gBest187I )
  when 188 return( gBest188I )
  when 189 return( gBest189I )
  when 190 return( gBest190I )
  when 191 return( gBest191I )
  when 192 return( gBest192I )
  when 193 return( gBest193I )
  when 194 return( gBest194I )
  when 195 return( gBest195I )
  when 196 return( gBest196I )
  when 197 return( gBest197I )
  when 198 return( gBest198I )
  when 199 return( gBest199I )
  when 200 return( gBest200I )
  otherwise return( 999 )
 endcase
end

proc BestSet( integer exponentI, integer valueI )
 case exponentI
  when 1 gBest001I = valueI
  when 2 gBest002I = valueI
  when 3 gBest003I = valueI
  when 4 gBest004I = valueI
  when 5 gBest005I = valueI
  when 6 gBest006I = valueI
  when 7 gBest007I = valueI
  when 8 gBest008I = valueI
  when 9 gBest009I = valueI
  when 10 gBest010I = valueI
  when 11 gBest011I = valueI
  when 12 gBest012I = valueI
  when 13 gBest013I = valueI
  when 14 gBest014I = valueI
  when 15 gBest015I = valueI
  when 16 gBest016I = valueI
  when 17 gBest017I = valueI
  when 18 gBest018I = valueI
  when 19 gBest019I = valueI
  when 20 gBest020I = valueI
  when 21 gBest021I = valueI
  when 22 gBest022I = valueI
  when 23 gBest023I = valueI
  when 24 gBest024I = valueI
  when 25 gBest025I = valueI
  when 26 gBest026I = valueI
  when 27 gBest027I = valueI
  when 28 gBest028I = valueI
  when 29 gBest029I = valueI
  when 30 gBest030I = valueI
  when 31 gBest031I = valueI
  when 32 gBest032I = valueI
  when 33 gBest033I = valueI
  when 34 gBest034I = valueI
  when 35 gBest035I = valueI
  when 36 gBest036I = valueI
  when 37 gBest037I = valueI
  when 38 gBest038I = valueI
  when 39 gBest039I = valueI
  when 40 gBest040I = valueI
  when 41 gBest041I = valueI
  when 42 gBest042I = valueI
  when 43 gBest043I = valueI
  when 44 gBest044I = valueI
  when 45 gBest045I = valueI
  when 46 gBest046I = valueI
  when 47 gBest047I = valueI
  when 48 gBest048I = valueI
  when 49 gBest049I = valueI
  when 50 gBest050I = valueI
  when 51 gBest051I = valueI
  when 52 gBest052I = valueI
  when 53 gBest053I = valueI
  when 54 gBest054I = valueI
  when 55 gBest055I = valueI
  when 56 gBest056I = valueI
  when 57 gBest057I = valueI
  when 58 gBest058I = valueI
  when 59 gBest059I = valueI
  when 60 gBest060I = valueI
  when 61 gBest061I = valueI
  when 62 gBest062I = valueI
  when 63 gBest063I = valueI
  when 64 gBest064I = valueI
  when 65 gBest065I = valueI
  when 66 gBest066I = valueI
  when 67 gBest067I = valueI
  when 68 gBest068I = valueI
  when 69 gBest069I = valueI
  when 70 gBest070I = valueI
  when 71 gBest071I = valueI
  when 72 gBest072I = valueI
  when 73 gBest073I = valueI
  when 74 gBest074I = valueI
  when 75 gBest075I = valueI
  when 76 gBest076I = valueI
  when 77 gBest077I = valueI
  when 78 gBest078I = valueI
  when 79 gBest079I = valueI
  when 80 gBest080I = valueI
  when 81 gBest081I = valueI
  when 82 gBest082I = valueI
  when 83 gBest083I = valueI
  when 84 gBest084I = valueI
  when 85 gBest085I = valueI
  when 86 gBest086I = valueI
  when 87 gBest087I = valueI
  when 88 gBest088I = valueI
  when 89 gBest089I = valueI
  when 90 gBest090I = valueI
  when 91 gBest091I = valueI
  when 92 gBest092I = valueI
  when 93 gBest093I = valueI
  when 94 gBest094I = valueI
  when 95 gBest095I = valueI
  when 96 gBest096I = valueI
  when 97 gBest097I = valueI
  when 98 gBest098I = valueI
  when 99 gBest099I = valueI
  when 100 gBest100I = valueI
  when 101 gBest101I = valueI
  when 102 gBest102I = valueI
  when 103 gBest103I = valueI
  when 104 gBest104I = valueI
  when 105 gBest105I = valueI
  when 106 gBest106I = valueI
  when 107 gBest107I = valueI
  when 108 gBest108I = valueI
  when 109 gBest109I = valueI
  when 110 gBest110I = valueI
  when 111 gBest111I = valueI
  when 112 gBest112I = valueI
  when 113 gBest113I = valueI
  when 114 gBest114I = valueI
  when 115 gBest115I = valueI
  when 116 gBest116I = valueI
  when 117 gBest117I = valueI
  when 118 gBest118I = valueI
  when 119 gBest119I = valueI
  when 120 gBest120I = valueI
  when 121 gBest121I = valueI
  when 122 gBest122I = valueI
  when 123 gBest123I = valueI
  when 124 gBest124I = valueI
  when 125 gBest125I = valueI
  when 126 gBest126I = valueI
  when 127 gBest127I = valueI
  when 128 gBest128I = valueI
  when 129 gBest129I = valueI
  when 130 gBest130I = valueI
  when 131 gBest131I = valueI
  when 132 gBest132I = valueI
  when 133 gBest133I = valueI
  when 134 gBest134I = valueI
  when 135 gBest135I = valueI
  when 136 gBest136I = valueI
  when 137 gBest137I = valueI
  when 138 gBest138I = valueI
  when 139 gBest139I = valueI
  when 140 gBest140I = valueI
  when 141 gBest141I = valueI
  when 142 gBest142I = valueI
  when 143 gBest143I = valueI
  when 144 gBest144I = valueI
  when 145 gBest145I = valueI
  when 146 gBest146I = valueI
  when 147 gBest147I = valueI
  when 148 gBest148I = valueI
  when 149 gBest149I = valueI
  when 150 gBest150I = valueI
  when 151 gBest151I = valueI
  when 152 gBest152I = valueI
  when 153 gBest153I = valueI
  when 154 gBest154I = valueI
  when 155 gBest155I = valueI
  when 156 gBest156I = valueI
  when 157 gBest157I = valueI
  when 158 gBest158I = valueI
  when 159 gBest159I = valueI
  when 160 gBest160I = valueI
  when 161 gBest161I = valueI
  when 162 gBest162I = valueI
  when 163 gBest163I = valueI
  when 164 gBest164I = valueI
  when 165 gBest165I = valueI
  when 166 gBest166I = valueI
  when 167 gBest167I = valueI
  when 168 gBest168I = valueI
  when 169 gBest169I = valueI
  when 170 gBest170I = valueI
  when 171 gBest171I = valueI
  when 172 gBest172I = valueI
  when 173 gBest173I = valueI
  when 174 gBest174I = valueI
  when 175 gBest175I = valueI
  when 176 gBest176I = valueI
  when 177 gBest177I = valueI
  when 178 gBest178I = valueI
  when 179 gBest179I = valueI
  when 180 gBest180I = valueI
  when 181 gBest181I = valueI
  when 182 gBest182I = valueI
  when 183 gBest183I = valueI
  when 184 gBest184I = valueI
  when 185 gBest185I = valueI
  when 186 gBest186I = valueI
  when 187 gBest187I = valueI
  when 188 gBest188I = valueI
  when 189 gBest189I = valueI
  when 190 gBest190I = valueI
  when 191 gBest191I = valueI
  when 192 gBest192I = valueI
  when 193 gBest193I = valueI
  when 194 gBest194I = valueI
  when 195 gBest195I = valueI
  when 196 gBest196I = valueI
  when 197 gBest197I = valueI
  when 198 gBest198I = valueI
  when 199 gBest199I = valueI
  when 200 gBest200I = valueI
 endcase
end

proc InitializeBest()
 integer exponentI = 0
 for exponentI = 1 to 200
  BestSet( exponentI, 999 )
 endfor
 BestSet( 1, 0 )
end

proc SearchChains( integer depthI, integer depthLimitI )
 integer indexI = 0
 integer lastExponentI = 0
 integer nextExponentI = 0

 lastExponentI = ChainGet( depthI + 1 )

 if depthI > BestGet( lastExponentI )
  return()
 endif

 if depthI < BestGet( lastExponentI )
  BestSet( lastExponentI, depthI )
 endif

 if depthI == depthLimitI
  return()
 endif

 for indexI = depthI + 1 downto 1
  nextExponentI = lastExponentI + ChainGet( indexI )
  if nextExponentI <= 200
   if depthI + 1 <= BestGet( nextExponentI )
    ChainSet( depthI + 2, nextExponentI )
    SearchChains( depthI + 1, depthLimitI )
   endif
  endif
 endfor
end

integer proc SolveEuler122()
 integer depthLimitI = 0
 integer exponentI = 0
 integer sumI = 0

 InitializeBest()
 ChainSet( 1, 1 )

 for depthLimitI = 1 to 11
  SearchChains( 0, depthLimitI )
 endfor

 sumI = 0
 for exponentI = 1 to 200
  sumI = sumI + BestGet( exponentI )
 endfor

 return( sumI )
end

PROC Main()
 string resultS[255] = ""
 integer answerI = 0

 answerI = SolveEuler122()
 resultS = Str( answerI )

 CopyToWinClip( resultS )
 Warn( resultS )
END
