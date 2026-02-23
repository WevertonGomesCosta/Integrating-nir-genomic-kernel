#!/usr/bin/env python3
"""Automated data sanity checks for tutorial datasets."""

from __future__ import annotations
import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NIR_PATH = ROOT / "data" / "NIR.csv"
GENO_PATH = ROOT / "data" / "GAPIT.Genotype.Numerical.txt"
OUT_PATH = ROOT / "output" / "data_sanity_report.json"


def read_header(path: Path, delimiter: str = ","):
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle, delimiter=delimiter)
        return next(reader)


def count_rows(path: Path, delimiter: str = ",") -> int:
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.reader(handle, delimiter=delimiter)
        next(reader)
        return sum(1 for _ in reader)


def collect_column_values(path: Path, column_name: str, delimiter: str = ","):
    values = []
    with path.open("r", encoding="utf-8", newline="") as handle:
        reader = csv.DictReader(handle, delimiter=delimiter)
        for row in reader:
            values.append(row.get(column_name))
    return values


def main() -> int:
    nir_header = read_header(NIR_PATH, ",")
    geno_header = read_header(GENO_PATH, "\t")

    nir_ids = collect_column_values(NIR_PATH, "Pedigree", ",")
    geno_ids = collect_column_values(GENO_PATH, "taxa", "\t")

    nir_env = collect_column_values(NIR_PATH, "Env", ",")

    nir_unique_ids = {x for x in nir_ids if x}
    geno_unique_ids = {x for x in geno_ids if x}
    common_ids = nir_unique_ids & geno_unique_ids

    report = {
        "files": {
            "NIR": str(NIR_PATH.relative_to(ROOT)),
            "Genotype": str(GENO_PATH.relative_to(ROOT)),
        },
        "counts": {
            "nir_rows": count_rows(NIR_PATH, ","),
            "geno_rows": count_rows(GENO_PATH, "\t"),
            "nir_columns": len(nir_header),
            "geno_columns": len(geno_header),
            "nir_unique_pedigree": len(nir_unique_ids),
            "geno_unique_taxa": len(geno_unique_ids),
            "shared_ids": len(common_ids),
        },
        "checks": {
            "nir_required_columns": all(col in nir_header for col in ["Pedigree", "Env", "GY", "KW"]),
            "geno_required_columns": "taxa" in geno_header,
            "nir_missing_pedigree": any(v in (None, "") for v in nir_ids),
            "geno_missing_taxa": any(v in (None, "") for v in geno_ids),
            "nir_has_known_environments": set(e for e in nir_env if e) >= {"CS11_WS", "CS11_WW", "CS12_WS", "CS12_WW"},
            "has_shared_ids": len(common_ids) > 0,
        },
    }

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(json.dumps(report, indent=2), encoding="utf-8")

    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
