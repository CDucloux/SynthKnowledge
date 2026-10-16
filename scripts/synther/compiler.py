"""Compilation Typst (CLI `typst` si présente, sinon paquet Python `typst`) et contrôle du PDF."""
import os
import re
import shutil
import subprocess


def compile_typst(source, output, inputs=None):
    inputs = inputs or {}
    os.makedirs(os.path.dirname(output), exist_ok=True)
    if shutil.which("typst"):
        flags = [arg for k, v in inputs.items() for arg in ("--input", f"{k}={v}")]
        subprocess.run(["typst", "compile", "--root", ".", "--font-path", "fonts", *flags, source, output], check=True)
    else:
        import typst
        typst.compile(source, output=output, root=".", font_paths=["fonts"], sys_inputs=inputs)


def compile_sheet(sheet):
    compile_typst("template/sheet.typ", sheet.pdf_path, {"son": "/" + sheet.source})


def page_count(pdf_path):
    if shutil.which("pdfinfo"):
        out = subprocess.run(["pdfinfo", pdf_path], capture_output=True, text=True).stdout
        if m := re.search(r"^Pages:\s+(\d+)", out, re.M):
            return int(m.group(1))
    with open(pdf_path, "rb") as f:
        return len(re.findall(rb"/Type\s*/Page[^s]", f.read()))
