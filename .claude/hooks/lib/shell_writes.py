"""shell_writes.py — files a shell command writes with >, >>, tee or sed -i.

Usage:
  python3 shell_writes.py COMMAND ROOT

Prints one absolute path per line, only for paths inside ROOT. The command is
tokenized, not grepped, so a ">" inside quotes or a heredoc body is not a write.
Paths built from other variables can't be resolved and are left out. So is
anything that writes without these four: cp, mv, python, a script.
"""

import os
import re
import sys

SED_IN_PLACE = re.compile(r"^(?:-[A-Za-z]*i|--in-place)")
ASSIGNMENT = re.compile(r"^\w+=")


def parse(cmd):
    """Return (redirect targets, simple commands as word lists)."""
    writes, commands, words, heredocs = [], [], [], []
    word, pending = None, None  # pending: what the next word is, if not an argument
    i, n = 0, len(cmd)

    def flush():
        nonlocal word, pending
        if word is None:
            return
        if pending == "write":
            writes.append(word)
        elif pending == "delim":
            heredocs.append(word)
        elif pending != "skip":
            words.append(word)
        word, pending = None, None

    def end_command():
        nonlocal words
        flush()
        if words:
            commands.append(words)
        words = []

    while i < n:
        c = cmd[i]
        if c == "\\":
            if cmd[i + 1 : i + 2] != "\n":
                word = (word or "") + cmd[i + 1 : i + 2]
            i += 2
        elif c == "'":
            end = cmd.find("'", i + 1)
            end = n if end < 0 else end
            word = (word or "") + cmd[i + 1 : end]
            i = end + 1
        elif c == '"':
            word = word or ""
            i += 1
            while i < n and cmd[i] != '"':
                if cmd[i] == "\\" and i + 1 < n:
                    i += 1
                word += cmd[i]
                i += 1
            i += 1
        elif c == "\n":
            end_command()
            i += 1
            for delim in heredocs:  # skip each heredoc body
                while i < n:
                    end = cmd.find("\n", i)
                    end = n if end < 0 else end
                    line = cmd[i:end]
                    i = end + 1
                    if line.strip() == delim:
                        break
            heredocs = []
        elif c in " \t\r":
            flush()
            i += 1
        elif c == "#" and word is None:
            end = cmd.find("\n", i)
            i = n if end < 0 else end
        elif c == "<":
            flush()
            if cmd.startswith("<<<", i):
                pending, i = "skip", i + 3
            elif cmd.startswith("<<", i):
                pending, i = "delim", i + 2
                if cmd[i : i + 1] == "-":
                    i += 1
            else:
                pending, i = "skip", i + 1
        elif c == ">" or cmd.startswith("&>", i):
            fd = word if word is not None and word.isdigit() else None
            if fd is not None:
                word = None  # "2>" is an operator, not an argument
            flush()
            i += 1 if c == ">" else 2
            if cmd[i : i + 1] in (">", "|"):
                i += 1
            if re.match(r"&(?:\d|-)", cmd[i : i + 2]):  # 2>&1 duplicates a stream
                i += 2
                continue
            if cmd[i : i + 1] == "&":
                i += 1
            pending = "skip" if fd not in (None, "1") else "write"
        elif c in ";&|()":
            end_command()
            i += 1
        else:
            word = (word or "") + c
            i += 1
    end_command()
    return writes, commands


def command_writes(words):
    """Files a tee or sed -i command writes."""
    while words and (ASSIGNMENT.match(words[0]) or words[0] == "sudo"):
        words = words[1:]
    if not words:
        return []
    name, args = os.path.basename(words[0]), words[1:]
    if name == "sed" and not any(SED_IN_PLACE.match(a) for a in args):
        return []
    if name not in ("tee", "sed"):
        return []
    return [a for a in args if a and not a.startswith("-")]


def resolve(path, root):
    """Absolute path inside root, or None."""
    home = os.path.expanduser("~")
    path = re.sub(r"^~(?=/|$)", lambda _: home, path)
    for name, value in (("HOME", home), ("PWD", root), ("CLAUDE_PROJECT_DIR", root)):
        path = re.sub(r"\$(?:\{%s\}|%s\b)" % (name, name), lambda _: value, path)
    if "$" in path:
        return None
    path = os.path.normpath(os.path.join(root, path))
    return path if path.startswith(root.rstrip("/") + "/") else None


def main():
    if len(sys.argv) < 3:
        return
    command, root = sys.argv[1], sys.argv[2]
    writes, commands = parse(command)
    for words in commands:
        writes += command_writes(words)
    for path in writes:
        resolved = resolve(path, root)
        if resolved:
            print(resolved)


if __name__ == "__main__":
    try:
        main()
    except Exception:  # never break a command on a parser bug
        pass
