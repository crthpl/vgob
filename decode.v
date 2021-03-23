module vgob

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
	$if T is int {
		d.decode_type(.int) ?
		return int(d.decode_int() ?)
	} $else $if T is i64 {
		d.decode_type(.int) ?
		return i64(d.decode_int() ?)
	} $else $if T is u64 {
		d.decode_type(.uint) ?
		x := u64(d.decode_uint() ?)
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
		bytes := d.gbs(len - 1)

		mut res := u64(bytes.last())

		if len == 2 { // < 32768
			res |= u64(bytes[0]) << 8
		} else if len == 4 {
			res |= bytes[0] << 24
			res |= bytes[1] << 16
			res |= bytes[2] << 8
		} else {
			return error('too big')
		}
		// res--
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

// gb gets the byte at the current position
[inline]
fn (d Decoder) gb() byte {
	return d.gbs(1)[0]
}

// gbs gets the bytes from the current position to n bytes in the future
fn (d Decoder) gbs(n int) []byte {
	return d.buf[d.i..d.i + n]
}
