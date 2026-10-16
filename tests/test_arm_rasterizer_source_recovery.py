import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class ArmRasterizerSourceRecoveryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = (ROOT / "src" / "arm_rasterizer_tables.c").read_text()
        cls.raster_source = (ROOT / "src" / "arm_rasterizer.c").read_text()
        cls.header = (ROOT / "include" / "arm_rasterizer.h").read_text()
        cls.makefile = (ROOT / "Makefile").read_text()
        cls.disassembly = (
            ROOT / "asm" / "runtime" / "arm_rasterizer_641b8_64edc.dis.txt"
        ).read_text().lower()

    def test_primitive_edge_entry_is_defined_in_arm_unit(self):
        self.assertIn("int ArmRaster_ProcessPrimitiveEdges(", self.source)
        self.assertNotIn("extern int ArmRaster_ProcessPrimitiveEdges", self.source)
        arm_state = next(
            line for line in self.makefile.splitlines()
            if line.startswith("ARM_STATE_SOURCES :=")
        )
        self.assertIn("src/arm_rasterizer_tables.c", arm_state)
        self.assertIn("src/arm_rasterizer.c", arm_state)

    def test_bucket_walker_uses_primitive_and_coordinate_bases(self):
        self.assertIn("vertex_bytes + 0x08", self.source)
        self.assertIn("vertex_bytes + 0x10", self.source)
        self.assertIn("primitive_records + (uint32_t)primitive_index * 8u", self.source)
        self.assertIn(
            "ArmRaster_ProcessPrimitiveEdges(output, coordinate_records,",
            self.source,
        )
        self.assertIn("ArmRaster_DrawRows(output, draw_list)", self.source)
        self.assertIn("void ArmRaster_DrawRows(", self.raster_source)
        self.assertIn("void ArmRaster_DrawRows(", self.header)
        self.assertIn("void ArmRaster_ApplyVertexParameters(", self.raster_source)
        self.assertIn("void ArmRaster_ApplyVertexParameters(", self.header)
        self.assertIn("void ArmRaster_TransformVertexRows(", self.raster_source)
        self.assertIn("void ArmRaster_TransformVertexRows(", self.header)

    def test_row_drawing_entry_and_sample_helpers_are_defined(self):
        self.assertIn("ArmRaster_EmitSamples", self.raster_source)
        self.assertIn("ArmRaster_EmitPackedSamples", self.raster_source)
        self.assertIn("row_base_offset += 64u", self.raster_source)
        self.assertIn("ARMRASTER_RECIPROCAL_TABLE_ADDRESS 0x0874D1E4u",
                      self.raster_source)
        self.assertIn("ARMRASTER_PARAMETER_TABLE_ADDRESS  0x0874CC60u",
                      self.raster_source)
        self.assertIn("ArmRaster_SignedBits(sample) > 255", self.raster_source)
        self.assertIn("8064af8: 0874cc60", self.disassembly)

    def test_vertex_row_transform_preserves_arm_matrix_and_record_steps(self):
        self.assertIn("input_records += 10u", self.raster_source)
        self.assertIn("vertex_values += 6u", self.raster_source)
        self.assertIn("output_records += 16u", self.raster_source)
        self.assertIn("ArmRaster_Add32(matrix_x", self.raster_source)
        self.assertIn("ArmRaster_Add32(matrix_y", self.raster_source)
        self.assertIn("ArmRaster_Add32(matrix_z", self.raster_source)
        self.assertIn("8064afc:", self.disassembly)
        self.assertIn("8064b94:", self.disassembly)
        self.assertIn("8064c24:", self.disassembly)

    def test_reciprocal_table_and_branch_targets_are_documented_in_source(self):
        self.assertIn("ARMRASTER_RECIPROCAL_TABLE_ADDRESS 0x0874D1E4u", self.source)
        self.assertIn("ArmRaster_ProcessRepeatedIndex", self.source)
        self.assertIn("row_count == upper_row_count", self.source)
        self.assertIn("8064364:", self.disassembly)
        self.assertIn("8064724:", self.disassembly)
        self.assertIn("80645ec:", self.disassembly)


if __name__ == "__main__":
    unittest.main()
