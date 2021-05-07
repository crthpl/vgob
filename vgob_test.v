module vgob

fn test_numeric() ? {
	test_ints := [i64(6), -6, 12345, 4123809423347243, -4123809342789243]
	test_uints := [u64(6), 12345, 4128789243, 4123809789243]
	test_floats := [f64(17), 4, 3.7, 8923147203.41328472314,
		143289041237890.432189078912403897412317980,
		3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000.0,
	]
	for test_uint in test_uints {
		bytes := encode(test_uint) ?
		println(bytes)
		decod := decode<u64>(bytes) ?
		assert test_uint == decod
	}
	for test_int in test_ints {
		bytes := encode(test_int) ?
		decod := decode<i64>(bytes) ?
		assert test_int == decod
	}
	for test_float in test_floats {
		bytes := encode(test_float) ?
		println(bytes.map(int(it)))
		decod := decode<f64>(bytes) ?

		assert test_float == decod
	}
}

// also tests maps
fn test_array() ? {
	test_strings := ['abc', '803921 0', '💩📙📙', 'èúabc']

	for test_string in test_strings {
		bytes := encode(test_string) ?
		decod := decode<string>(bytes) ?
		assert test_string == decod
	}
}
