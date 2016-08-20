#!/usr/bin/ruby

# Implementation of SHA-2 hash function
# To check the result http://www.sha1-online.com/
$scriptname="sha-2.rb"


# FUNCTIONS

def rotr(n,x) # rotate right
	ret = ((x>>n) | (x<<(32-n))).to_s(2).reverse[0...32].reverse # reverse+reverse to get the 32 last chars (and so fix length)
end

def get2Dcell(m, i, j) # get a cell from a 2D array m
	m[i*15+j]
end

def Sig0_256(x)
	return rotr(2,x).to_i(2)^rotr(13,x).to_i(2)^rotr(22,x).to_i(2)
end

def Sig1_256(x)
	return rotr(6,x).to_i(2)^rotr(11,x).to_i(2)^rotr(25,x).to_i(2)	
end

def sig0_256(x)
	return rotr(7,x).to_i(2)^rotr(18,x).to_i(2)^(x>>3)
end

def sig1_256(x)
	return rotr(17,x).to_i(2)^rotr(19,x).to_i(2)^(x>>10)
end

def ch(x,y,z)
	return (x&y)^(~(x)&z)
end

def maj(x,y,z)
	return (x&y)^(x&z)^(y&z)
end

def list_first_prime_numbers(number)
	result=Array.new
	result.push(2)
	for i in 2..number
		new_prime_number=find_next_prime_number(result.last)
		result.push(new_prime_number)
	end
	return result
end

def find_next_prime_number(number)
	if(number==2)
		i=3
	else
		i=number+2
	end
	while(true)
		if (is_prime?(i))
			return i
		end
		i=i+1
	end
end

def is_prime?(number)
	 if number==1 || number ==0
	 	return false
	 end
	 return false unless number.is_a? Integer
	  is_prime = true
	  for i in 2..number-1
	    if number % i == 0
	      is_prime = false
	    end
	  end
	  return is_prime
end

def floatToHex(number) # Only number <1
	r = Array.new
	b=0
	while(number!=0 && b!=32)
		number = number*2
		r.push(number.to_i)
		number = number%1
		b = b+1
	end
	return r.join('').to_i(2).to_s(16)
end

# END FUNCTIONS


def encode(message)	
	# CONST

	nbBits = 8 # ASCII chars

	h0 = [0x6a09e667]
	h1 = [0xbb67ae85]
	h2 = [0x3c6ef372]
	h3 = [0xa54ff53a]
	h4 = [0x510e527f]
	h5 = [0x9b05688c]
	h6 = [0x1f83d9ab]
	h7 = [0x5be0cd19]

	# Get the 64 first prime numbers
	# Get the decimal part of the cube root
	# convert it in hexa (or binary)
	kt = list_first_prime_numbers(64).map! { |val|
		val = ((val ** (1.0/3))%1)
		val = floatToHex(val)
	}

	# END CONST

	# PREPROCESSING

	l = message.length*nbBits

	k = 448 -  ( (l+1) % (2**32) )

	while (k<0)
		k = k + 512
	end

	messageComplete = message.unpack("B*")[0]+'1'+'0'*k+'0'*(64-l.to_s(2).length)+l.to_s(2)
	# Message length is now a multiple of 512 bits

	# END PREPROCESSING

	# DIVISION INTO BLOCKS 

	m = Array.new
	array512 = messageComplete.chars.each_slice(512).map(&:join) # Divide the message into 512 bits blocks
	array512.each { |x| 
		array16 = x.chars.each_slice(32).map(&:join) # Divide each block into 32 bits words (16 words)
		array16.each { |y|
			m.push(y)
		}
	}

	# END DIVISION INTO BLOCKS

	# HASH

	n = array512.length
	w = Array.new # Array of string representing binary digits

	for i in 1..n

		# 1

		for t in 0..63
			if(t<=15)
				val = get2Dcell(m, i-1, t)
				w.push(val)
			else
				val = ( sig1_256(w[t-2].to_i(2)) + w[t-7].to_i(2) + sig0_256(w[t-15].to_i(2)) + w[t-16].to_i(2) ) & 0xffffffff
				val = val.to_s(2)
				w.push(val)
			end
		end

		# 2

		a=h0[i-1]
		b=h1[i-1]
		c=h2[i-1]
		d=h3[i-1]
		e=h4[i-1]
		f=h5[i-1]
		g=h6[i-1]
		h=h7[i-1]

		# 3

		total1 = nil
		total2 = nil
		for t in 0..63
			total1 = ( h + Sig1_256(e) + ch(e,f,g) + kt[t].to_i(16) + w[t].to_i(2) ) & 0xffffffff
			total2 = ( Sig0_256(a) + maj(a,b,c) ) & 0xffffffff
			h = g
			g = f
			f = e
			e = (d + total1) & 0xffffffff
			d = c
			c = b
			b = a
			a = (total1 + total2) & 0xffffffff
			puts t.to_s+"-a-"+a.to_s(16)+"-b-"+b.to_s(16)+"-c-"+c.to_s(16)+"-d-"+d.to_s(16)+"-e-"+e.to_s(16)+"-f-"+f.to_s(16)+"-g-"+g.to_s(16)+"-h-"+h.to_s(16)

		end

		# 4

		h0.push( (a+h0[i-1]) & 0xffffffff)
		h1.push( (b+h1[i-1]) & 0xffffffff)
		h2.push( (c+h2[i-1]) & 0xffffffff)
		h3.push( (d+h3[i-1]) & 0xffffffff)
		h4.push( (e+h4[i-1]) & 0xffffffff)
		h5.push( (f+h5[i-1]) & 0xffffffff)
		h6.push( (g+h6[i-1]) & 0xffffffff)
		h7.push( (h+h7[i-1]) & 0xffffffff)
	end

	# END HASH

	f0 = ("0x%08x" % h0[n]).to_s[2..-1]
	f1 = ("0x%08x" % h1[n]).to_s[2..-1]
	f2 = ("0x%08x" % h2[n]).to_s[2..-1]
	f3 = ("0x%08x" % h3[n]).to_s[2..-1]
	f4 = ("0x%08x" % h4[n]).to_s[2..-1]
	f5 = ("0x%08x" % h5[n]).to_s[2..-1]
	f6 = ("0x%08x" % h6[n]).to_s[2..-1]
	f7 = ("0x%08x" % h7[n]).to_s[2..-1]
	result = f0 + f1 + f2 + f3 + f4 + f5 + f6 + f7 # Concatenate all values

	puts result
end


# MAIN

def help()
	puts
    puts "Pass the string you want to hash as parameter"
    puts "Ex: ./#{$scriptname} test"
    puts
end


if(ARGV[0]=="-h" || ARGV[0]=="--help")
	help()
	exit 0
elsif(ARGV.length==1)
	encode(ARGV[0])
	exit 0
elsif(ARGV.length==0)
	puts
    puts "Use it with -h (or --help) option to learn more about it: ./#{$script_name} -h"
    puts
    exit 0
end


# END
