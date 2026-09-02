from __future__ import annotations

import argparse
import os
import tempfile
import zipfile
from pathlib import Path
from xml.etree import ElementTree as ET


W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
W = f"{{{W_NS}}}"
ET.register_namespace("w", W_NS)
ET.register_namespace("r", R_NS)


def patch_document_xml(data: bytes) -> bytes:
    root = ET.fromstring(data)
    for sect_pr in root.findall(f".//{W}sectPr"):
        cols = sect_pr.find(f"{W}cols")
        if cols is None:
            cols = ET.SubElement(sect_pr, f"{W}cols")
        cols.set(f"{W}num", "2")
        cols.set(f"{W}space", "300")
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def build(source: Path, output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(suffix=".docx", dir=output.parent)
    os.close(fd)
    temp_path = Path(temp_name)
    try:
        with zipfile.ZipFile(source, "r") as src, zipfile.ZipFile(
            temp_path, "w"
        ) as dst:
            for info in src.infolist():
                data = src.read(info.filename)
                if info.filename == "word/document.xml":
                    data = patch_document_xml(data)
                dst.writestr(info, data)
        os.replace(temp_path, output)
    finally:
        temp_path.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    build(args.source.resolve(), args.output.resolve())


if __name__ == "__main__":
    main()
