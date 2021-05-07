module vgob

import math.bits

pub fn encode<T>(data T) ?[]byte {
	mut e := Encoder{}
	e.encode<T>(data) ?
	return e.final()
}

struct Encoder {
mut:
	types []byte
	data  []byte
}

fn (mut e Encoder) final() ?[]byte {
	data_end := e.data.len
	e.uint(u64(e.data.len)) ?
	mut res := []byte{cap: e.types.len + e.data.len}
	res << e.data[data_end..]
	res << e.types
	res << e.data[..data_end]
	return res
}

fn (mut e Encoder) encode<T>(data T) ? {
	e.typ<T>() ?
	e.data << 0 // WHY? Go just always adds a zero at the end, but it isn't in the spec (as far as I can tell)
	$if T is i8 {
		e.int(data) ?
	} $else $if T is i16 {
		e.int(data) ?
	} $else $if T is int {
		e.int(data) ?
	} $else $if T is i64 {
		e.int(data) ?
	} $else $if T is byte {
		e.uint(data) ?
	} $else $if T is u16 {
		e.uint(data) ?
	} $else $if T is u32 {
		e.uint(data) ?
	} $else $if T is u64 {
		e.uint(data) ?
	} $else $if T is u64 {
		e.uint(data) ?
	} $else $if T is f32 {
		e.float(data) ?
	} $else $if T is f64 {
		e.float(data) ?
	} $else $if T is string {
		e.string(data) ?
	} $else {
		return error('unknown type')
	}
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

fn (mut e Encoder) typ<T>() ? {
	$if T is i8 {
		e.int(int(Type.int)) ?
	} $else $if T is i16 {
		e.int(int(Type.int)) ?
	} $else $if T is int {
		e.int(int(Type.int)) ?
	} $else $if T is i64 {
		e.int(int(Type.int)) ?
	} $else $if T is byte {
		e.int(int(Type.uint)) ?
	} $else $if T is u16 {
		e.int(int(Type.uint)) ?
	} $else $if T is u32 {
		e.int(int(Type.uint)) ?
	} $else $if T is u64 {
		e.int(int(Type.uint)) ?
	} $else $if T is u64 {
		e.int(int(Type.uint)) ?
	} $else $if T is f32 {
		e.int(int(Type.float)) ?
	} $else $if T is f64 {
		e.int(int(Type.float)) ?
	} $else $if T is string {
		e.int(int(Type.string)) ?
	} $else {
		return error('unknown type')
	}
}

fn (mut e Encoder) int(x i64) ? {
	e.uint(if x < 0 { ((~u64(x)) << 1) | 1 } else { (u64(x) << 1) }) ?
}

fn (mut e Encoder) uint(x u64) ? {
	if x < 128 {
		e.data << [byte(x)]
	} else if x < 65536 {
		e.data << [~byte(1), byte(x >> 8), byte(x)]
	} else if x < 4294967296 {
		e.data << [~byte(3), byte(x >> 24), byte(x >> 16), byte(x >> 8), byte(x)]
	} else if x <= 18446744073709551615 {
		e.data << [~byte(7), byte(x >> 56), byte(x >> 48), byte(x >> 40), byte(x >> 32),
			byte(x >> 24), byte(x >> 16), byte(x >> 8), byte(x)]
	} else {
		return error('too big: $x')
	}
}

fn (mut e Encoder) float(x f64) ? {
	e.uint(bits.reverse_bytes_64(unsafe { FToU{ f: x }.u })) ?
}

// and back again, in decode.v
union FToU {
	f f64
	u u64
}

fn (mut e Encoder) string(x string) ? {
	e.uint(u64(x.len)) ?
	e.data << x.bytes()
}
