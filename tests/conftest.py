"""Les modules de synther travaillent depuis la racine du dépôt."""

import copy
from collections.abc import Callable, Iterator
from pathlib import Path
from typing import Any

import pytest
import yaml

from synther import ROOT
from synther.yamlfile import read_yaml

# Fiche de référence, valide, que les tests modifient.
THRILLER = Path("sounds/messenger/thriller-bass.yaml")


@pytest.fixture(autouse=True)
def at_root(monkeypatch: pytest.MonkeyPatch) -> None:
    monkeypatch.chdir(ROOT)


@pytest.fixture
def thriller() -> Iterator[dict[str, Any]]:
    """Données de la fiche Thriller (copie modifiable)."""
    yield copy.deepcopy(read_yaml(ROOT / THRILLER)[1])


WriteSheet = Callable[..., Path]


@pytest.fixture
def write_sheet(tmp_path: Path) -> WriteSheet:
    """Écrit une fiche dans <tmp>/<dossier>/fiche.yaml, renvoie son chemin."""

    def write(data: Any, folder: str = "messenger", raw: str = "") -> Path:
        path = tmp_path / folder / "fiche.yaml"
        path.parent.mkdir(exist_ok=True)
        text = raw or yaml.safe_dump(data, allow_unicode=True)
        path.write_text(text, encoding="utf-8")
        return path

    return write
