import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from check_upstream_rom import identify

def test():
    assert identify('cd527c8c24e20e33913fc45199e64b3e6138a6e5') == 'us'
    assert identify('6d20a586e7bb52b4a9352bbeaec9d7be65e93369') == 'eu'
    assert identify('9210a12ce01fefbf7994af2a8d51351ed82d7253') == 'debug'
    assert identify('8d2cdd3ece0ab7d2f982b0a83e3ecb878f514a72') is None
    print('Upstream ROM fingerprint tests passed')
if __name__ == '__main__':
    test()
