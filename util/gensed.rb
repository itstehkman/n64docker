#!/usr/bin/ruby
require 'json'
require 'irb'

PLAYER_NUM = ENV.fetch("PLAYER_NUM", "1")

# This script is meant to create a sed string for netsed (beware, it does not
# support regex) that can maps VNC Keys to unused keys on mupen64plus, since each
# key can only be used once. The idea is that each player uses wasd,ijkl, etc locally
# but the server will conveniently lay those keys out as it wishes. The translation is done via a client side proxy that modifies the VNC Key events at the tcp level.
# Format of a Key Event is as specified here: https://github.com/rfbproto/rfbproto/blob/master/rfbproto.rst#keyevent
# Key sym codes can be found here: https://www.cl.cam.ac.uk/~mgk25/ucs/keysymdef.h

# \x04 = key event code, \x00 = off, 2 bytes padding (usually null bytes), 4 bytes keysym (network order -> big endian)
off_format = "s/%%04%%00%%00%%00%%00%%00%s/%%04%%00%%00%%00%%00%%00%s"
on_format =  "s/%%04%%01%%00%%00%%00%%00%s/%%04%%01%%00%%00%%00%%00%s"

def netsed_short_str(i)
  x = "%04x" % i
  even = true
  res = []
  x.chars.each do |c|
    if even
      res << "%"
      even = false
    else
      even = true
    end
    res << c
  end
  res.join
end

def netsed_rule(orig, replace, off_format, on_format)
  orig_netsed = netsed_short_str orig
  replace_netsed = netsed_short_str replace
  [off_format % [orig_netsed, replace_netsed],
   on_format % [orig_netsed, replace_netsed]]
end

keytranslations = File.read('keysym-translation.json')
keytranslations = JSON.parse(keytranslations)

translations = keytranslations[PLAYER_NUM]
rules = []
translations.each do |k, translation|
  orig = translation["original"]["x11_keysym"]
  replace = translation["replacement"]["x11_keysym"]
  rule = netsed_rule(orig, replace, off_format, on_format)
  rules << rule
end

puts rules.join(" ")
