"""Compilation Typst et contrôle du PDF.

CLI `typst` si elle est installée, sinon paquet Python `typst`.
"""

import re
import shutil
import subprocess
from pathlib import Path

from . import FONTS_DIR, SHEET_TEMPLATE
from .sheet import Sheet


class CompileError(Exception):
    """Échec de Typst ; le message est celui de Typst."""


def compile_typst(
    source: Path, output: Path, inputs: dict[str, str] | None = None
) -> None:
    """Compile `source` en `output`, racine Typst = dossier courant.

    `inputs` : valeurs lues dans le template par `sys.inputs`.
    Lève CompileError si Typst échoue.
    """
    inputs = inputs or {}
    output.parent.mkdir(parents=True, exist_ok=True)
    if shutil.which("typst"):
        input_flags = [
            flag
            for key, value in inputs.items()
            for flag in ("--input", f"{key}={value}")
        ]
        command = [
            "typst",
            "compile",
            "--root",
            ".",
            "--font-path",
            str(FONTS_DIR),
            *input_flags,
            str(source),
            str(output),
        ]
        # Messages de Typst affichés directement (stderr non capturé).
        if subprocess.run(command).returncode != 0:
            raise CompileError("typst a échoué (voir ci-dessus)")
        return

    import typst

    try:
        typst.compile(
            str(source),
            output=str(output),
            root=".",
            font_paths=[str(FONTS_DIR)],
            sys_inputs=inputs,
        )
    except typst.TypstError as error:
        raise CompileError(str(error)) from error


def compile_sheet(sheet: Sheet) -> None:
    # Chemin Typst absolu depuis la racine du projet : « /sounds/… ».
    son = "/" + sheet.source.as_posix()
    compile_typst(SHEET_TEMPLATE, sheet.pdf_path, {"son": son})


def page_count(pdf: Path) -> int:
    """Nombre de pages : pdfinfo si présent, sinon lecture du PDF brut."""
    if shutil.which("pdfinfo"):
        info = subprocess.run(
            ["pdfinfo", str(pdf)], capture_output=True, text=True
        ).stdout
        if match := re.search(r"^Pages:\s+(\d+)", info, re.MULTILINE):
            return int(match.group(1))
    return len(re.findall(rb"/Type\s*/Page[^s]", pdf.read_bytes()))
