import sys
import unittest
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from verify_resource_node_validator import verify


def _rom_argument():
    configured = os.environ.get("UBJ_ORIGINAL_ROM")
    if configured and Path(configured).is_file():
        return Path(configured)
    for value in sys.argv[1:]:
        path = Path(value)
        if path.is_file():
            return path
    return None


class ResourceNodeValidatorRomTests(unittest.TestCase):
    def test_original_rom_bytes_match_listing_and_call_contract(self):
        rom_path = _rom_argument()
        if rom_path is None:
            self.skipTest("pass the locally supplied original ROM path")
        report = verify(rom_path.read_bytes())
        self.assertEqual(report["entry"], 0x080604F8)
        self.assertEqual(report["instruction_halfwords"], 32)
        self.assertEqual(report["diagnostic_pointers"],
                         (0x0875591C, 0x08755938, 0x08755954))
        self.assertEqual(report["call_targets"], (0x08057C5C,) * 3)


if __name__ == "__main__":
    rom_path = _rom_argument()
    if rom_path is None:
        raise SystemExit("pass the locally supplied original ROM path")
    os.environ["UBJ_ORIGINAL_ROM"] = str(rom_path)
    sys.argv = [sys.argv[0]]
    unittest.main()
