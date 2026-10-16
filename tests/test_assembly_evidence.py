import tempfile
import unittest
from pathlib import Path
from tools.audit_assembly_evidence import analyze

class AssemblyEvidenceTests(unittest.TestCase):
    def test_calls_and_memory(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'test.s'
            p.write_text('  49268: b570          push {r4, r5, r6, lr}\n  4926a: f000 f801     bl 0x49270 <rom>\n  4926e: 6001          str r1, [r0]\n  49270: 4770          bx lr\n')
            a=analyze(p)
            self.assertEqual(a['instructions'],4)
            self.assertEqual(a['internal_call_targets'],['0x49270'])
            self.assertTrue(a['has_return_pattern'])
            self.assertEqual(a['memory_write_instructions'],2)
    def test_empty(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'empty.s';p.write_text('hello')
            self.assertEqual(analyze(p)['instructions'],0)
if __name__=='__main__':unittest.main()
