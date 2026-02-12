
dll "<kernel32.dll>"
    integer proc GetShortPathName(string inpath:cstrval, var string outpath:strptr, integer len) : "GetShortPathNameA"
end

/**************************************************************************
  GetShortPathName only works for existing path's..., so create inpath if
  it does not already exist.
 **************************************************************************/
string proc mGetShortPathname(string inpath)
    integer len
    string short_path[_MAXPATH_] = Format("":_MAXPATH_:Chr(0))

    len = GetShortPathName(inpath, short_path, _MAXPATH_)
    return (iif(len > 0, short_path[1:Pos(Chr(0), short_path) - 1], inpath))
end

/**************************************************************************
  c:\dir1\dir2\dirn\name.ext
 **************************************************************************/
string proc mExpandPath(string inpath)
    string path[_MAXPATH_], fn[_MAXPATH_]

    path = ExpandPath(inpath)
    fn = ""
    if isWildPath(path)
        fn = SplitPath(path, _NAME_|_EXT_)
        path = RemoveTrailingSlash(SplitPath(path, _DRIVE_|_PATH_))
    endif

    path = mGetShortPathname(path)
    if fn <> ""
        path = path + "\" + fn
    endif
    return (path)
end

string proc pickFileFormat(string cFullPath)
    string lfn[9], lext[5], fn[9], ext[4], s[100], size[9]
    integer save_date_format

    lfn = SplitPath(PBName(), _NAME_)
    lext = SplitPath(PBName(), _EXT_)

    if Length(lfn) > 8 or Length(lext) > 4
        s = mGetShortPathname(AddTrailingSlash(SplitPath(cFullPath, _DRIVE_|_PATH_)) + PBName())
        fn = SplitPath(s, _NAME_)
        ext = SplitPath(s, _EXT_)
    else
        fn = lfn
        ext = lext
    endif

    if ext[1] == "."
        ext = DelStr(ext, 1, 1)
    endif

    size = Str(PBSize())

    if PBAttribute() & _DIRECTORY_
        size = "  <DIR>  "
        if fn == ""
            fn = ".."
        endif
        fn = "\" + fn
    endif

    save_date_format = Set(DateFormat, 1)
    s = Format("   ", fn:-9; ext:-3; size:9; PBDateStr():8; PBTimeStr():8)
    Set(DateFormat, save_date_format)
    return (s)
end

