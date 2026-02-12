/*
The character conversion macros, revised to include all of the variations
into one macro, sharing the common routines.

Refer to CVT-READ.ME for an overview.

If you wish to automatically convert to spaces any characters that cannot be
converted to the new character set, add the following line to the beginning of
each conversion routine. (Don't tack it onto the end or it will remove much of
what was done by the previous lines.)
    lReplace(fnd_str,"\d032",cvt_opts)
*/

string fnd_str[50] = ""   // place proper find string for each charset here
string char_set[25] = ""  // place proper message string for each charset here
integer cvt_table = 0     // choice conversion macro to use
string msg[45] = "Converting Hi-bit characters, "
string dn[5] = "done."
string cvt_opts[4] = ""


proc Dos2Ansi()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d248","\d176",cvt_opts)
    lReplace("\d237","\d248",cvt_opts)
    lReplace("\d161","\d237",cvt_opts)
    lReplace("\d173","\d161",cvt_opts)
    lReplace("\d162","\d243",cvt_opts)
    lReplace("\d155","\d162",cvt_opts)
    lReplace("\d250","\d183",cvt_opts)
    lReplace("\d163","\d250",cvt_opts)
    lReplace("\d156","\d163",cvt_opts)
    lReplace("\d165","\d209",cvt_opts)
    lReplace("\d157","\d165",cvt_opts)
    lReplace("\d172","\d188",cvt_opts)
    lReplace("\d170","\d172",cvt_opts)
    lReplace("\d166","\d170",cvt_opts)
    lReplace("\d171","\d189",cvt_opts)
    lReplace("\d174","\d171",cvt_opts)
    lReplace("\d241","\d177",cvt_opts)
    lReplace("\d253","\d178",cvt_opts)
    Message(msg + char_set +  "20% " + dn)

    lReplace("\d230","\d181",cvt_opts)
    lReplace("\d167","\d186",cvt_opts)
    lReplace("\d175","\d187",cvt_opts)
    lReplace("\d168","\d191",cvt_opts)
    lReplace("\d142","\d196",cvt_opts)
    lReplace("\d143","\d197",cvt_opts)
    lReplace("\d146","\d198",cvt_opts)
    lReplace("\d128","\d199",cvt_opts)
    Message(msg + char_set +  "40% " + dn)

    lReplace("\d144","\d201",cvt_opts)
    lReplace("\d153","\d214",cvt_opts)
    lReplace("\d232","\d216",cvt_opts)
    lReplace("\d154","\d220",cvt_opts)
    lReplace("\d225","\d223",cvt_opts)
    lReplace("\d133","\d224",cvt_opts)
    lReplace("\d160","\d225",cvt_opts)
    lReplace("\d131","\d226",cvt_opts)
    lReplace("\d132","\d228",cvt_opts)
    lReplace("\d134","\d229",cvt_opts)
    lReplace("\d135","\d231",cvt_opts)
    Message(msg + char_set +  "60% " + dn)

    lReplace("\d145","\d230",cvt_opts)
    lReplace("\d138","\d232",cvt_opts)
    lReplace("\d130","\d233",cvt_opts)
    lReplace("\d136","\d234",cvt_opts)
    lReplace("\d137","\d235",cvt_opts)
    lReplace("\d141","\d236",cvt_opts)
    lReplace("\d140","\d238",cvt_opts)
    lReplace("\d139","\d239",cvt_opts)
    lReplace("\d164","\d241",cvt_opts)
    Message(msg + char_set +  "80% " + dn)

    lReplace("\d149","\d242",cvt_opts)
    lReplace("\d147","\d244",cvt_opts)
    lReplace("\d246","\d247",cvt_opts)
    lReplace("\d148","\d246",cvt_opts)
    lReplace("\d151","\d249",cvt_opts)
    lReplace("\d150","\d251",cvt_opts)
    lReplace("\d129","\d252",cvt_opts)
    lReplace("\d152","\d255",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc Ansi2Dos()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d161","\d173",cvt_opts)
    lReplace("\d237","\d161",cvt_opts)
    lReplace("\d162","\d155",cvt_opts)
    lReplace("\d163","\d156",cvt_opts)
    lReplace("\d165","\d157",cvt_opts)
    lReplace("\d166","\d124",cvt_opts)
    lReplace("\d170","\d166",cvt_opts)
    lReplace("\d171","\d174",cvt_opts)
    lReplace("\d172","\d170",cvt_opts)
    lReplace("\d248","\d237",cvt_opts)
    lReplace("\d176","\d248",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d241","\d164",cvt_opts)
    lReplace("\d177","\d241",cvt_opts)
    lReplace("\d178","\d253",cvt_opts)
    lReplace("\d230","\d145",cvt_opts)
    lReplace("\d181","\d230",cvt_opts)
    lReplace("\d250","\d163",cvt_opts)
    lReplace("\d183","\d250",cvt_opts)
    lReplace("\d186","\d167",cvt_opts)
    lReplace("\d187","\d175",cvt_opts)
    lReplace("\d188","\d172",cvt_opts)
    lReplace("\d189","\d171",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d191","\d168",cvt_opts)
    lReplace("\d196","\d142",cvt_opts)
    lReplace("\d197","\d143",cvt_opts)
    lReplace("\d198","\d146",cvt_opts)
    lReplace("\d128","\d000",cvt_opts)
    lReplace("\d199","\d128",cvt_opts)
    lReplace("\d201","\d144",cvt_opts)
    lReplace("\d209","\d165",cvt_opts)
    lReplace("\d214","\d153",cvt_opts)
    lReplace("\d232","\d138",cvt_opts)
    lReplace("\d216","\d232",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d220","\d154",cvt_opts)
    lReplace("\d224","\d133",cvt_opts)
    lReplace("\d225","\d160",cvt_opts)
    lReplace("\d223","\d225",cvt_opts)
    lReplace("\d226","\d131",cvt_opts)
    lReplace("\d228","\d132",cvt_opts)
    lReplace("\d229","\d134",cvt_opts)
    lReplace("\d231","\d135",cvt_opts)
    lReplace("\d233","\d130",cvt_opts)
    lReplace("\d234","\d136",cvt_opts)
    lReplace("\d235","\d137",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d236","\d141",cvt_opts)
    lReplace("\d238","\d140",cvt_opts)
    lReplace("\d239","\d139",cvt_opts)
    lReplace("\d242","\d149",cvt_opts)
    lReplace("\d243","\d162",cvt_opts)
    lReplace("\d244","\d147",cvt_opts)
    lReplace("\d246","\d148",cvt_opts)
    lReplace("\d247","\d246",cvt_opts)
    lReplace("\d249","\d151",cvt_opts)
    lReplace("\d251","\d150",cvt_opts)
    lReplace("\d252","\d129",cvt_opts)
    lReplace("\d255","\d152",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc Dos2Hp()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d020","\d244",cvt_opts)
    lReplace("\d021","\d189",cvt_opts)
    lReplace("\d094","\d170",cvt_opts)
    lReplace("\d096","\d169",cvt_opts)
    lReplace("\d172","\d247",cvt_opts)
    lReplace("\d126","\d172",cvt_opts)
    lReplace("\d128","\d180",cvt_opts)
    lReplace("\d129","\d207",cvt_opts)
    lReplace("\d130","\d197",cvt_opts)
    lReplace("\d131","\d192",cvt_opts)
    lReplace("\d132","\d204",cvt_opts)
    lReplace("\d133","\d200",cvt_opts)
    Message(msg + char_set +  "20% " + dn)

    lReplace("\d134","\d212",cvt_opts)
    lReplace("\d135","\d181",cvt_opts)
    lReplace("\d136","\d193",cvt_opts)
    lReplace("\d137","\d205",cvt_opts)
    lReplace("\d138","\d201",cvt_opts)
    lReplace("\d139","\d221",cvt_opts)
    lReplace("\d140","\d209",cvt_opts)
    lReplace("\d141","\d217",cvt_opts)
    lReplace("\d142","\d216",cvt_opts)
    lReplace("\d143","\d208",cvt_opts)
    lReplace("\d144","\d220",cvt_opts)
    lReplace("\d145","\d215",cvt_opts)
    Message(msg + char_set +  "40% " + dn)

    lReplace("\d146","\d211",cvt_opts)
    lReplace("\d147","\d194",cvt_opts)
    lReplace("\d148","\d206",cvt_opts)
    lReplace("\d149","\d202",cvt_opts)
    lReplace("\d150","\d195",cvt_opts)
    lReplace("\d151","\d203",cvt_opts)
    lReplace("\d152","\d239",cvt_opts)
    lReplace("\d153","\d218",cvt_opts)
    lReplace("\d154","\d219",cvt_opts)
    lReplace("\d155","\d191",cvt_opts)
    lReplace("\d175","\d253",cvt_opts)
//    lReplace("\d156","\d175",cvt_opts)    // Don't ask me why this character is duplicated in the HP set!
    Message(msg + char_set +  "60% " + dn)

    lReplace("\d156","\d187",cvt_opts)
    lReplace("\d157","\d188",cvt_opts)
    lReplace("\d159","\d190",cvt_opts)
    lReplace("\d160","\d196",cvt_opts)
    lReplace("\d161","\d213",cvt_opts)
    lReplace("\d162","\d198",cvt_opts)
    lReplace("\d163","\d199",cvt_opts)
    lReplace("\d164","\d183",cvt_opts)
    lReplace("\d165","\d182",cvt_opts)
    lReplace("\d249","\d242",cvt_opts)
    lReplace("\d166","\d249",cvt_opts)
    lReplace("\d167","\d250",cvt_opts)
    Message(msg + char_set +  "80% " + dn)

    lReplace("\d168","\d185",cvt_opts)
    lReplace("\d248","\d179",cvt_opts)
    lReplace("\d171","\d248",cvt_opts)
    lReplace("\d173","\d184",cvt_opts)
    lReplace("\d174","\d251",cvt_opts)
    lReplace("\d225","\d222",cvt_opts)
    lReplace("\d230","\d243",cvt_opts)
    lReplace("\d254","\d252",cvt_opts)
    lReplace("\d241","\d254",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc Hp2Dos()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d244","\d020",cvt_opts)
    lReplace("\d189","\d021",cvt_opts)
    lReplace("\d170","\d094",cvt_opts)
    lReplace("\d169","\d096",cvt_opts)
    lReplace("\d172","\d126",cvt_opts)
    lReplace("\d247","\d172",cvt_opts)
    lReplace("\d180","\d128",cvt_opts)
    lReplace("\d207","\d129",cvt_opts)
    lReplace("\d197","\d130",cvt_opts)
    lReplace("\d192","\d131",cvt_opts)
    lReplace("\d204","\d132",cvt_opts)
    lReplace("\d200","\d133",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d212","\d134",cvt_opts)
    lReplace("\d181","\d135",cvt_opts)
    lReplace("\d193","\d136",cvt_opts)
    lReplace("\d205","\d137",cvt_opts)
    lReplace("\d201","\d138",cvt_opts)
    lReplace("\d221","\d139",cvt_opts)
    lReplace("\d209","\d140",cvt_opts)
    lReplace("\d217","\d141",cvt_opts)
    lReplace("\d216","\d142",cvt_opts)
    lReplace("\d208","\d143",cvt_opts)
    lReplace("\d220","\d144",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d215","\d145",cvt_opts)
    lReplace("\d211","\d146",cvt_opts)
    lReplace("\d194","\d147",cvt_opts)
    lReplace("\d206","\d148",cvt_opts)
    lReplace("\d202","\d149",cvt_opts)
    lReplace("\d195","\d150",cvt_opts)
    lReplace("\d203","\d151",cvt_opts)
    lReplace("\d239","\d152",cvt_opts)
    lReplace("\d218","\d153",cvt_opts)
    lReplace("\d219","\d154",cvt_opts)
    lReplace("\d191","\d155",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d175","\d156",cvt_opts)
    lReplace("\d187","\d156",cvt_opts)      // Don't ask me why this character is duplicated in the HP set!
    lReplace("\d253","\d175",cvt_opts)
    lReplace("\d188","\d157",cvt_opts)
    lReplace("\d190","\d159",cvt_opts)
    lReplace("\d196","\d160",cvt_opts)
    lReplace("\d213","\d161",cvt_opts)
    lReplace("\d198","\d162",cvt_opts)
    lReplace("\d199","\d163",cvt_opts)
    lReplace("\d183","\d164",cvt_opts)
    lReplace("\d182","\d165",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d249","\d166",cvt_opts)
    lReplace("\d242","\d249",cvt_opts)
    lReplace("\d250","\d167",cvt_opts)
    lReplace("\d185","\d168",cvt_opts)
    lReplace("\d248","\d171",cvt_opts)
    lReplace("\d179","\d248",cvt_opts)
    lReplace("\d184","\d173",cvt_opts)
    lReplace("\d251","\d174",cvt_opts)
    lReplace("\d222","\d225",cvt_opts)
    lReplace("\d243","\d230",cvt_opts)
    lReplace("\d254","\d241",cvt_opts)
    lReplace("\d252","\d254",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc Dos2Mac()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d130","\d142",cvt_opts)
    lReplace("\d128","\d130",cvt_opts)
    lReplace("\d129","\d159",cvt_opts)
    lReplace("\d145","\d190",cvt_opts)
    lReplace("\d137","\d145",cvt_opts)
    lReplace("\d131","\d137",cvt_opts)
    lReplace("\d143","\d129",cvt_opts)
    lReplace("\d138","\d143",cvt_opts)
    lReplace("\d132","\d138",cvt_opts)
    lReplace("\d144","\d131",cvt_opts)
    lReplace("\d136","\d144",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d133","\d136",cvt_opts)
    lReplace("\d154","\d134",cvt_opts)
    lReplace("\d148","\d154",cvt_opts)
    lReplace("\d140","\d148",cvt_opts)
    lReplace("\d153","\d133",cvt_opts)
    lReplace("\d147","\d153",cvt_opts)
    lReplace("\d141","\d147",cvt_opts)
    lReplace("\d135","\d141",cvt_opts)
    lReplace("\d152","\d216",cvt_opts)
    lReplace("\d149","\d152",cvt_opts)
    lReplace("\d139","\d149",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d174","\d199",cvt_opts)
    lReplace("\d146","\d174",cvt_opts)
    lReplace("\d150","\d158",cvt_opts)
    lReplace("\d157","\d180",cvt_opts)
    lReplace("\d151","\d157",cvt_opts)
    lReplace("\d162","\d151",cvt_opts)
    lReplace("\d155","\d162",cvt_opts)
    lReplace("\d163","\d156",cvt_opts)
    lReplace("\d160","\d135",cvt_opts)
    lReplace("\d161","\d146",cvt_opts)
    lReplace("\d164","\d150",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d165","\d132",cvt_opts)
    lReplace("\d166","\d187",cvt_opts)
    lReplace("\d167","\d188",cvt_opts)
    lReplace("\d168","\d192",cvt_opts)
    lReplace("\d170","\d194",cvt_opts)
    lReplace("\d173","\d193",cvt_opts)
    lReplace("\d175","\d200",cvt_opts)
    lReplace("\d225","\d167",cvt_opts)
    lReplace("\d227","\d185",cvt_opts)
    lReplace("\d228","\d183",cvt_opts)
    lReplace("\d230","\d181",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d234","\d189",cvt_opts)
    lReplace("\d235","\d182",cvt_opts)
    lReplace("\d236","\d176",cvt_opts)
    lReplace("\d237","\d175",cvt_opts)
    lReplace("\d241","\d177",cvt_opts)
    lReplace("\d242","\d179",cvt_opts)
    lReplace("\d243","\d178",cvt_opts)
    lReplace("\d246","\d214",cvt_opts)
    lReplace("\d247","\d197",cvt_opts)
    lReplace("\d248","\d161",cvt_opts)
    lReplace("\d250","\d165",cvt_opts)
    lReplace("\d251","\d195",cvt_opts)
    EndFile()
    InsertText("")
    PopPosition()
    Message(msg + char_set + dn)
end


proc Mac2Dos()
    PushPosition()
    Message(msg + char_set + "working..")
    lReplace("\d130","\d128",cvt_opts)
    lReplace("\d165","\d250",cvt_opts)
    lReplace("\d132","\d165",cvt_opts)
    lReplace("\d138","\d132",cvt_opts)
    lReplace("\d143","\d138",cvt_opts)
    lReplace("\d129","\d143",cvt_opts)
    lReplace("\d159","\d129",cvt_opts)
    lReplace("\d142","\d130",cvt_opts)
    lReplace("\d135","\d160",cvt_opts)
    lReplace("\d141","\d135",cvt_opts)
    lReplace("\d147","\d141",cvt_opts)
    lReplace("\d153","\d147",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d133","\d153",cvt_opts)
    lReplace("\d136","\d133",cvt_opts)
    lReplace("\d144","\d136",cvt_opts)
    lReplace("\d131","\d144",cvt_opts)
    lReplace("\d137","\d131",cvt_opts)
    lReplace("\d145","\d137",cvt_opts)
    lReplace("\d149","\d139",cvt_opts)
    lReplace("\d148","\d140",cvt_opts)
    lReplace("\d190","\d145",cvt_opts)
    lReplace("\d161","\d248",cvt_opts)
    lReplace("\d146","\d161",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d174","\d146",cvt_opts)
    lReplace("\d154","\d148",cvt_opts)
    lReplace("\d152","\d149",cvt_opts)
    lReplace("\d150","\d164",cvt_opts)
    lReplace("\d158","\d150",cvt_opts)
    lReplace("\d162","\d155",cvt_opts)
    lReplace("\d151","\d162",cvt_opts)
    lReplace("\d157","\d151",cvt_opts)
    lReplace("\d216","\d152",cvt_opts)
    lReplace("\d134","\d154",cvt_opts)
    lReplace("\d180","\d157",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d156","\d163",cvt_opts)
    lReplace("\d187","\d166",cvt_opts)
    lReplace("\d167","\d225",cvt_opts)
    lReplace("\d188","\d167",cvt_opts)
    lReplace("\d192","\d168",cvt_opts)
    lReplace("\d194","\d170",cvt_opts)
    lReplace("\d193","\d173",cvt_opts)
    lReplace("\d199","\d174",cvt_opts)
    lReplace("\d175","\d237",cvt_opts)
    lReplace("\d200","\d175",cvt_opts)
    lReplace("\d185","\d227",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d183","\d228",cvt_opts)
    lReplace("\d181","\d230",cvt_opts)
    lReplace("\d189","\d234",cvt_opts)
    lReplace("\d182","\d235",cvt_opts)
    lReplace("\d176","\d236",cvt_opts)
    lReplace("\d177","\d241",cvt_opts)
    lReplace("\d179","\d242",cvt_opts)
    lReplace("\d178","\d243",cvt_opts)
    lReplace("\d214","\d246",cvt_opts)
    lReplace("\d197","\d247",cvt_opts)
    lReplace("\d195","\d251",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc Ansi2Mac()
    PushPosition()
    Message(msg + char_set + "working..")

    lReplace("\d199","\d130",cvt_opts)
    lReplace("\d171","\d199",cvt_opts)
    lReplace("\d252","\d159",cvt_opts)
    lReplace("\d233","\d142",cvt_opts)
    lReplace("\d226","\d137",cvt_opts)
    lReplace("\d228","\d138",cvt_opts)
    lReplace("\d224","\d136",cvt_opts)
    lReplace("\d229","\d140",cvt_opts)
    lReplace("\d231","\d141",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d234","\d144",cvt_opts)
    lReplace("\d235","\d145",cvt_opts)
    lReplace("\d232","\d143",cvt_opts)
    lReplace("\d239","\d149",cvt_opts)
    lReplace("\d238","\d148",cvt_opts)
    lReplace("\d236","\d147",cvt_opts)
    lReplace("\d196","\d128",cvt_opts)
    lReplace("\d197","\d129",cvt_opts)
    lReplace("\d201","\d131",cvt_opts)
    lReplace("\d230","\d190",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d198","\d174",cvt_opts)
    lReplace("\d244","\d153",cvt_opts)
    lReplace("\d246","\d154",cvt_opts)
    lReplace("\d242","\d152",cvt_opts)
    lReplace("\d251","\d158",cvt_opts)
    lReplace("\d249","\d157",cvt_opts)
    lReplace("\d255","\d216",cvt_opts)
    lReplace("\d214","\d133",cvt_opts)
    lReplace("\d220","\d134",cvt_opts)
    lReplace("\d162","\d162",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d163","\d163",cvt_opts)
    lReplace("\d165","\d180",cvt_opts)
    lReplace("\d183","\d165",cvt_opts)
    lReplace("\d225","\d135",cvt_opts)
    lReplace("\d237","\d146",cvt_opts)
    lReplace("\d243","\d151",cvt_opts)
    lReplace("\d250","\d156",cvt_opts)
    lReplace("\d241","\d150",cvt_opts)
    lReplace("\d209","\d132",cvt_opts)
    lReplace("\d187","\d200",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d170","\d187",cvt_opts)
    lReplace("\d186","\d188",cvt_opts)
    lReplace("\d191","\d192",cvt_opts)
    lReplace("\d172","\d194",cvt_opts)
    lReplace("\d189","\d193",cvt_opts)
    lReplace("\d223","\d167",cvt_opts)
    lReplace("\d181","\d181",cvt_opts)
    lReplace("\d248","\d175",cvt_opts)
    lReplace("\d177","\d177",cvt_opts)
    EndFile()
    InsertText("")
    PopPosition()
    Message(msg + char_set + dn)
end


proc Mac2Ansi()
    PushPosition()
    Message(msg + char_set + "working..")

    lReplace("\d199","\d171",cvt_opts)
    lReplace("\d130","\d199",cvt_opts)
    lReplace("\d159","\d252",cvt_opts)
    lReplace("\d142","\d233",cvt_opts)
    lReplace("\d137","\d226",cvt_opts)
    lReplace("\d138","\d228",cvt_opts)
    lReplace("\d136","\d224",cvt_opts)
    lReplace("\d140","\d229",cvt_opts)
    lReplace("\d141","\d231",cvt_opts)
    Message(msg + char_set + "20% " + dn)

    lReplace("\d144","\d234",cvt_opts)
    lReplace("\d145","\d235",cvt_opts)
    lReplace("\d143","\d232",cvt_opts)
    lReplace("\d149","\d239",cvt_opts)
    lReplace("\d148","\d238",cvt_opts)
    lReplace("\d147","\d236",cvt_opts)
    lReplace("\d128","\d196",cvt_opts)
    lReplace("\d129","\d197",cvt_opts)
    lReplace("\d131","\d201",cvt_opts)
    lReplace("\d190","\d230",cvt_opts)
    Message(msg + char_set + "40% " + dn)

    lReplace("\d174","\d198",cvt_opts)
    lReplace("\d153","\d244",cvt_opts)
    lReplace("\d154","\d246",cvt_opts)
    lReplace("\d152","\d242",cvt_opts)
    lReplace("\d158","\d251",cvt_opts)
    lReplace("\d157","\d249",cvt_opts)
    lReplace("\d216","\d255",cvt_opts)
    lReplace("\d133","\d214",cvt_opts)
    lReplace("\d134","\d220",cvt_opts)
    lReplace("\d162","\d162",cvt_opts)
    Message(msg + char_set + "60% " + dn)

    lReplace("\d163","\d163",cvt_opts)
    lReplace("\d165","\d183",cvt_opts)
    lReplace("\d180","\d165",cvt_opts)
    lReplace("\d135","\d225",cvt_opts)
    lReplace("\d146","\d237",cvt_opts)
    lReplace("\d151","\d243",cvt_opts)
    lReplace("\d156","\d250",cvt_opts)
    lReplace("\d150","\d241",cvt_opts)
    lReplace("\d132","\d209",cvt_opts)
    lReplace("\d187","\d170",cvt_opts)
    Message(msg + char_set + "80% " + dn)

    lReplace("\d188","\d186",cvt_opts)
    lReplace("\d192","\d191",cvt_opts)
    lReplace("\d194","\d172",cvt_opts)
    lReplace("\d193","\d189",cvt_opts)
    lReplace("\d200","\d187",cvt_opts)
    lReplace("\d167","\d223",cvt_opts)
    lReplace("\d181","\d181",cvt_opts)
    lReplace("\d175","\d248",cvt_opts)
    lReplace("\d177","\d177",cvt_opts)
    PopPosition()
    Message(msg + char_set + dn)
end


proc CvtChars()             // Start Conversion & call the requested
    integer key                // conversion table above.

    Set (Break,ON)
    if isCursorInBlock()        // Allow conversion of partial file.
        cvt_opts = "xlgn"
    else
        cvt_opts = "xgn"
        PopWinOpen(25,11,53,14,3,"",Query(CurrWinBorderAttr))
        VGotoXY(1,1)
        PutStr("  Converting Entire File   ")
        VGotoXY(1,2)
        PutStr("Press any Key, <N> to abort")
        key = GetKey()
        case key                // Allow second thoughts.
            when <N>, <Shift N>
                PopWinClose()
                return()
        endcase
        PopWinClose()
    endif
    case cvt_table
        when 1 Dos2Ansi()
        when 2 Ansi2Dos()
        when 3 Dos2Hp()
        when 4 Hp2Dos()
        when 5 Dos2Mac()
        when 6 Mac2Dos()
        when 7 Ansi2Mac()
        when 8 Mac2Ansi()
    endcase
end


proc YesNoCvtChrs()      // Determine the presence of hi-bit chars
    string fnd_opts[4]
    string fnd_zone[5]
    integer cuenta = 0

    PushPosition()
    if isCursorInBlock()       // Allow conversion of partial file.
        fnd_opts = "xlgn"
        fnd_zone = "Block"
    else
        fnd_opts = "xgn"
        fnd_zone = "File"
    endif
    if lFind("[Ä-ˇ]",fnd_opts)
        repeat
            cuenta = cuenta + 1
        until not lRepeatfind()
        Message(fnd_zone + " needs conversion, " + Str(cuenta) + " chars.")
    else
        Message(fnd_zone + " OK without conversion.")
    endif
    PopPosition()
end


proc Locate()               // Locate & count unconvertible chars

    string fnd_opts[4]
    string fnd_zone[5]
    integer cuenta = 0

    PushPosition()
    if isCursorInBlock()       // Allow conversion of partial file.
        fnd_opts = "xlg"
        fnd_zone = "block"
    else
        fnd_opts = "xg"
        fnd_zone = "file"
    endif
    if lFind(fnd_str,fnd_opts)
        repeat
            cuenta = cuenta + 1
        until not lRepeatfind()
        PopPosition()
        Find(fnd_str,fnd_opts)
    else
        PopPosition()
    endif
    Message(fnd_zone + " contains, " + Str(cuenta) + " unconvertible chars." +
    " Use <Esc> & RepeatFind to go to chars.")
end


menu ActionMenu()       // Choice of find unconvertible chars or do conversion
    x = 27
    y = 10

    "Do &Conversion."           ,  CvtChars()

    "&GoTo Unconvertible Chars" ,  Locate(), DontClose,
        "Locate Chars that can't be converted to the target set."
end


proc Setup(integer cvt_set)     // Set strings & call Action Menu
    cvt_table = cvt_set

    case cvt_set
        when 1
            char_set = "DOS - ANSI/ISO.. "
            fnd_str = "[ûü©∞-‡‚-ÂÁÈ-ÏÓ-Ú-ı˜˘˚¸˛ˇ]"
        when 2
            char_set = "ANSI/ISO - DOS.. "
            fnd_str =  "[Å-†§ß®©≠ÆØ≥¥∂∏πæ¿-√» -–“-’◊Ÿ-€›ﬁ„ı˝˛]"
        when 3
            char_set = "DOS - HP ROMAN-8.. "
            fnd_str =  "[û©™∞-‡‚-ÂÁ-Ú-˜˙-˝]"
        when 4
            char_set = "HP ROMAN-8 - DOS.. "
            fnd_str =  "[Ä-®´≠Æ∞-≤∫“÷ﬂ-ÓÒıˆ]"
        when 5
            char_set = "DOS - MACINTOSH.. "
            fnd_str =  "[Üéúûü©´¨∞-‡‚ÂÁ-ÈÓ-Ùı˘¸-ˇ]"
        when 6
            char_set = "MACINTOSH - DOS.. "
            fnd_str =  "[Äãåõ†£§¶®-≠∏∫øƒ∆…-’◊Ÿ-ˇ]"
        when 7
            char_set = "ANSI/ISO - MACINTOSH.. "
            fnd_str =  "[Ä-°§¶-©≠-∞≤-¥∂∏πºæ¿-√» -–“-’◊-€›ﬁ„ı˜˝˛]"
        when 8
            char_set = "MACINTOSH - ANSI/ISO.. "
            fnd_str =  "[ãõ†°§¶®-≠∞≤≥∂-∫Ωø√-∆…-◊Ÿ-ˇ]"
    endcase
    Message(char_set)
    ActionMenu()
end


menu Direction()    // Starting point, choose char. set & calls setup
    title = "High-bit Character Set Conversions"
    history
    x = 27
    y = 5

    " Need &Conversion?", YesNoCvtChrs() , DontClose,
"Any chars in current block or file needing conversion?"
    "Choice of Conversions"   ,           ,Divide
    "DOS - ANSI/ISO.."        ,  Setup(1) ,CloseBefore   // Dos2Ansi
    "ANSI/ISO - DOS.."        ,  Setup(2) ,CloseBefore   // Ansi2Dos
    "DOS - HP ROMAN-8.."      ,  Setup(3) ,CloseBefore   // Dos2Hp
    "HP ROMAN-8 - DOS.."      ,  Setup(4) ,CloseBefore   // Hp2Dos
    "DOS - MACINTOSH.."       ,  Setup(5) ,CloseBefore   // Dos2Mac
    "MACINTOSH - DOS.."       ,  Setup(6) ,CloseBefore   // Mac2Dos
    "ANSI/ISO - MACINTOSH.."  ,  Setup(7) ,CloseBefore   // Ansi2Mac
    "MACINTOSH - ANSI/ISO.."  ,  Setup(8) ,CloseBefore   // Mac2Ansi
end



<Ctrl k><F5>  Direction()
// <Key_of_your_choice>  Direction()
