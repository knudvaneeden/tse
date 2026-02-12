library GetFldr;

{**********************************************************************}
{                                                                      }
{   GetFldr                                                            }
{                                                                      }
{   determine name of desktop folder                                   }
{                                                                      }
{   Version     v2.10/20.04.01                                         }
{   Copyright   (c) 2000 by DiK                                        }
{                                                                      }
{   History                                                            }
{   v2.10/20.04.01  new for this version                               }
{                                                                      }
{**********************************************************************}

{----------------------------------------------------------------------}
{   libraries                                                          }
{----------------------------------------------------------------------}

uses
  Windows, ShlObj, ActiveX;

{----------------------------------------------------------------------}
{   types                                                              }
{----------------------------------------------------------------------}

type
  PSalStr = ^TSalStr;
  TSalStr = record
    Size: SmallInt;
    Data: array [0..255] of Char;
  end;

{----------------------------------------------------------------------}
{   functions                                                          }
{----------------------------------------------------------------------}

procedure GetSpecialFolder(
  Folder: Integer; StrData: PSalStr; StrSize: Integer); stdcall;
var
  I: SmallInt;
  Code: HResult;
  ShellMalloc: IMalloc;
  ItemIdList: PItemIdList;
  FolderName: array [0..MAX_PATH] of Char;
begin

  FolderName[0] := #0;

  Code := ShGetMalloc(ShellMalloc);
  if (Code = NOERROR) and (ShellMalloc <> nil) then
  begin
    Code := SHGetSpecialFolderLocation(0, Folder, ItemIdList);
    if (Code = NOERROR) and (ItemIdList <> nil) then
      if SHGetPathFromIDList(ItemIdList, FolderName) then
        ShellMalloc.Free(ItemIdList);
  end;

  with StrData^ do
  begin
    I := 0;
    while FolderName[I] <> #0 do
    begin
      if I = StrSize then
      begin
        I := 0;
        Break;
      end;
      Data[I] := FolderName[I];
      Inc(I);
    end;
    Size := I;
  end;

end;

{----------------------------------------------------------------------}
{   exports                                                            }
{----------------------------------------------------------------------}

exports
  GetSpecialFolder index 1;

end.
