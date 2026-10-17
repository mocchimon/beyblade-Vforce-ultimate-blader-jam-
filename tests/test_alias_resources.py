import sys
import unittest
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from verify_alias_resources import verify
from verify_resource_manifest import read_manifest


def _rom_argument():
    for value in sys.argv[1:]:
        path = Path(value)
        if path.is_file():
            return path
    return None


def _check_alias_resources(rom_path):
    manifest = read_manifest(
        Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
    original = rom_path.read_bytes()
    assert verify(original, manifest)
    for addr in (0x0807DCA4, 0x080BE234):
        damaged = bytearray(original)
        damaged[addr - 0x08000000 + 4] ^= 1
        try:
            verify(damaged, manifest)
        except ValueError:
            pass
        else:
            raise AssertionError(f'failed to reject damaged header at {addr:#x}')


class AliasResourceRomTests(unittest.TestCase):
    def test_alias_metadata_and_corrupted_headers(self):
        rom_path = _rom_argument()
        if rom_path is None:
            self.skipTest('pass the locally supplied original ROM path')
        _check_alias_resources(rom_path)


if __name__ == '__main__':
    rom_path = _rom_argument()
    if rom_path is None:
        raise SystemExit('pass the locally supplied original ROM path')
    _check_alias_resources(rom_path)
    print('PASS: alias metadata and corrupted-header detection')
