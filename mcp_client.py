# mcp_client.py
# TSE MCP Client - filesystem server over stdio
# Place in: c:\temp\mcp_client.py
# <version>1.0.0.0.6</version>

import subprocess
import json
import sys
import os
import anthropic

# --- Server config ---
# SERVER_CMD = ["npx", "-y", "@modelcontextprotocol/server-filesystem", "."]
SERVER_CMD = [r"G:\LANGUAGE\COMPUTER\NODEJS\npx.cmd", "-y", "@modelcontextprotocol/server-filesystem", "."]
SERVER_CWD = r"c:\temp"
REQ_FILE   = r"c:\temp\mcp_req.json"
RESP_FILE  = r"c:\temp\mcp_resp.json"

def send(proc, obj):
    line = json.dumps(obj) + "\n"
    proc.stdin.write(line.encode("utf-8"))
    proc.stdin.flush()

def recv(proc):
    line = proc.stdout.readline()
    return json.loads(line.decode("utf-8"))

def write_resp(result):
    """Write response to RESP_FILE.
    If the MCP result contains a plain text payload, write that directly.
    Otherwise write the full JSON so nothing is lost.
    """
    text = None
    try:
        text = result.get("content", [{}])[0].get("text", "")
    except (AttributeError, IndexError, TypeError):
        pass

    if text:
        open(RESP_FILE, "w", encoding="utf-8").write(text)
    else:
        json.dump(result, open(RESP_FILE, "w", encoding="utf-8"), indent=2)

def do_autofix(req):
    """Read SAL source + sc32 errors, ask Claude to fix, write fixed source
    back to content_file so SAL can retry compilation.
    Returns: "fixed" | "no_errors" | "error: ..."
    """
    source_file  = req.get("source_file")
    error_file   = req.get("error_file")
    content_file = req.get("content_file", r"c:\temp\mcp_content.tmp")
    attempt      = req.get("attempt", 1)

    if not source_file or not error_file:
        return "error: missing source_file or error_file in request"

    if not os.path.exists(source_file):
        return "error: source_file not found: " + source_file
    if not os.path.exists(error_file):
        return "error: error_file not found: " + error_file

    source = open(source_file,  encoding="utf-8").read()
    errors = open(error_file,   encoding="utf-8").read()

    # If no errors in output, nothing to fix
    if "Error" not in errors and "error" not in errors:
        return "no_errors"

    # Strip deliberate-error comments so Claude does not treat them as intentional
    import re
    source = re.sub(r'//\s*DELIBERATE ERROR[^\n]*\n', '', source)

    # Call Claude API
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        return "error: ANTHROPIC_API_KEY not set"

    client = anthropic.Anthropic(api_key=api_key)

    prompt = f"""You are a TSE SAL (SemWare Application Language) expert.
The following SAL source file failed to compile. Fix ALL compilation errors.
Return ONLY the corrected SAL source code with no explanation, no markdown, no code fences.
Do NOT include the original errors or comments about them in the output.

Attempt: {attempt} of 3

=== CRITICAL SAL RULES ===
- All variables (integer, string) MUST be declared at the top of the proc, before any executable statements
- There is NO NextBuffer() function in SAL - use NextFile(_DONT_LOAD_) instead
- There is NO _SYSTEM_ constant in SAL
- To walk all open buffers use: repeat / NextFile(_DONT_LOAD_) / until GetBufferId() == orig_id
- String length must be declared: string myvar[255]
- Use CurrFilename() to get the current buffer's filename
- Use GetBufferId() to get current buffer id
- Use GotoBufferId(id) to switch buffers
- lList() shows a pick list
- CreateTempBuffer() creates a temporary buffer
- AbandonFile(id) closes a buffer without saving

=== COMPILER ERRORS ===
{errors}

=== SAL SOURCE TO FIX ===
{source}
"""

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=4096,
        messages=[{"role": "user", "content": prompt}]
    )

    fixed_source = response.content[0].text.strip()

    # Sanity check - if response still contains known bad symbols, warn
    if "NextBuffer" in fixed_source or "buf_id = NextBuffer" in fixed_source:
        open(RESP_FILE, "w", encoding="utf-8").write(
            "WARNING attempt " + str(attempt) + ": Claude returned unfixed source - NextBuffer still present"
        )

    # Write fixed source back to content_file for SAL to pick up
    open(content_file, "w", encoding="utf-8").write(fixed_source)

    return "fixed attempt " + str(attempt)

def main():
    # Load request written by TSE SAL
    if not os.path.exists(REQ_FILE):
        open(RESP_FILE, "w", encoding="utf-8").write("ERROR: mcp_req.json not found")
        sys.exit(1)

    req = json.load(open(REQ_FILE, encoding="utf-8"))
    method = req.get("method", "tools/list")

    # --- autofix is handled entirely in Python, no MCP server needed ---
    if method == "autofix":
        result = do_autofix(req)
        open(RESP_FILE, "w", encoding="utf-8").write(result)
        return

    # --- all other methods go through MCP filesystem server ---
    proc = subprocess.Popen(
        SERVER_CMD,
        cwd=SERVER_CWD,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL
    )

    try:
        # 1. initialize handshake
        send(proc, {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {
                    "name": "tse-mcp-client",
                    "version": "0.1"
                }
            }
        })
        recv(proc)  # consume initialize response

        # 2. initialized notification
        send(proc, {
            "jsonrpc": "2.0",
            "method": "notifications/initialized",
            "params": {}
        })

        # 3. dispatch on method
        if method == "tools/list":
            send(proc, {
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/list",
                "params": {}
            })

        elif method == "tools/call":
            arguments = req.get("arguments", {})

            # Large content via temp file - bypasses SAL 255-char limit
            if "content_file" in arguments:
                content_path = arguments.pop("content_file")
                arguments["content"] = open(
                    content_path, encoding="utf-8"
                ).read()

            send(proc, {
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/call",
                "params": {
                    "name": req["tool"],
                    "arguments": arguments
                }
            })

        else:
            open(RESP_FILE, "w", encoding="utf-8").write(
                "ERROR: unknown method: " + method
            )
            return

        # 4. read response and write to resp file
        resp = recv(proc)
        result = resp.get("result", resp.get("error", resp))
        write_resp(result)

    finally:
        proc.terminate()

if __name__ == "__main__":
    main()
