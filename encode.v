module vgob

import math.bits

pub fn encode<T>(data T) ?[]byte {
	mut res := encode_no_len<T>(data) ?
	len := encode_uint(u64(res.len)) ?
	res.prepend(len)
	return res
}

fn encode_no_len<T>(data T) ?[]byte {
	mut result := []byte{}
	$if T is i8 {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is i16 {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is int {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is i64 {
		result << encode_type(.int) ?
		result << encode_int(data) ?
	} $else $if T is byte {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else $if T is u16 {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else $if T is u32 {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else $if T is u64 {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else $if T is u64 {
		result << encode_type(.uint) ?
		result << encode_uint(data) ?
	} $else $if T is f32 {
		result << encode_type(.float) ?
		resudlt << encode_float(data) ?
	} $else $if T is f64 {
		result << encode_type(.float) ?
		result << encode_float(data) ?
	} $else $if T is string {
		result << encode_type(.string) ?
		result << encode_string(data) ?
	} $else {
		return error('unknown type')
	}
	// $for field in T.fields {
	// 	$if field.typ is string {
	// 		// $(string_expr) produces an identifier
	// 		// result.$(field.name) = encode_string(data, field.name)
	// 	} $else $if field.typ is int {
	// 		result << encode_int(data) ?
	// 	}
	// }
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
	if x < 128 {
		return [byte(x)]
	} else if x < 65536 {
		return [~byte(1), byte(x >> 8), byte(x)]
	} else if x < 4294967296 {
		return [~byte(3), byte(x >> 24), byte(x >> 16), byte(x >> 8), byte(x)]
	} else if x <= 18446744073709551615 {
		return [~byte(7), byte(x >> 56), byte(x >> 48), byte(x >> 40), byte(x >> 32), byte(x >> 24),
			byte(x >> 16), byte(x >> 8), byte(x)]
	} else {
		return error('too big: $x, ${x < 18446744073709551616}')
	}
}

fn encode_float(x f64) ?[]byte {
	return encode_uint(bits.reverse_bytes_64(unsafe { FToU{ f: x }.u }))
}

// and back again
union FToU {
	f f64
	u u64
}

fn encode_string(x string) ?[]byte {
	mut res := encode_uint(u64(x.len)) ?
	for c in x {
		res << c
	}
	return res
}
