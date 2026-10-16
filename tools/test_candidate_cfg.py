import struct
import unittest
from trace_candidate_cfg import trace
from trace_directory_runtime import BASE


class TestCFG(unittest.TestCase):
    def test_thumb_unconditional_branch(self):
        rom = bytearray(16)
        struct.pack_into('<H', rom, 0, 0xe001)  # target +6
        struct.pack_into('<H', rom, 6, 0x4770)  # BX LR
        result = trace(rom, BASE, 'Thumb')
        self.assertEqual(result['visited'], [f'{BASE:#010x}', f'{BASE+6:#010x}'])
        self.assertEqual(result['stops'][0]['reason'], 'indirect_bx_or_blx')

    def test_thumb_conditional_fork(self):
        rom = bytearray(12)
        struct.pack_into('<H', rom, 0, 0xd001)
        struct.pack_into('<H', rom, 2, 0x4770)
        struct.pack_into('<H', rom, 6, 0x4770)
        self.assertEqual(trace(rom, BASE, 'Thumb')['visited_count'], 3)

    def test_arm_unconditional_branch(self):
        rom = bytearray(20)
        struct.pack_into('<I', rom, 0, 0xea000000)  # ARM B to +8
        struct.pack_into('<I', rom, 8, 0xe12fff1e)  # BX LR
        self.assertEqual(trace(rom, BASE, 'ARM')['visited_count'], 2)

    def test_arm_bl_no_callee_follow(self):
        rom = bytearray(20)
        struct.pack_into('<I', rom, 0, 0xeb000000)
        struct.pack_into('<I', rom, 4, 0xe12fff1e)
        self.assertEqual(trace(rom, BASE, 'ARM')['visited_count'], 2)

    def test_thumb_bl_pair_forward(self):
        rom = bytearray(32)
        struct.pack_into('<HHH', rom, 0, 0xf000, 0xf802, 0x4770)
        result = trace(rom, BASE, 'Thumb')
        self.assertEqual(result['visited_count'], 2)
        self.assertIn({'from': f'{BASE:#010x}', 'to': f'{BASE+8:#010x}', 'kind': 'call'}, result['edges'])

    def test_thumb_bl_pair_backward(self):
        rom = bytearray(32)
        struct.pack_into('<HHH', rom, 8, 0xf7ff, 0xfffa, 0x4770)
        result = trace(rom, BASE+8, 'Thumb')
        self.assertIn({'from': f'{BASE+8:#010x}', 'to': f'{BASE:#010x}', 'kind': 'call'}, result['edges'])

    def test_invalid_thumb_bl_pair(self):
        rom = bytearray(8)
        struct.pack_into('<H', rom, 0, 0xf000)
        self.assertEqual(trace(rom, BASE, 'Thumb')['stops'][0]['reason'], 'invalid_thumb_bl_pair')

    def test_arm_mov_pc_lr_return(self):
        rom = struct.pack('<II', 0xe1a0f00e, 0)
        self.assertEqual(trace(rom, BASE, 'ARM')['visited_count'], 1)

    def test_arm_pop_pc_return(self):
        rom = struct.pack('<II', 0xe8bd8010, 0)
        self.assertEqual(trace(rom, BASE, 'ARM')['visited_count'], 1)

    def test_thumb_swi_stop(self):
        rom = struct.pack('<HH', 0xdf00, 0)
        self.assertEqual(trace(rom, BASE, 'Thumb')['stops'][0]['reason'], 'software_interrupt')

    def test_conditional_arm_return_keeps_fallthrough(self):
        rom = struct.pack('<III', 0x01a0f00e, 0xe12fff1e, 0)
        result = trace(rom, BASE, 'ARM')
        self.assertEqual(result['visited_count'], 2)
        self.assertIn('conditional_return_fallthrough', [e['kind'] for e in result['edges']])

    def test_conditional_arm_bx_keeps_fallthrough(self):
        rom = struct.pack('<II', 0x012fff1e, 0xe12fff1e)
        self.assertEqual(trace(rom, BASE, 'ARM')['visited_count'], 2)

    def test_arm_ldr_pc_stops(self):
        rom = struct.pack('<II', 0xe59ff000, 0)
        result = trace(rom, BASE, 'ARM')
        self.assertEqual(result['visited_count'], 1)
        self.assertEqual(result['stops'][0]['reason'], 'indirect_ldr_pc')

    def test_arm_swi_stops(self):
        rom = struct.pack('<II', 0xef000000, 0)
        self.assertEqual(trace(rom, BASE, 'ARM')['stops'][0]['reason'], 'software_interrupt')

    def test_thumb_mov_pc_stops(self):
        rom = struct.pack('<HH', 0x4687, 0)
        self.assertEqual(trace(rom, BASE, 'Thumb')['stops'][0]['reason'], 'indirect_mov_pc')

    def test_conditional_arm_swi_preserves_fallthrough(self):
        rom = struct.pack('<II', 0x0f000000, 0xe12fff1e)
        result = trace(rom, BASE, 'ARM')
        self.assertEqual(result['visited_count'], 2)
        self.assertIn('conditional_swi_fallthrough', [e['kind'] for e in result['edges']])

    def test_arm_blx_register_is_indirect(self):
        rom = struct.pack('<II', 0xe12fff30, 0xe12fff1e)
        result = trace(rom, BASE, 'ARM')
        self.assertEqual(result['visited_count'], 2)
        self.assertEqual(result['stops'][0]['reason'], 'indirect_bx_or_blx')

    def test_thumb_blx_register_is_indirect(self):
        rom = struct.pack('<HH', 0x4780, 0x4770)
        result = trace(rom, BASE, 'Thumb')
        self.assertEqual(result['visited_count'], 2)
        self.assertEqual(result['stops'][0]['reason'], 'indirect_bx_or_blx')

    def test_invalid_seed(self):
        with self.assertRaises(ValueError):
            trace(bytes(4), BASE + 1, 'ARM')

    def test_bounded(self):
        result = trace(bytes(128), BASE, 'Thumb', max_instructions=3)
        self.assertTrue(result['truncated'])
        self.assertEqual(result['visited_count'], 3)


if __name__ == '__main__':
    unittest.main()
