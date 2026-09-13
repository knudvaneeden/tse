/*
 * speak_bcc55.cpp
 * Version 1.0.0.0.0 - 2026-09-13
 * Borland C++ 5.5.1 implementation for 32-bit TSE.
 * Uses late-bound Windows SAPI.SpVoice Automation: no sapi.h or ATL required.
 */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <oleauto.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_ASYNC 32

struct ASYNC_ITEM {
    int active;
    int uid;
    char *text;
    int textLength;
    HANDLE thread;
    DWORD threadId;
};

static CRITICAL_SECTION gLock;
static int gLockReady = 0;
static int gInitialized = 0;
static int gVoiceCount = 0;
static int gVoice = 0;
static int gVolume = 35;
static ASYNC_ITEM gAsync[MAX_ASYNC];

static HRESULT get_id(IDispatch *object, const wchar_t *name, DISPID *id)
{
    LPOLESTR names[1];
    names[0] = (LPOLESTR)name;
    return object->GetIDsOfNames(IID_NULL, names, 1, LOCALE_USER_DEFAULT, id);
}

static HRESULT invoke_name(IDispatch *object, const wchar_t *name, WORD flags,
                           VARIANT *args, UINT count, VARIANT *result)
{
    DISPID id;
    DISPPARAMS dp;
    DISPID putId = DISPID_PROPERTYPUT;
    HRESULT hr;

    if (!object) return E_POINTER;
    hr = get_id(object, name, &id);
    if (FAILED(hr)) return hr;

    memset(&dp, 0, sizeof(dp));
    dp.rgvarg = args;
    dp.cArgs = count;
    if (flags & (DISPATCH_PROPERTYPUT | DISPATCH_PROPERTYPUTREF)) {
        dp.rgdispidNamedArgs = &putId;
        dp.cNamedArgs = 1;
    }
    if (result) VariantInit(result);
    return object->Invoke(id, IID_NULL, LOCALE_USER_DEFAULT, flags,
                          &dp, result, NULL, NULL);
}

static BSTR ansi_to_bstr(const char *text, int length)
{
    int chars;
    BSTR value;
    if (!text || length < 0) return NULL;
    chars = MultiByteToWideChar(CP_ACP, 0, text, length, NULL, 0);
    if (chars <= 0) return NULL;
    value = SysAllocStringLen(NULL, chars);
    if (!value) return NULL;
    MultiByteToWideChar(CP_ACP, 0, text, length, value, chars);
    value[chars] = 0;
    return value;
}

static HRESULT create_voice(IDispatch **voice)
{
    CLSID clsid;
    HRESULT hr;
    *voice = NULL;
    hr = CLSIDFromProgID(L"SAPI.SpVoice", &clsid);
    if (FAILED(hr)) return hr;
    return CoCreateInstance(clsid, NULL, CLSCTX_INPROC_SERVER | CLSCTX_LOCAL_SERVER,
                            IID_IDispatch, (void **)voice);
}

static int get_voice_count(IDispatch *voice)
{
    VARIANT voices;
    VARIANT count;
    HRESULT hr;
    int answer = 0;
    VariantInit(&voices);
    VariantInit(&count);

    hr = invoke_name(voice, L"GetVoices", DISPATCH_METHOD, NULL, 0, &voices);
    if (SUCCEEDED(hr) && voices.vt == VT_DISPATCH && voices.pdispVal) {
        hr = invoke_name(voices.pdispVal, L"Count", DISPATCH_PROPERTYGET,
                         NULL, 0, &count);
        if (SUCCEEDED(hr)) {
            if (count.vt == VT_I4) answer = (int)count.lVal;
            else if (count.vt == VT_I2) answer = (int)count.iVal;
        }
    }
    VariantClear(&count);
    VariantClear(&voices);
    return answer;
}

static HRESULT set_volume_on(IDispatch *voice, int volume)
{
    VARIANT value;
    VariantInit(&value);
    value.vt = VT_I4;
    value.lVal = volume;
    return invoke_name(voice, L"Volume", DISPATCH_PROPERTYPUT, &value, 1, NULL);
}

static HRESULT get_voice_token(IDispatch *voice, int number, IDispatch **token)
{
    VARIANT voices;
    VARIANT index;
    VARIANT item;
    HRESULT hr;
    *token = NULL;
    VariantInit(&voices);
    VariantInit(&index);
    VariantInit(&item);

    hr = invoke_name(voice, L"GetVoices", DISPATCH_METHOD, NULL, 0, &voices);
    if (SUCCEEDED(hr) && voices.vt == VT_DISPATCH && voices.pdispVal) {
        index.vt = VT_I4;
        index.lVal = number;
        hr = invoke_name(voices.pdispVal, L"Item", DISPATCH_METHOD,
                         &index, 1, &item);
        if (SUCCEEDED(hr) && item.vt == VT_DISPATCH && item.pdispVal) {
            *token = item.pdispVal;
            (*token)->AddRef();
        } else hr = E_FAIL;
    }
    VariantClear(&item);
    VariantClear(&voices);
    return hr;
}

static HRESULT set_voice_on(IDispatch *voice, int number)
{
    IDispatch *token;
    VARIANT value;
    HRESULT hr = get_voice_token(voice, number, &token);
    if (FAILED(hr)) return hr;
    VariantInit(&value);
    value.vt = VT_DISPATCH;
    value.pdispVal = token;
    hr = invoke_name(voice, L"Voice", DISPATCH_PROPERTYPUTREF, &value, 1, NULL);
    token->Release();
    return hr;
}

static int speak_on(IDispatch *voice, const char *text, int length)
{
    VARIANT args[2];
    VARIANT result;
    BSTR speech;
    HRESULT hr;
    if (!text || length <= 0) return -1;
    speech = ansi_to_bstr(text, length);
    if (!speech) return -2;

    VariantInit(&args[0]);
    VariantInit(&args[1]);
    args[0].vt = VT_I4;            /* Flags; COM arguments are reversed. */
    args[0].lVal = 0;
    args[1].vt = VT_BSTR;
    args[1].bstrVal = speech;
    hr = invoke_name(voice, L"Speak", DISPATCH_METHOD, args, 2, &result);
    VariantClear(&result);
    SysFreeString(speech);
    return SUCCEEDED(hr) ? length : -3;
}

static int speak_new_voice(const char *text, int length, int voiceNumber, int volume)
{
    IDispatch *voice;
    HRESULT hr;
    int answer;
    hr = create_voice(&voice);
    if (FAILED(hr)) return -4;
    set_volume_on(voice, volume);
    set_voice_on(voice, voiceNumber);
    answer = speak_on(voice, text, length);
    voice->Release();
    return answer;
}

static char *read_file(const char *filename, int *length)
{
    FILE *file;
    long size;
    char *data;
    *length = 0;
    file = fopen(filename, "rb");
    if (!file) return NULL;
    if (fseek(file, 0, SEEK_END) != 0 || (size = ftell(file)) <= 0 ||
        fseek(file, 0, SEEK_SET) != 0) {
        fclose(file);
        return NULL;
    }
    data = (char *)malloc((size_t)size + 1);
    if (!data) { fclose(file); return NULL; }
    if (fread(data, 1, (size_t)size, file) != (size_t)size) {
        free(data); fclose(file); return NULL;
    }
    fclose(file);
    data[size] = 0;
    *length = (int)size;
    return data;
}

static DWORD WINAPI async_thread(LPVOID parameter)
{
    ASYNC_ITEM *item = (ASYNC_ITEM *)parameter;
    CoInitialize(NULL);
    speak_new_voice(item->text, item->textLength, gVoice, gVolume);
    EnterCriticalSection(&gLock);
    item->active = 0;
    if (item->text) free(item->text);
    item->text = NULL;
    if (item->thread) CloseHandle(item->thread);
    item->thread = NULL;
    LeaveCriticalSection(&gLock);
    CoUninitialize();
    return 0;
}

static ASYNC_ITEM *find_async(int uid)
{
    int i;
    for (i = 0; i < MAX_ASYNC; ++i)
        if (gAsync[i].active && gAsync[i].uid == uid) return &gAsync[i];
    return NULL;
}

extern "C" __declspec(dllexport) int __stdcall speak_initialize(void)
{
    IDispatch *voice;
    HRESULT hr;
    if (gInitialized) return gVoiceCount;
    hr = CoInitialize(NULL);
    if (FAILED(hr) && hr != RPC_E_CHANGED_MODE) return -1;
    if (!gLockReady) {
        InitializeCriticalSection(&gLock);
        memset(gAsync, 0, sizeof(gAsync));
        gLockReady = 1;
    }
    hr = create_voice(&voice);
    if (FAILED(hr)) return -2;
    gVoiceCount = get_voice_count(voice);
    voice->Release();
    if (gVoiceCount < 1) return 0;
    gInitialized = 1;
    return gVoiceCount;
}

extern "C" __declspec(dllexport) int __stdcall speak_text(const char *text, int textLength)
{
    if (speak_initialize() < 1) return -1;
    return speak_new_voice(text, textLength, gVoice, gVolume);
}

extern "C" __declspec(dllexport) int __stdcall speak_text_file(const char *filename)
{
    int length;
    int answer;
    char *text = read_file(filename, &length);
    if (!text) return -1;
    answer = speak_text(text, length);
    free(text);
    return answer;
}

extern "C" __declspec(dllexport) int __stdcall speak_text_async(const char *text, int textLength, int uid)
{
    int i;
    ASYNC_ITEM *item = NULL;
    if (speak_initialize() < 1 || !text || textLength <= 0) return -1;
    EnterCriticalSection(&gLock);
    if (find_async(uid)) { LeaveCriticalSection(&gLock); return -2; }
    for (i = 0; i < MAX_ASYNC; ++i)
        if (!gAsync[i].active) { item = &gAsync[i]; break; }
    if (!item) { LeaveCriticalSection(&gLock); return -3; }
    item->text = (char *)malloc((size_t)textLength + 1);
    if (!item->text) { LeaveCriticalSection(&gLock); return -4; }
    memcpy(item->text, text, (size_t)textLength);
    item->text[textLength] = 0;
    item->textLength = textLength;
    item->uid = uid;
    item->active = 1;
    item->thread = CreateThread(NULL, 0, async_thread, item, 0, &item->threadId);
    if (!item->thread) {
        free(item->text); item->text = NULL; item->active = 0;
        LeaveCriticalSection(&gLock); return -5;
    }
    LeaveCriticalSection(&gLock);
    return uid;
}

extern "C" __declspec(dllexport) int __stdcall speak_text_async_file(const char *filename, int uid)
{
    int length;
    int answer;
    char *text = read_file(filename, &length);
    if (!text) return -1;
    answer = speak_text_async(text, length, uid);
    free(text);
    return answer;
}

extern "C" __declspec(dllexport) int __stdcall speak_text_async_pause(int uid)
{
    ASYNC_ITEM *item;
    DWORD result;
    EnterCriticalSection(&gLock);
    item = find_async(uid);
    result = item ? SuspendThread(item->thread) : (DWORD)-1;
    LeaveCriticalSection(&gLock);
    return result == (DWORD)-1 ? -1 : uid;
}

extern "C" __declspec(dllexport) int __stdcall speak_text_async_resume(int uid)
{
    ASYNC_ITEM *item;
    DWORD result;
    EnterCriticalSection(&gLock);
    item = find_async(uid);
    result = item ? ResumeThread(item->thread) : (DWORD)-1;
    LeaveCriticalSection(&gLock);
    return result == (DWORD)-1 ? -1 : uid;
}

extern "C" __declspec(dllexport) int __stdcall speak_text_async_stop(int uid)
{
    ASYNC_ITEM *item;
    EnterCriticalSection(&gLock);
    item = find_async(uid);
    if (!item) { LeaveCriticalSection(&gLock); return -1; }
    TerminateThread(item->thread, 0);
    CloseHandle(item->thread);
    item->thread = NULL;
    if (item->text) free(item->text);
    item->text = NULL;
    item->active = 0;
    LeaveCriticalSection(&gLock);
    return uid;
}

extern "C" __declspec(dllexport) int __stdcall speak_set_volume(int volume)
{
    if (volume < 0) volume = 0;
    if (volume > 100) volume = 100;
    gVolume = volume;
    return gVolume;
}

extern "C" __declspec(dllexport) int __stdcall speak_set_voice(int voiceNum)
{
    if (speak_initialize() < 1) return -1;
    if (voiceNum < 0 || voiceNum >= gVoiceCount) return -2;
    gVoice = voiceNum;
    return gVoice;
}

extern "C" __declspec(dllexport) int __stdcall speak_get_voice_info(int voiceNum, char *output255)
{
    IDispatch *voice;
    IDispatch *token;
    VARIANT description;
    HRESULT hr;
    int bytes;
    if (!output255) return -1;
    output255[0] = 0;
    if (speak_initialize() < 1) return -2;
    if (voiceNum < 0 || voiceNum >= gVoiceCount) return -3;
    hr = create_voice(&voice);
    if (FAILED(hr)) return -4;
    hr = get_voice_token(voice, voiceNum, &token);
    voice->Release();
    if (FAILED(hr)) return -5;
    VariantInit(&description);
    hr = invoke_name(token, L"GetDescription", DISPATCH_METHOD,
                     NULL, 0, &description);
    token->Release();
    if (FAILED(hr) || description.vt != VT_BSTR) {
        VariantClear(&description); return -6;
    }
    bytes = WideCharToMultiByte(CP_ACP, 0, description.bstrVal, -1,
                                output255, 255, NULL, NULL);
    output255[254] = 0;
    VariantClear(&description);
    return bytes > 0 ? (int)strlen(output255) : -7;
}

BOOL WINAPI DllEntryPoint(HINSTANCE instance, DWORD reason, LPVOID reserved)
{
    instance = instance;
    reserved = reserved;
    if (reason == DLL_PROCESS_DETACH && gLockReady)
        DeleteCriticalSection(&gLock);
    return TRUE;
}
