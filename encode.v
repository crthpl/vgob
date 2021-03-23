module vgob

pub fn encode<T>(data T) ?[]byte {
	mut result := []byte{}
	// compile-time `for` loop
	// T.fields gives an array of a field metadata type

	// $for field in T.fields {
	// 	$if field.typ is string {
	// 		// $(string_expr) produces an identifier
	// 		// result.$(field.name) = encode_string(data, field.name)
	// 	} $else $if field.typ is int {
	// 		result << encode_int(data) ?
	// 	}
	// }
	$if T is int {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is i64 {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is u64 {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else {
		return error('unknown type')
	}
	len := encode_uint(u64(result.len)) ?
	result.prepend(len)
	return result
}

enum Type {
	bool = 1
	int = 2
	uint = 3
	float = 4
	byte_arr = 5 // []byte
	string = 6
	complex = 7
	@interface = 8
	// gap for reserved ids.
	wire_type = 16
	array_type = 17
	common_type = 18
	slice_type = 19
	struct_type = 20
	field_type = 21
	// 22 is slice of fieldType.
	map_type = 23
}

fn encode_type(t Type) ?[]byte {
	mut typ := encode_int(int(t)) ?
	typ << 0
	return typ
}

fn encode_int(x i64) ?[]byte {
	return encode_uint(if x < 0 { ((~u64(x)) << 1) | 1 } else { (u64(x) << 1) })
}

fn encode_uint(x u64) ?[]byte {
	return if x < 128 {
		[byte(x)]
	} else if x < 32768 {
		[~byte(1), byte(x >> 8), byte(x)]
	} else if x < 2147483648 {
		[~byte(3), byte(x >> 24), byte(x >> 16), byte(x >> 8), byte(x)]
	} else {
		error('too big (TODO): $x')
	}
}
