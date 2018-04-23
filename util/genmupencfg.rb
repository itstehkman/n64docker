require 'json'

template = "# Mupen64Plus SDL Input Plugin config parameter version number.  Please don't change this version number.
version = 2.000000
# Controller configuration mode: 0=Fully Manual, 1=Auto with named SDL Device, 2=Fully automatic
mode = 0
# Specifies which joystick is bound to this controller: -1=No joystick, 0 or more= SDL Joystick number
device = -1
# SDL joystick name (or Keyboard)
name = \"Keyboard\"
# Specifies whether this controller is 'plugged in' to the simulated N64
plugged = True
# Specifies which type of expansion pak is in the controller: 1=None, 2=Mem pak, 5=Rumble pak
plugin = 1
# If True, then mouse buttons may be used with this controller
mouse = False
# Scaling factor for mouse movements.  For X, Y axes.
MouseSensitivity = \"2.00,2.00\"
# The minimum absolute value of the SDL analog joystick axis to move the N64 controller axis value from 0.  For X, Y axes.
AnalogDeadzone = \"4096,4096\"
# An absolute value of the SDL joystick axis >= AnalogPeak will saturate the N64 controller axis value (at 80).  For X, Y axes. For each axis, this must be greater than the corresponding AnalogDeadzone value
AnalogPeak = \"32768,32768\"
# Digital button configuration mappings
DPad R = \"key(%d)\"
DPad L = \"key(%d)\"
DPad D = \"key(%d)\"
DPad U = \"key(%d)\"
Start = \"key(%d)\"
Z Trig = \"key(%d)\"
B Button = \"key(%d)\"
A Button = \"key(%d)\"
C Button R = \"key(%d)\"
C Button L = \"key(%d)\"
C Button D = \"key(%d)\"
C Button U = \"key(%d)\"
R Trig = \"key(%d)\"
L Trig = \"key(%d)\"
Mempak switch = \"\"
Rumblepak switch = \"\"
# Analog axis configuration mappings
X Axis = \"key(%d,%d)\"
Y Axis = \"key(%d,%d)\"


"

keytranslations = File.read('./config/keysym-translation.json')
keytranslations = JSON.parse(keytranslations)

def keycode(translations, key)
  translations[key]["replacement"]["sdl_keycode"]
end

def gen_fmt_array(translations)
  # d pad -> wasd
  [keycode(translations, "d"), keycode(translations,"a"), keycode(translations,"s"), keycode(translations,"w"),
   keycode(translations,"enter"), # start -> enter
   keycode(translations,"z"),
   keycode(translations,"lctrl"), keycode(translations,"lshift"),
  # cpad -> ijkl
   keycode(translations,"l"), keycode(translations, "j"), keycode(translations,"k"), keycode(translations, "i"),
  #r,l
   keycode(translations,"x"), keycode(translations,"c"),
   keycode(translations,"left"), keycode(translations,"right"),
   keycode(translations,"up"), keycode(translations,"down")]
end

player_templates = {}
keytranslations.each do |player, translations|
  fmt = gen_fmt_array(translations)
  player_templates[player] = template % fmt
end

# Replace mupen cfg

mupen_template = File.read('./config/mupen64plus.template.cfg')
mupen_config = ""
i = mupen_template.index("[Input-SDL-Control1]")
mupen_config << mupen_template[0...i]

player_templates.each do |player, config|
  mupen_config << ("[Input-SDL-Control%d]\n\n" % player.to_i)
  mupen_config << config
end

i = mupen_template.index("[UI-Console]")
mupen_config << mupen_template[i..-1]
puts mupen_config
