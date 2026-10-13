# Resource directory alias records

ROM directory at `0x08075640` has 32 slots, each containing a pointer-table start/end pair.

* Bank 6 has **two** pointers, at `0x08214664` (size `0x6480`) and `0x0821AAF4` (size `0x57`). The second record was missing from the manifest; it has the same `(0, size, 0, 0)` header and occupies `0x68` bytes including alignment.
* Odd banks 7–31 (13 slots) share the pointer table `0x08074DCC–0x08074DD0`, containing one pointer to `0x0807DCA4` (data size `0x40580`).
* Even banks 8–30 (12 slots) share the pointer table `0x08074DD4–0x08074DD8`, containing one pointer to `0x080BE234` (data size `0x4D780`).
* Both large targets use the same 16-byte record header `(0, size, 0, 0)` as the smaller manifest records. These are **two unique records**, not 25 independent copies.

This confirms record framing and aliasing, **not** the data's graphic/audio meaning. The alias targets reside earlier in ROM than the bank-0 resources. No payload bytes are included in this project.

`python3 tools/verify_alias_resources.py <original-rom>` checks all 25 alias slots, their exact pointers, their headers, and all listed manifest entries. `tests/test_alias_resources.py` additionally tests corrupted-header rejection.
