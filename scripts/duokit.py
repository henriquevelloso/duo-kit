#!/usr/bin/env python3
"""Maintenance checks for duo-kit. Python 3.9+, standard library only.

  python3 scripts/duokit.py sync      copy shared/not-an-ipad.md into every SKILL.md
  python3 scripts/duokit.py lint      structure, banned words, card freshness
  python3 scripts/duokit.py snippets  type-check every ```swift block in skills/
"""
import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"
CARD = ROOT / "shared" / "not-an-ipad.md"
START, END = "<!-- duo-kit:card:start -->", "<!-- duo-kit:card:end -->"
# Skills must stay self-contained and harness-neutral.
BANNED = [r"\baxiom\b", r"\bcupertino\b", r"mcp__", r"\bapp-resizability\b"]
MAX_SKILL_LINES = 220
TARGET = "arm64-apple-ios27.1-simulator"
# Code that ships in a reference file and is also built and run as a fixture.
FIXTURE_COPIES = {
    "fixtures/DuoBookSample/BookSpread.swift": "skills/duo-book-layout/references/book-spread.md",
}


def skill_files():
    return sorted(SKILLS.glob("*/SKILL.md"))


def card_block():
    return f"{START}\n{CARD.read_text(encoding='utf-8').rstrip()}\n{END}"


def sync():
    changed = []
    pattern = re.compile(re.escape(START) + r".*?" + re.escape(END), re.S)
    for path in skill_files():
        text = path.read_text(encoding="utf-8")
        if not pattern.search(text):
            print(f"no card markers: {path.relative_to(ROOT)}")
            return 1
        new = pattern.sub(lambda _: card_block(), text)
        if new != text:
            path.write_text(new, encoding="utf-8")
            changed.append(path.parent.name)
    print("card synced:", ", ".join(changed) if changed else "already up to date")
    return 0


def lint():
    problems = []
    files = skill_files()
    if not files:
        problems.append("no skills found")
    for path in files:
        rel = path.relative_to(ROOT)
        folder = path.parent.name
        text = path.read_text(encoding="utf-8")
        front = re.match(r"^---\n(.*?)\n---\n", text, re.S)
        if not front:
            problems.append(f"{rel}: no frontmatter")
            continue
        name = re.search(r"^name:\s*(\S+)\s*$", front.group(1), re.M)
        if not name or name.group(1) != folder:
            problems.append(f"{rel}: frontmatter name must equal the folder name")
        if not folder.startswith("duo-"):
            problems.append(f"{rel}: skill names start with duo-")
        description = re.search(r"^description:\s*(.+)$", front.group(1), re.M)
        if not description or "iPhone Duo" not in description.group(1):
            problems.append(f"{rel}: description must mention iPhone Duo")
        if card_block() not in text:
            problems.append(f"{rel}: card missing or stale (run sync)")
        if len(text.splitlines()) > MAX_SKILL_LINES:
            problems.append(f"{rel}: over {MAX_SKILL_LINES} lines; move detail to references/")
        if not (path.parent / "agents" / "openai.yaml").is_file():
            problems.append(f"{rel}: missing agents/openai.yaml")
        for link in re.findall(r"\]\((references/[^)#]+)", text):
            if not (path.parent / link).is_file():
                problems.append(f"{rel}: broken link {link}")
    for path in sorted(SKILLS.rglob("*")):
        if path.is_file() and path.suffix in {".md", ".yaml"}:
            text = path.read_text(encoding="utf-8")
            for word in BANNED:
                for match in re.finditer(word, text, re.I):
                    line = text.count("\n", 0, match.start()) + 1
                    problems.append(f"{path.relative_to(ROOT)}:{line}: banned term {match.group(0)!r}")
    for fixture, reference in FIXTURE_COPIES.items():
        if (ROOT / fixture).read_text(encoding="utf-8") not in (ROOT / reference).read_text(encoding="utf-8"):
            problems.append(f"{reference}: code differs from {fixture}")
    for problem in problems:
        print(problem)
    print(f"lint: {len(files)} skills, {len(problems)} problems")
    return 1 if problems else 0


def snippets():
    sdk = subprocess.run(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"],
                         capture_output=True, text=True, check=True).stdout.strip()
    version = subprocess.run(["xcodebuild", "-version"], capture_output=True, text=True).stdout.split("\n")
    print("checking against", " / ".join(v for v in version if v), "target", TARGET)
    failures = total = 0
    with tempfile.TemporaryDirectory() as tmp:
        for path in sorted(SKILLS.rglob("*.md")):
            blocks = re.findall(r"```swift\n(.*?)```", path.read_text(encoding="utf-8"), re.S)
            for index, block in enumerate(blocks, 1):
                if block.lstrip().startswith("// fragment"):
                    continue  # an excerpt that is not meant to compile on its own
                total += 1
                source = Path(tmp) / f"snippet_{total}.swift"
                source.write_text(block, encoding="utf-8")
                result = subprocess.run(
                    ["xcrun", "swiftc", "-typecheck", "-parse-as-library", "-sdk", sdk,
                     "-target", TARGET, str(source)], capture_output=True, text=True)
                label = f"{path.relative_to(ROOT)} block {index}"
                if result.returncode:
                    failures += 1
                    print(f"FAIL {label}\n{result.stderr.strip()[:1500]}")
                else:
                    print(f"ok   {label}")
    print(f"snippets: {total} checked, {failures} failed")
    return 1 if failures else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=["sync", "lint", "snippets"])
    return {"sync": sync, "lint": lint, "snippets": snippets}[parser.parse_args().command]()


if __name__ == "__main__":
    sys.exit(main())
