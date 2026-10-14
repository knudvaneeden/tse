// UTF8SHORT 1.0.0.0.4 - OpenAI Codex (GPT-6).
// DLL is preloaded by utf8short.mac from its own directory.
dll "<utf8short.dll>"
    integer proc pascal UniSelect(integer ownerI)
    integer proc pascal UniFromUtf8(string inputS)
    integer proc pascal UniByte(integer indexI)
    integer proc pascal UniError()
end
