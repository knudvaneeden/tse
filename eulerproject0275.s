// Version: 6
// History:
// Created by Google Gemini (Pro mode)
// V2: Moved all variable declarations to immediately follow function headers.
// V3: Added mandatory max length specifier [255] to all string declarations.
// V4: Replaced invalid '!=' operator with '<>'.
// V5: Fully optimized integer-only bitmask and array implementation based on Redelmeier's algorithm.
// V6: Fixed 'case' and statement separation syntax. Removed invalid '|' separators.

integer total_N = 0
integer total_sym = 0

// Bitmask grid for 18 rows. x ranges 0..34.
// x < 18 stored in sX_0, x >= 18 stored in sX_1
integer s0_0=0, s0_1=0
integer s1_0=0, s1_1=0
integer s2_0=0, s2_1=0
integer s3_0=0, s3_1=0
integer s4_0=0, s4_1=0
integer s5_0=0, s5_1=0
integer s6_0=0, s6_1=0
integer s7_0=0, s7_1=0
integer s8_0=0, s8_1=0
integer s9_0=0, s9_1=0
integer s10_0=0, s10_1=0
integer s11_0=0, s11_1=0
integer s12_0=0, s12_1=0
integer s13_0=0, s13_1=0
integer s14_0=0, s14_1=0
integer s15_0=0, s15_1=0
integer s16_0=0, s16_1=0
integer s17_0=0, s17_1=0

// Global Fast Integer Queue (up to 200 elements, safe bound for order 18)
integer Q_1=0, Q_2=0, Q_3=0, Q_4=0, Q_5=0, Q_6=0, Q_7=0, Q_8=0, Q_9=0, Q_10=0
integer Q_11=0, Q_12=0, Q_13=0, Q_14=0, Q_15=0, Q_16=0, Q_17=0, Q_18=0, Q_19=0, Q_20=0
integer Q_21=0, Q_22=0, Q_23=0, Q_24=0, Q_25=0, Q_26=0, Q_27=0, Q_28=0, Q_29=0, Q_30=0
integer Q_31=0, Q_32=0, Q_33=0, Q_34=0, Q_35=0, Q_36=0, Q_37=0, Q_38=0, Q_39=0, Q_40=0
integer Q_41=0, Q_42=0, Q_43=0, Q_44=0, Q_45=0, Q_46=0, Q_47=0, Q_48=0, Q_49=0, Q_50=0
integer Q_51=0, Q_52=0, Q_53=0, Q_54=0, Q_55=0, Q_56=0, Q_57=0, Q_58=0, Q_59=0, Q_60=0
integer Q_61=0, Q_62=0, Q_63=0, Q_64=0, Q_65=0, Q_66=0, Q_67=0, Q_68=0, Q_69=0, Q_70=0
integer Q_71=0, Q_72=0, Q_73=0, Q_74=0, Q_75=0, Q_76=0, Q_77=0, Q_78=0, Q_79=0, Q_80=0
integer Q_81=0, Q_82=0, Q_83=0, Q_84=0, Q_85=0, Q_86=0, Q_87=0, Q_88=0, Q_89=0, Q_90=0
integer Q_91=0, Q_92=0, Q_93=0, Q_94=0, Q_95=0, Q_96=0, Q_97=0, Q_98=0, Q_99=0, Q_100=0
integer Q_101=0, Q_102=0, Q_103=0, Q_104=0, Q_105=0, Q_106=0, Q_107=0, Q_108=0, Q_109=0, Q_110=0
integer Q_111=0, Q_112=0, Q_113=0, Q_114=0, Q_115=0, Q_116=0, Q_117=0, Q_118=0, Q_119=0, Q_120=0
integer Q_121=0, Q_122=0, Q_123=0, Q_124=0, Q_125=0, Q_126=0, Q_127=0, Q_128=0, Q_129=0, Q_130=0
integer Q_131=0, Q_132=0, Q_133=0, Q_134=0, Q_135=0, Q_136=0, Q_137=0, Q_138=0, Q_139=0, Q_140=0
integer Q_141=0, Q_142=0, Q_143=0, Q_144=0, Q_145=0, Q_146=0, Q_147=0, Q_148=0, Q_149=0, Q_150=0
integer Q_151=0, Q_152=0, Q_153=0, Q_154=0, Q_155=0, Q_156=0, Q_157=0, Q_158=0, Q_159=0, Q_160=0
integer Q_161=0, Q_162=0, Q_163=0, Q_164=0, Q_165=0, Q_166=0, Q_167=0, Q_168=0, Q_169=0, Q_170=0
integer Q_171=0, Q_172=0, Q_173=0, Q_174=0, Q_175=0, Q_176=0, Q_177=0, Q_178=0, Q_179=0, Q_180=0
integer Q_181=0, Q_182=0, Q_183=0, Q_184=0, Q_185=0, Q_186=0, Q_187=0, Q_188=0, Q_189=0, Q_190=0
integer Q_191=0, Q_192=0, Q_193=0, Q_194=0, Q_195=0, Q_196=0, Q_197=0, Q_198=0, Q_199=0, Q_200=0

integer proc get_p(integer b)
    case b
        when 0 return(1)
        when 1 return(2)
        when 2 return(4)
        when 3 return(8)
        when 4 return(16)
        when 5 return(32)
        when 6 return(64)
        when 7 return(128)
        when 8 return(256)
        when 9 return(512)
        when 10 return(1024)
        when 11 return(2048)
        when 12 return(4096)
        when 13 return(8192)
        when 14 return(16384)
        when 15 return(32768)
        when 16 return(65536)
        when 17 return(131072)
    endcase
    return(0)
end

proc set_Q(integer idx_q, integer cell_data)
    case idx_q
        when 1 Q_1 = cell_data
        when 2 Q_2 = cell_data
        when 3 Q_3 = cell_data
        when 4 Q_4 = cell_data
        when 5 Q_5 = cell_data
        when 6 Q_6 = cell_data
        when 7 Q_7 = cell_data
        when 8 Q_8 = cell_data
        when 9 Q_9 = cell_data
        when 10 Q_10 = cell_data
        when 11 Q_11 = cell_data
        when 12 Q_12 = cell_data
        when 13 Q_13 = cell_data
        when 14 Q_14 = cell_data
        when 15 Q_15 = cell_data
        when 16 Q_16 = cell_data
        when 17 Q_17 = cell_data
        when 18 Q_18 = cell_data
        when 19 Q_19 = cell_data
        when 20 Q_20 = cell_data
        when 21 Q_21 = cell_data
        when 22 Q_22 = cell_data
        when 23 Q_23 = cell_data
        when 24 Q_24 = cell_data
        when 25 Q_25 = cell_data
        when 26 Q_26 = cell_data
        when 27 Q_27 = cell_data
        when 28 Q_28 = cell_data
        when 29 Q_29 = cell_data
        when 30 Q_30 = cell_data
        when 31 Q_31 = cell_data
        when 32 Q_32 = cell_data
        when 33 Q_33 = cell_data
        when 34 Q_34 = cell_data
        when 35 Q_35 = cell_data
        when 36 Q_36 = cell_data
        when 37 Q_37 = cell_data
        when 38 Q_38 = cell_data
        when 39 Q_39 = cell_data
        when 40 Q_40 = cell_data
        when 41 Q_41 = cell_data
        when 42 Q_42 = cell_data
        when 43 Q_43 = cell_data
        when 44 Q_44 = cell_data
        when 45 Q_45 = cell_data
        when 46 Q_46 = cell_data
        when 47 Q_47 = cell_data
        when 48 Q_48 = cell_data
        when 49 Q_49 = cell_data
        when 50 Q_50 = cell_data
        when 51 Q_51 = cell_data
        when 52 Q_52 = cell_data
        when 53 Q_53 = cell_data
        when 54 Q_54 = cell_data
        when 55 Q_55 = cell_data
        when 56 Q_56 = cell_data
        when 57 Q_57 = cell_data
        when 58 Q_58 = cell_data
        when 59 Q_59 = cell_data
        when 60 Q_60 = cell_data
        when 61 Q_61 = cell_data
        when 62 Q_62 = cell_data
        when 63 Q_63 = cell_data
        when 64 Q_64 = cell_data
        when 65 Q_65 = cell_data
        when 66 Q_66 = cell_data
        when 67 Q_67 = cell_data
        when 68 Q_68 = cell_data
        when 69 Q_69 = cell_data
        when 70 Q_70 = cell_data
        when 71 Q_71 = cell_data
        when 72 Q_72 = cell_data
        when 73 Q_73 = cell_data
        when 74 Q_74 = cell_data
        when 75 Q_75 = cell_data
        when 76 Q_76 = cell_data
        when 77 Q_77 = cell_data
        when 78 Q_78 = cell_data
        when 79 Q_79 = cell_data
        when 80 Q_80 = cell_data
        when 81 Q_81 = cell_data
        when 82 Q_82 = cell_data
        when 83 Q_83 = cell_data
        when 84 Q_84 = cell_data
        when 85 Q_85 = cell_data
        when 86 Q_86 = cell_data
        when 87 Q_87 = cell_data
        when 88 Q_88 = cell_data
        when 89 Q_89 = cell_data
        when 90 Q_90 = cell_data
        when 91 Q_91 = cell_data
        when 92 Q_92 = cell_data
        when 93 Q_93 = cell_data
        when 94 Q_94 = cell_data
        when 95 Q_95 = cell_data
        when 96 Q_96 = cell_data
        when 97 Q_97 = cell_data
        when 98 Q_98 = cell_data
        when 99 Q_99 = cell_data
        when 100 Q_100 = cell_data
        when 101 Q_101 = cell_data
        when 102 Q_102 = cell_data
        when 103 Q_103 = cell_data
        when 104 Q_104 = cell_data
        when 105 Q_105 = cell_data
        when 106 Q_106 = cell_data
        when 107 Q_107 = cell_data
        when 108 Q_108 = cell_data
        when 109 Q_109 = cell_data
        when 110 Q_110 = cell_data
        when 111 Q_111 = cell_data
        when 112 Q_112 = cell_data
        when 113 Q_113 = cell_data
        when 114 Q_114 = cell_data
        when 115 Q_115 = cell_data
        when 116 Q_116 = cell_data
        when 117 Q_117 = cell_data
        when 118 Q_118 = cell_data
        when 119 Q_119 = cell_data
        when 120 Q_120 = cell_data
        when 121 Q_121 = cell_data
        when 122 Q_122 = cell_data
        when 123 Q_123 = cell_data
        when 124 Q_124 = cell_data
        when 125 Q_125 = cell_data
        when 126 Q_126 = cell_data
        when 127 Q_127 = cell_data
        when 128 Q_128 = cell_data
        when 129 Q_129 = cell_data
        when 130 Q_130 = cell_data
        when 131 Q_131 = cell_data
        when 132 Q_132 = cell_data
        when 133 Q_133 = cell_data
        when 134 Q_134 = cell_data
        when 135 Q_135 = cell_data
        when 136 Q_136 = cell_data
        when 137 Q_137 = cell_data
        when 138 Q_138 = cell_data
        when 139 Q_139 = cell_data
        when 140 Q_140 = cell_data
        when 141 Q_141 = cell_data
        when 142 Q_142 = cell_data
        when 143 Q_143 = cell_data
        when 144 Q_144 = cell_data
        when 145 Q_145 = cell_data
        when 146 Q_146 = cell_data
        when 147 Q_147 = cell_data
        when 148 Q_148 = cell_data
        when 149 Q_149 = cell_data
        when 150 Q_150 = cell_data
        when 151 Q_151 = cell_data
        when 152 Q_152 = cell_data
        when 153 Q_153 = cell_data
        when 154 Q_154 = cell_data
        when 155 Q_155 = cell_data
        when 156 Q_156 = cell_data
        when 157 Q_157 = cell_data
        when 158 Q_158 = cell_data
        when 159 Q_159 = cell_data
        when 160 Q_160 = cell_data
        when 161 Q_161 = cell_data
        when 162 Q_162 = cell_data
        when 163 Q_163 = cell_data
        when 164 Q_164 = cell_data
        when 165 Q_165 = cell_data
        when 166 Q_166 = cell_data
        when 167 Q_167 = cell_data
        when 168 Q_168 = cell_data
        when 169 Q_169 = cell_data
        when 170 Q_170 = cell_data
        when 171 Q_171 = cell_data
        when 172 Q_172 = cell_data
        when 173 Q_173 = cell_data
        when 174 Q_174 = cell_data
        when 175 Q_175 = cell_data
        when 176 Q_176 = cell_data
        when 177 Q_177 = cell_data
        when 178 Q_178 = cell_data
        when 179 Q_179 = cell_data
        when 180 Q_180 = cell_data
        when 181 Q_181 = cell_data
        when 182 Q_182 = cell_data
        when 183 Q_183 = cell_data
        when 184 Q_184 = cell_data
        when 185 Q_185 = cell_data
        when 186 Q_186 = cell_data
        when 187 Q_187 = cell_data
        when 188 Q_188 = cell_data
        when 189 Q_189 = cell_data
        when 190 Q_190 = cell_data
        when 191 Q_191 = cell_data
        when 192 Q_192 = cell_data
        when 193 Q_193 = cell_data
        when 194 Q_194 = cell_data
        when 195 Q_195 = cell_data
        when 196 Q_196 = cell_data
        when 197 Q_197 = cell_data
        when 198 Q_198 = cell_data
        when 199 Q_199 = cell_data
        when 200 Q_200 = cell_data
    endcase
end

integer proc get_Q(integer idx_q)
    case idx_q
        when 1 return(Q_1)
        when 2 return(Q_2)
        when 3 return(Q_3)
        when 4 return(Q_4)
        when 5 return(Q_5)
        when 6 return(Q_6)
        when 7 return(Q_7)
        when 8 return(Q_8)
        when 9 return(Q_9)
        when 10 return(Q_10)
        when 11 return(Q_11)
        when 12 return(Q_12)
        when 13 return(Q_13)
        when 14 return(Q_14)
        when 15 return(Q_15)
        when 16 return(Q_16)
        when 17 return(Q_17)
        when 18 return(Q_18)
        when 19 return(Q_19)
        when 20 return(Q_20)
        when 21 return(Q_21)
        when 22 return(Q_22)
        when 23 return(Q_23)
        when 24 return(Q_24)
        when 25 return(Q_25)
        when 26 return(Q_26)
        when 27 return(Q_27)
        when 28 return(Q_28)
        when 29 return(Q_29)
        when 30 return(Q_30)
        when 31 return(Q_31)
        when 32 return(Q_32)
        when 33 return(Q_33)
        when 34 return(Q_34)
        when 35 return(Q_35)
        when 36 return(Q_36)
        when 37 return(Q_37)
        when 38 return(Q_38)
        when 39 return(Q_39)
        when 40 return(Q_40)
        when 41 return(Q_41)
        when 42 return(Q_42)
        when 43 return(Q_43)
        when 44 return(Q_44)
        when 45 return(Q_45)
        when 46 return(Q_46)
        when 47 return(Q_47)
        when 48 return(Q_48)
        when 49 return(Q_49)
        when 50 return(Q_50)
        when 51 return(Q_51)
        when 52 return(Q_52)
        when 53 return(Q_53)
        when 54 return(Q_54)
        when 55 return(Q_55)
        when 56 return(Q_56)
        when 57 return(Q_57)
        when 58 return(Q_58)
        when 59 return(Q_59)
        when 60 return(Q_60)
        when 61 return(Q_61)
        when 62 return(Q_62)
        when 63 return(Q_63)
        when 64 return(Q_64)
        when 65 return(Q_65)
        when 66 return(Q_66)
        when 67 return(Q_67)
        when 68 return(Q_68)
        when 69 return(Q_69)
        when 70 return(Q_70)
        when 71 return(Q_71)
        when 72 return(Q_72)
        when 73 return(Q_73)
        when 74 return(Q_74)
        when 75 return(Q_75)
        when 76 return(Q_76)
        when 77 return(Q_77)
        when 78 return(Q_78)
        when 79 return(Q_79)
        when 80 return(Q_80)
        when 81 return(Q_81)
        when 82 return(Q_82)
        when 83 return(Q_83)
        when 84 return(Q_84)
        when 85 return(Q_85)
        when 86 return(Q_86)
        when 87 return(Q_87)
        when 88 return(Q_88)
        when 89 return(Q_89)
        when 90 return(Q_90)
        when 91 return(Q_91)
        when 92 return(Q_92)
        when 93 return(Q_93)
        when 94 return(Q_94)
        when 95 return(Q_95)
        when 96 return(Q_96)
        when 97 return(Q_97)
        when 98 return(Q_98)
        when 99 return(Q_99)
        when 100 return(Q_100)
        when 101 return(Q_101)
        when 102 return(Q_102)
        when 103 return(Q_103)
        when 104 return(Q_104)
        when 105 return(Q_105)
        when 106 return(Q_106)
        when 107 return(Q_107)
        when 108 return(Q_108)
        when 109 return(Q_109)
        when 110 return(Q_110)
        when 111 return(Q_111)
        when 112 return(Q_112)
        when 113 return(Q_113)
        when 114 return(Q_114)
        when 115 return(Q_115)
        when 116 return(Q_116)
        when 117 return(Q_117)
        when 118 return(Q_118)
        when 119 return(Q_119)
        when 120 return(Q_120)
        when 121 return(Q_121)
        when 122 return(Q_122)
        when 123 return(Q_123)
        when 124 return(Q_124)
        when 125 return(Q_125)
        when 126 return(Q_126)
        when 127 return(Q_127)
        when 128 return(Q_128)
        when 129 return(Q_129)
        when 130 return(Q_130)
        when 131 return(Q_131)
        when 132 return(Q_132)
        when 133 return(Q_133)
        when 134 return(Q_134)
        when 135 return(Q_135)
        when 136 return(Q_136)
        when 137 return(Q_137)
        when 138 return(Q_138)
        when 139 return(Q_139)
        when 140 return(Q_140)
        when 141 return(Q_141)
        when 142 return(Q_142)
        when 143 return(Q_143)
        when 144 return(Q_144)
        when 145 return(Q_145)
        when 146 return(Q_146)
        when 147 return(Q_147)
        when 148 return(Q_148)
        when 149 return(Q_149)
        when 150 return(Q_150)
        when 151 return(Q_151)
        when 152 return(Q_152)
        when 153 return(Q_153)
        when 154 return(Q_154)
        when 155 return(Q_155)
        when 156 return(Q_156)
        when 157 return(Q_157)
        when 158 return(Q_158)
        when 159 return(Q_159)
        when 160 return(Q_160)
        when 161 return(Q_161)
        when 162 return(Q_162)
        when 163 return(Q_163)
        when 164 return(Q_164)
        when 165 return(Q_165)
        when 166 return(Q_166)
        when 167 return(Q_167)
        when 168 return(Q_168)
        when 169 return(Q_169)
        when 170 return(Q_170)
        when 171 return(Q_171)
        when 172 return(Q_172)
        when 173 return(Q_173)
        when 174 return(Q_174)
        when 175 return(Q_175)
        when 176 return(Q_176)
        when 177 return(Q_177)
        when 178 return(Q_178)
        when 179 return(Q_179)
        when 180 return(Q_180)
        when 181 return(Q_181)
        when 182 return(Q_182)
        when 183 return(Q_183)
        when 184 return(Q_184)
        when 185 return(Q_185)
        when 186 return(Q_186)
        when 187 return(Q_187)
        when 188 return(Q_188)
        when 189 return(Q_189)
        when 190 return(Q_190)
        when 191 return(Q_191)
        when 192 return(Q_192)
        when 193 return(Q_193)
        when 194 return(Q_194)
        when 195 return(Q_195)
        when 196 return(Q_196)
        when 197 return(Q_197)
        when 198 return(Q_198)
        when 199 return(Q_199)
        when 200 return(Q_200)
    endcase
    return(0)
end

integer proc get_seen(integer px, integer py)
    integer p_bit = 0
    integer cell_data = 0
    
    if px < 18
        p_bit = get_p(px)
        case py
            when 0 cell_data = s0_0
            when 1 cell_data = s1_0
            when 2 cell_data = s2_0
            when 3 cell_data = s3_0
            when 4 cell_data = s4_0
            when 5 cell_data = s5_0
            when 6 cell_data = s6_0
            when 7 cell_data = s7_0
            when 8 cell_data = s8_0
            when 9 cell_data = s9_0
            when 10 cell_data = s10_0
            when 11 cell_data = s11_0
            when 12 cell_data = s12_0
            when 13 cell_data = s13_0
            when 14 cell_data = s14_0
            when 15 cell_data = s15_0
            when 16 cell_data = s16_0
            when 17 cell_data = s17_0
        endcase
    else
        p_bit = get_p(px - 18)
        case py
            when 0 cell_data = s0_1
            when 1 cell_data = s1_1
            when 2 cell_data = s2_1
            when 3 cell_data = s3_1
            when 4 cell_data = s4_1
            when 5 cell_data = s5_1
            when 6 cell_data = s6_1
            when 7 cell_data = s7_1
            when 8 cell_data = s8_1
            when 9 cell_data = s9_1
            when 10 cell_data = s10_1
            when 11 cell_data = s11_1
            when 12 cell_data = s12_1
            when 13 cell_data = s13_1
            when 14 cell_data = s14_1
            when 15 cell_data = s15_1
            when 16 cell_data = s16_1
            when 17 cell_data = s17_1
        endcase
    endif
    
    if (cell_data & p_bit) <> 0
        return(1)
    endif
    return(0)
end

proc set_seen_1(integer px, integer py)
    integer p_bit = 0
    
    if px < 18
        p_bit = get_p(px)
        case py
            when 0 s0_0 = s0_0 | p_bit
            when 1 s1_0 = s1_0 | p_bit
            when 2 s2_0 = s2_0 | p_bit
            when 3 s3_0 = s3_0 | p_bit
            when 4 s4_0 = s4_0 | p_bit
            when 5 s5_0 = s5_0 | p_bit
            when 6 s6_0 = s6_0 | p_bit
            when 7 s7_0 = s7_0 | p_bit
            when 8 s8_0 = s8_0 | p_bit
            when 9 s9_0 = s9_0 | p_bit
            when 10 s10_0 = s10_0 | p_bit
            when 11 s11_0 = s11_0 | p_bit
            when 12 s12_0 = s12_0 | p_bit
            when 13 s13_0 = s13_0 | p_bit
            when 14 s14_0 = s14_0 | p_bit
            when 15 s15_0 = s15_0 | p_bit
            when 16 s16_0 = s16_0 | p_bit
            when 17 s17_0 = s17_0 | p_bit
        endcase
    else
        p_bit = get_p(px - 18)
        case py
            when 0 s0_1 = s0_1 | p_bit
            when 1 s1_1 = s1_1 | p_bit
            when 2 s2_1 = s2_1 | p_bit
            when 3 s3_1 = s3_1 | p_bit
            when 4 s4_1 = s4_1 | p_bit
            when 5 s5_1 = s5_1 | p_bit
            when 6 s6_1 = s6_1 | p_bit
            when 7 s7_1 = s7_1 | p_bit
            when 8 s8_1 = s8_1 | p_bit
            when 9 s9_1 = s9_1 | p_bit
            when 10 s10_1 = s10_1 | p_bit
            when 11 s11_1 = s11_1 | p_bit
            when 12 s12_1 = s12_1 | p_bit
            when 13 s13_1 = s13_1 | p_bit
            when 14 s14_1 = s14_1 | p_bit
            when 15 s15_1 = s15_1 | p_bit
            when 16 s16_1 = s16_1 | p_bit
            when 17 s17_1 = s17_1 | p_bit
        endcase
    endif
end

proc set_seen_0(integer px, integer py)
    integer p_bit = 0
    
    if px < 18
        p_bit = get_p(px)
        case py
            when 0 s0_0 = s0_0 - p_bit
            when 1 s1_0 = s1_0 - p_bit
            when 2 s2_0 = s2_0 - p_bit
            when 3 s3_0 = s3_0 - p_bit
            when 4 s4_0 = s4_0 - p_bit
            when 5 s5_0 = s5_0 - p_bit
            when 6 s6_0 = s6_0 - p_bit
            when 7 s7_0 = s7_0 - p_bit
            when 8 s8_0 = s8_0 - p_bit
            when 9 s9_0 = s9_0 - p_bit
            when 10 s10_0 = s10_0 - p_bit
            when 11 s11_0 = s11_0 - p_bit
            when 12 s12_0 = s12_0 - p_bit
            when 13 s13_0 = s13_0 - p_bit
            when 14 s14_0 = s14_0 - p_bit
            when 15 s15_0 = s15_0 - p_bit
            when 16 s16_0 = s16_0 - p_bit
            when 17 s17_0 = s17_0 - p_bit
        endcase
    else
        p_bit = get_p(px - 18)
        case py
            when 0 s0_1 = s0_1 - p_bit
            when 1 s1_1 = s1_1 - p_bit
            when 2 s2_1 = s2_1 - p_bit
            when 3 s3_1 = s3_1 - p_bit
            when 4 s4_1 = s4_1 - p_bit
            when 5 s5_1 = s5_1 - p_bit
            when 6 s6_1 = s6_1 - p_bit
            when 7 s7_1 = s7_1 - p_bit
            when 8 s8_1 = s8_1 - p_bit
            when 9 s9_1 = s9_1 - p_bit
            when 10 s10_1 = s10_1 - p_bit
            when 11 s11_1 = s11_1 - p_bit
            when 12 s12_1 = s12_1 - p_bit
            when 13 s13_1 = s13_1 - p_bit
            when 14 s14_1 = s14_1 - p_bit
            when 15 s15_1 = s15_1 - p_bit
            when 16 s16_1 = s16_1 - p_bit
            when 17 s17_1 = s17_1 - p_bit
        endcase
    endif
end

proc clear_all_seen()
    s0_0 = 0
    s0_1 = 0
    s1_0 = 0
    s1_1 = 0
    s2_0 = 0
    s2_1 = 0
    s3_0 = 0
    s3_1 = 0
    s4_0 = 0
    s4_1 = 0
    s5_0 = 0
    s5_1 = 0
    s6_0 = 0
    s6_1 = 0
    s7_0 = 0
    s7_1 = 0
    s8_0 = 0
    s8_1 = 0
    s9_0 = 0
    s9_1 = 0
    s10_0 = 0
    s10_1 = 0
    s11_0 = 0
    s11_1 = 0
    s12_0 = 0
    s12_1 = 0
    s13_0 = 0
    s13_1 = 0
    s14_0 = 0
    s14_1 = 0
    s15_0 = 0
    s15_1 = 0
    s16_0 = 0
    s16_1 = 0
    s17_0 = 0
    s17_1 = 0
end

proc rec_total(integer q_begin, integer q_end_, integer size, integer moment, integer minx, integer maxx)
    integer r = 0
    integer min_possible_x = 0
    integer max_possible_x = 0
    integer i = 0
    integer x = 0
    integer y = 0
    integer added = 0
    integer nx = 0
    integer ny = 0
    integer nmin = 0
    integer nmax = 0
    integer j = 0
    integer ax = 0
    integer ay = 0
    integer actual_x = 0
    integer cell_data = 0

    if size == 18
        if moment == 0
            total_N = total_N + 1
        endif
        return()
    endif

    r = 18 - size
    min_possible_x = minx - r
    max_possible_x = maxx + r

    if (moment + (r * min_possible_x)) > 0
        return()
    endif
    if (moment + (r * max_possible_x)) < 0
        return()
    endif

    i = q_begin
    while i < q_end_
        cell_data = get_Q(i)
        x = cell_data / 100
        y = cell_data mod 100
        actual_x = x - 17
        added = 0

        nx = x - 1
        ny = y
        if nx >= 0
            if get_seen(nx, ny) == 0
                set_seen_1(nx, ny)
                set_Q(q_end_ + added, (nx * 100) + ny)
                added = added + 1
            endif
        endif

        nx = x + 1
        ny = y
        if nx <= 34
            if get_seen(nx, ny) == 0
                set_seen_1(nx, ny)
                set_Q(q_end_ + added, (nx * 100) + ny)
                added = added + 1
            endif
        endif

        nx = x
        ny = y - 1
        if ny >= 0
            if get_seen(nx, ny) == 0
                set_seen_1(nx, ny)
                set_Q(q_end_ + added, (nx * 100) + ny)
                added = added + 1
            endif
        endif

        nx = x
        ny = y + 1
        if ny <= 17
            if get_seen(nx, ny) == 0
                set_seen_1(nx, ny)
                set_Q(q_end_ + added, (nx * 100) + ny)
                added = added + 1
            endif
        endif

        nmin = minx
        if actual_x < minx
            nmin = actual_x
        endif

        nmax = maxx
        if actual_x > maxx
            nmax = actual_x
        endif

        rec_total(i + 1, q_end_ + added, size + 1, moment + actual_x, nmin, nmax)

        j = 0
        while j < added
            cell_data = get_Q(q_end_ + j)
            ax = cell_data / 100
            ay = cell_data mod 100
            set_seen_0(ax, ay)
            j = j + 1
        endwhile

        i = i + 1
    endwhile
end

proc rec_sym(integer q_begin, integer q_end_, integer full_size)
    integer i = 0
    integer x = 0
    integer y = 0
    integer added = 0
    integer nx = 0
    integer ny = 0
    integer j = 0
    integer ax = 0
    integer ay = 0
    integer actual_x = 0
    integer add_size = 0
    integer new_full = 0
    integer cell_data = 0

    if full_size == 18
        total_sym = total_sym + 1
        return()
    endif

    i = q_begin
    while i < q_end_
        cell_data = get_Q(i)
        x = cell_data / 100
        y = cell_data mod 100
        actual_x = x - 17

        add_size = 2
        if actual_x == 0
            add_size = 1
        endif

        new_full = full_size + add_size
        if new_full <= 18
            added = 0

            nx = x - 1
            ny = y
            if nx >= 17
                if get_seen(nx, ny) == 0
                    set_seen_1(nx, ny)
                    set_Q(q_end_ + added, (nx * 100) + ny)
                    added = added + 1
                endif
            endif

            nx = x + 1
            ny = y
            if nx <= 34
                if get_seen(nx, ny) == 0
                    set_seen_1(nx, ny)
                    set_Q(q_end_ + added, (nx * 100) + ny)
                    added = added + 1
                endif
            endif

            nx = x
            ny = y - 1
            if ny >= 0
                if get_seen(nx, ny) == 0
                    set_seen_1(nx, ny)
                    set_Q(q_end_ + added, (nx * 100) + ny)
                    added = added + 1
                endif
            endif

            nx = x
            ny = y + 1
            if ny <= 17
                if get_seen(nx, ny) == 0
                    set_seen_1(nx, ny)
                    set_Q(q_end_ + added, (nx * 100) + ny)
                    added = added + 1
                endif
            endif

            rec_sym(i + 1, q_end_ + added, new_full)

            j = 0
            while j < added
                cell_data = get_Q(q_end_ + j)
                ax = cell_data / 100
                ay = cell_data mod 100
                set_seen_0(ax, ay)
                j = j + 1
            endwhile
        endif
        i = i + 1
    endwhile
end

proc Main()
    integer q_end_val = 0
    integer answer = 0
    string s_answer[255] = ""

    // ----------------------------------------
    // TOTAL BALANCED SCULPTURES
    // ----------------------------------------
    clear_all_seen()
    total_N = 0

    // Force mandatory block at root: X=17, Y=0
    set_seen_1(17, 0)
    q_end_val = 1

    // Add root neighbors manually
    set_seen_1(16, 0)
    set_Q(q_end_val, (16 * 100) + 0)
    q_end_val = q_end_val + 1

    set_seen_1(18, 0)
    set_Q(q_end_val, (18 * 100) + 0)
    q_end_val = q_end_val + 1

    set_seen_1(17, 1)
    set_Q(q_end_val, (17 * 100) + 1)
    q_end_val = q_end_val + 1

    rec_total(1, q_end_val, 1, 0, 0, 0)

    // ----------------------------------------
    // SYMMETRIC SCULPTURES
    // ----------------------------------------
    clear_all_seen()
    total_sym = 0

    set_seen_1(17, 0)
    q_end_val = 1
    
    // Neighbors restricted to x >= 17 (16,0 is discarded)
    set_seen_1(18, 0)
    set_Q(q_end_val, (18 * 100) + 0)
    q_end_val = q_end_val + 1

    set_seen_1(17, 1)
    set_Q(q_end_val, (17 * 100) + 1)
    q_end_val = q_end_val + 1

    rec_sym(1, q_end_val, 1)

    // ----------------------------------------
    // FINAL RESULT
    // ----------------------------------------
    answer = (total_N + total_sym) / 2
    s_answer = Str(answer)

    CopyToWinClip(s_answer)
    Warn("Project Euler 275 answer: ", s_answer)
    CopyToWinClip(s_answer)
end
