module vgob

fn test_basic_encode() ? {
	test_ints := [i64(6), -6, 12345, 4123809423347243, -4123809342789243]
	test_uints := [u64(6), 256, 4123809423789243, 4123809423789243]
	for test_uint in test_uints {
		bytes := encode(test_uint) ?
		decod := decode<u64>(bytes) ?
		assert test_uint == decod
	}
	for test_int in test_ints {
		bytes := encode(test_int) ?
		decod := decode<i64>(bytes) ?
		assert test_int == decod
	}
}
