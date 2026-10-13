import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from verify_alias_resources import verify
from verify_resource_manifest import read_manifest

rom_path = Path(sys.argv[1])
manifest = read_manifest(Path(__file__).resolve().parents[1] / 'data/resource_blob_manifest.inc')
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
print('PASS: alias metadata and corrupted-header detection')
