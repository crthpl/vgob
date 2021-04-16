module vgob

import math.bits

struct Decoder {
mut:
	buf []byte
	i   int
}

fn decode<T>(data []byte) ?T {
	mut d := Decoder{
		buf: data
	}

	len := d.decode_uint() ?
	defer {
		if d.i != len {
			error('invalid length')
		}
	}
	$if T is i8 {
		d.decode_type(.int) ?
		return i8(d.decode_int() ?)
	} $else $if T is i16 {
		d.decode_type(.int) ?
		return i16(d.decode_int() ?)
	} $else $if T is int {
		d.decode_type(.int) ?
		return int(d.decode_int() ?)
	} $else $if T is i64 {
		d.decode_type(.int) ?
		return i64(d.decode_int() ?)
	} $else $if T is byte {
		d.decode_type(.uint) ?
		x := byte(d.decode_uint() ?)
		return x
	} $else $if T is u16 {
		d.decode_type(.uint) ?
		x := u16(d.decode_uint() ?)
		return x
	} $else $if T is u32 {
		d.decode_type(.uint) ?
		x := u32(d.decode_uint() ?)
		return x
	} $else $if T is u64 {
		d.decode_type(.uint) ?
		x := u64(d.decode_uint() ?)
		return x
	} $else $if T is f32 {
		d.decode_type(.float) ?
		x := f32(d.decode_float() ?)
		return x
	} $else $if T is f64 {
		d.decode_type(.float) ?
		x := f64(d.decode_float() ?)
		return x
	} $else $if T is string {
		d.decode_type(.string) ?
		x := d.decode_string() ?
		return x
	} $else {
		return error('unknown type')
	}
}

fn (mut d Decoder) decode_type(expect Type) ?Type {
	defer {
		d.i++ // because of 0 after type
	}
	typ := Type(d.decode_int() ?)
	if typ != expect {
		return error('cannot cast $typ to $expect')
	}
	return typ
}

fn (mut d Decoder) decode_uint() ?u64 {
	first_byte := d.gb()
	d.i++
	if first_byte > 127 {
		len := (~first_byte) + 1
		bytes := d.gbs(len)

		mut res := u64(0)
		// println(bytes.map(int(it)))
		if len == 2 { // < 32768
			res |= u64(bytes[0]) << 8
			res |= u64(bytes[1])
		} else if len == 4 {
			res |= u64(bytes[0]) << 24
			res |= u64(bytes[1]) << 16
			res |= u64(bytes[2]) << 8
			res |= u64(bytes[3])
		} else if len == 8 {
			res |= u64(bytes[0]) << 56
			res |= u64(bytes[1]) << 48
			res |= u64(bytes[2]) << 40
			res |= u64(bytes[3]) << 32
			res |= u64(bytes[4]) << 24
			res |= u64(bytes[5]) << 16
			res |= u64(bytes[6]) << 8
			res |= u64(bytes[7])
		} else {
			return error('invalid sized integer: $len')
		}
		// println(res)
		return res
	}
	return first_byte
}

fn (mut d Decoder) decode_int() ?i64 {
	x := d.decode_uint() ?
	sign := x & 1
	num := x >> 1
	// 0->positive
	// 1->negative
	return if sign == 0 { num } else { ~num }
}

fn (mut d Decoder) decode_float() ?f64 {
	return unsafe {
		FToU{
			u: bits.reverse_bytes_64(d.decode_uint() ?)
		}.f
	}
}

// fn encode_float(x f64) ?[]byte {
// 	mut res := u64(0)
// 	unsafe {
// 		first_byte := &byte(&x)
// 		// this operation reverses the float (because x86 is little-endian)
// 		res |= (*(first_byte + 0))
// 		res |= (*(first_byte + 1)) << 8
// 		res |= (*(first_byte + 2)) << 16
// 		res |= (*(first_byte + 3)) << 24
// 		res |= (*(first_byte + 4)) << 32
// 		res |= (*(first_byte + 5)) << 40
// 		res |= (*(first_byte + 6)) << 48
// 		res |= (*(first_byte + 7)) << 56
// 	}
// 	return encode_uint(res)
// }

[manualfree]
fn (mut d Decoder) decode_string() ?string {
	len := d.decode_uint() ?
	mut res := []byte{}

	for _ in 0 .. len {
		res << d.gb()
		d.i++
	}
	return unsafe { cstring_to_vstring(res.data) }
}

// gb gets the byte at the current position
[inline]
fn (d Decoder) gb() byte {
	return d.gbs(1)[0]
}

// gbs gets the bytes from the current position to n bytes in the future
fn (d Decoder) gbs(n int) []byte {
	return d.buf[d.i..d.i + n]
}
