"""Fiche son validée : accès typé aux données, nommage du PDF."""

from dataclasses import dataclass

from . import MACHINES
from .models import Reference, SheetModel


@dataclass(frozen=True)
class Sheet:
    """Une fiche de sounds/<machine>/<son>.yaml, déjà validée."""

    source: str
    model: SheetModel

    @property
    def machine(self) -> str:
        return self.model.synth

    @property
    def machine_name(self) -> str:
        return MACHINES[self.machine]

    @property
    def reference(self) -> Reference:
        return self.model.reference

    @property
    def role(self) -> str:
        """Rôle = titre moins le morceau (« Closer Bass » → « Bass »)."""
        song, title = self.reference.song, self.model.title
        if title.startswith(song):
            return title[len(song) :].strip()
        return ""

    @property
    def pdf_path(self) -> str:
        """« sheets/<machine>/[Artiste] Morceau (Rôle).pdf »"""
        name = f"[{self.reference.artist}] {self.reference.song}"
        if self.role:
            name += f" ({self.role})"
        return f"sheets/{self.machine}/{name.replace('/', '-')}.pdf"
