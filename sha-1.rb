#!/usr/bin/ruby

# Implementation of SHA-1 hash function
# To check the result http://www.sha1-online.com/
$scriptname="sha-1.rb"


# FUNCTIONS

def rotl(n,x) # rotate left
	ret = ((x<<n) | (x>>32-n) ).to_s(2).reverse[0...32].reverse # reverse+reverse to get the 32 last chars (and so fix length)
end

def get2Dcell(m, i, j) # get a cell from a 2D array m
	m[i*15+j]
end

def f(t,x,y,z)
	ret = nil
	if(t<=19)
		ret=(x&y)|(reverse(x)&z)
	elsif(t<=39)
		ret = x^y^z
	elsif(t<=59)
		ret = (x&y)|(x&z)|(y&z)
	else
		ret = x^y^z
	end
end

def K(t)
	ret = nil
	if(t<=19)
		ret=0x5a827999
	elsif(t<=39)
		ret = 0x6ed9eba1
	elsif(t<=59)
		ret = 0x8f1bbcdc
	else
		ret = 0xca62c1d6
	end
end

def reverse(x) # reverse a binary number (Ex: 10010 -> 01001)
	b = ~x
	reverse = 31.downto(0).map { |n| b[n] }.join
	reverse.to_i(2)
end

# END FUNCTIONS


def encode(message)	
# CONST

nbBits = 8 # ASCII chars

h0 = [0x67452301]
h1 = [0xefcdab89]
h2 = [0x98badcfe]
h3 = [0x10325476]
h4= [0xc3d2e1f0]

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

	for t in 0..79
		if(t<=15)
			val = get2Dcell(m, i-1, t)
			w.push(val)
		else
			sum = w[t-3].to_i(2)^w[t-8].to_i(2)^w[t-14].to_i(2)^w[t-16].to_i(2)
			val = rotl(1, sum)
			w.push(val)
		end
	end

	# 2

	a=h0[i-1]
	b=h1[i-1]
	c=h2[i-1]
	d=h3[i-1]
	e=h4[i-1]

	# 3

	total = nil
	for t in 0..79
		total = (rotl(5,a).to_i(2) + f(t,b,c,d) + e + K(t) + w[t].to_i(2)) %  (2**32)
		e = d
		d = c
		c = rotl(30, b).to_i(2)
		b = a
		a = total
	end

	# 4

	h0.push( (a+h0[i-1]) % (2**32))
	h1.push( (b+h1[i-1]) % (2**32))
	h2.push( (c+h2[i-1]) % (2**32))
	h3.push( (d+h3[i-1]) % (2**32))
	h4.push( (e+h4[i-1]) % (2**32))
end

# END HASH

f0 = ("0x%08x" % h0[n]).to_s[2..-1]
f1 = ("0x%08x" % h1[n]).to_s[2..-1]
f2 = ("0x%08x" % h2[n]).to_s[2..-1]
f3 = ("0x%08x" % h3[n]).to_s[2..-1]
f4 = ("0x%08x" % h4[n]).to_s[2..-1]
result = f0 + f1 + f2 + f3 + f4 # Concatenate all values

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
