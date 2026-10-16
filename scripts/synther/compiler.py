"""Compilation Typst et contrôle du PDF.

CLI `typst` si elle est installée, sinon paquet Python `typst`.
"""

import os
import re
import shutil
import subprocess

from .sheet import Sheet


def compile_typst(
    source: str, output: str, inputs: dict[str, str] | None = None
) -> None:
    inputs = inputs or {}
    os.makedirs(os.path.dirname(output), exist_ok=True)
    if shutil.which("typst"):
        flags = [
            arg for k, v in inputs.items() for arg in ("--input", f"{k}={v}")
        ]
        command = [
            "typst",
            "compile",
            "--root",
            ".",
            "--font-path",
            "fonts",
            *flags,
            source,
            output,
        ]
        subprocess.run(command, check=True)
    else:
        import typst

        typst.compile(
            source,
            output=output,
            root=".",
            font_paths=["fonts"],
            sys_inputs=inputs,
        )


def compile_sheet(sheet: Sheet) -> None:
    compile_typst(
        "template/sheet.typ", sheet.pdf_path, {"son": "/" + sheet.source}
    )


def page_count(pdf_path: str) -> int:
    if shutil.which("pdfinfo"):
        out = subprocess.run(
            ["pdfinfo", pdf_path], capture_output=True, text=True
        ).stdout
        if m := re.search(r"^Pages:\s+(\d+)", out, re.M):
            return int(m.group(1))
    with open(pdf_path, "rb") as f:
        return len(re.findall(rb"/Type\s*/Page[^s]", f.read()))
