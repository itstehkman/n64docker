require 'pry'
require 'json'

reserved = [0x1b, 0x11e, 0x120, 0x0, 0x122, 0x123, 0x125, 0x70, 0x6d, 0x5d, 0x5b, 0x66, 0x2f]
original_keys = {
  "w": {"sdl_keycode": 0x77, "x11_keysym": 0x77},
  "a": {"sdl_keycode": 0x61, "x11_keysym": 0x61},
  "s": {"sdl_keycode": 0x73, "x11_keysym": 0x73},
  "d": {"sdl_keycode": 0x64, "x11_keysym": 0x64},
  "i": {"sdl_keycode": 0x69, "x11_keysym": 0x69},
  "j": {"sdl_keycode": 0x6a, "x11_keysym": 0x6a},
  "k": {"sdl_keycode": 0x6b, "x11_keysym": 0x6b},
  "l": {"sdl_keycode": 0x6c, "x11_keysym": 0x6c},
  "z": {"sdl_keycode": 0x7a, "x11_keysym": 0x7a},
  "x": {"sdl_keycode": 0x78, "x11_keysym": 0x78},
  "c": {"sdl_keycode": 0x63, "x11_keysym": 0x63},
  "lshift": {"sdl_keycode": 0x130, "x11_keysym": 0xffe1},
  "lctrl": {"sdl_keycode": 0x132, "x11_keysym": 0xffe3},
  "up": {"sdl_keycode": 0x111, "x11_keysym": 0xff52},
  "down": {"sdl_keycode": 0x112, "x11_keysym": 0xff54},
  "left": {"sdl_keycode": 0x114, "x11_keysym": 0xff51},
  "right": {"sdl_keycode": 0x113, "x11_keysym": 0xff53},
  "enter": {"sdl_keycode": 0xd, "x11_keysym": 0xff0d},
}


def player_config(original_keys, keycodes_enum, sdl_keycodes_to_x11keycodes)
  config = {}
  for key in original_keys.keys do
    sdl_keycode = x11_keysym = keycodes_enum.next
    if sdl_keycodes_to_x11keycodes.include?(sdl_keycode.to_s(16)) then
      x11_keysym = sdl_keycodes_to_x11keycodes[sdl_keycode.to_s(16)].to_i(16)
    end
    config[key] =
      {"original": original_keys[key],
       "replacement": {"sdl_keycode": sdl_keycode, "x11_keysym": x11_keysym}}
  end
  config
end

sdl_keycodes = File.readlines("./config/sdlkeycodes")
sdl_keycodes = sdl_keycodes.map{|n| n.strip.chomp.split("u,")[0].to_i(16)}
sdl_keycodes = sdl_keycodes.select{|n| !reserved.include? n}

# Most x11 key codes match, but here are some that dont (which is good enough)
sdl_keycodes_to_x11keycodes = File.read('./config/sdlkeycodes2x11keysyms.json')
# keys and vals are in hex (without 0x, for easy keying)
sdl_keycodes_to_x11keycodes = JSON.parse(sdl_keycodes_to_x11keycodes)

num_players = 4
keytranslations = {}
avail_sdl_keycodes = sdl_keycodes.each

for i in 1..num_players do
  keytranslations[i] = player_config(original_keys, avail_sdl_keycodes, sdl_keycodes_to_x11keycodes)
end

puts JSON.pretty_generate keytranslations
