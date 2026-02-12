/*
   Macro          ReadReg.
   Author         Carlo.Hogeveen@xs4all.nl.
   Date           5 jun 2005.

   This macro demonstrates reading the Windows registry.
*/

constant
   ERROR_SUCCESS           = 0,
   ERROR_NO_MORE_ITEMS     = 259,

   HKEY_CLASSES_ROOT       = 0x80000000,
   HKEY_CURRENT_USER       = 0x80000001,
   HKEY_LOCAL_MACHINE      = 0x80000002,
   HKEY_USERS              = 0x80000003,
   HKEY_PERFORMANCE_DATA   = 0x80000004,
   HKEY_CURRENT_CONFIG     = 0x80000005,
   HKEY_DYN_DATA           = 0x80000006,

   KEY_QUERY_VALUE         = 0x0001

dll "<advapi32.dll>"
   integer proc RegOpenKeyEx(
      integer     hKey,
      string      lpSubKey:cstrval,
      integer     ulOptions,
      integer     samDesired,
      var integer phkResult
      ):"RegOpenKeyExA"
   integer proc RegEnumValue(
      integer     hKey,
      integer     dwIndex,
      integer     lpValueName,
      var integer lpcValueName,
      integer     lpReserved,
      integer     lpType,
      integer     lpData,
      var integer lpcbData
      ):"RegEnumValueA"
   integer proc RegCloseKey(
      integer     hKey
      )
end

proc set_string_length(integer string_adr, integer string_len)
   if string_len < 2
      // An empty string has no traling zero byte.
      PokeWord(string_adr - 2, 0)
   else
      // Ignore trailing zero byte.
      PokeWord(string_adr - 2, string_len - 1)
   endif
end

proc Main()
   integer reg_rootkey           = HKEY_CLASSES_ROOT
   string  reg_subkey [255]      = ".txt"
   integer reg_options           = 0
   integer reg_access            = KEY_QUERY_VALUE
   integer reg_key_handle        = 0
   integer reg_value_index       = -1
   string  reg_value_name [255]  = Format("":255)
   integer reg_value_name_adr    = Addr(reg_value_name) + 2
   integer reg_value_name_len    = 255
   integer reg_value_type        = 0
   string  reg_value_data [255]  = Format("":255)
   integer reg_value_data_adr    = Addr(reg_value_data) + 2
   integer reg_value_data_len    = 255
   integer reg_error             = 0
   if RegOpenKeyEx(reg_rootkey, reg_subkey, reg_options, reg_access,
         reg_key_handle) == ERROR_SUCCESS
      Message("Open key succeeded (reg_key_handle = ", reg_key_handle,")")
      Delay(36)
      repeat
         reg_value_index    = reg_value_index + 1
         reg_value_name_len = 255
         reg_value_data_len = 255
         reg_error = RegEnumValue(  reg_key_handle,
                                    reg_value_index,
                                    reg_value_name_adr,
                                    reg_value_name_len,
                                    reg_options,
                                    reg_value_type,
                                    reg_value_data_adr,
                                    reg_value_data_len)
         if reg_error == ERROR_SUCCESS
            set_string_length(reg_value_name_adr, reg_value_name_len)
            set_string_length(reg_value_data_adr, reg_value_data_len)
            MsgBox(  'Value name = "'
                     + reg_value_name
                     + '".'
                     + Chr(13)
                     + 'Value data = "'
                     + reg_value_data
                     + '".')
         elseif reg_error == ERROR_NO_MORE_ITEMS
            Warn('No more values.')
         else
            Warn('Error reading key: ', reg_error)
         endif
         Delay(9)
      until reg_error <> ERROR_SUCCESS
      if RegCloseKey(reg_key_handle) == ERROR_SUCCESS
         Message("Close key succeeded")
         Delay(36)
      else
         Message("Close key failed")
         Delay(36)
      endif
   else
      Message("Open key failed")
      Delay(36)
   endif
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

