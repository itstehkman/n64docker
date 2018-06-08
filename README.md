# n64 docker server

Play n64 with others online. The north star of this project is to matchmake players online who want to play a specific game,
spin up an n64 server anywhere (whether that be AWS, locally, or somewhere else) with that rom loaded,
and let them have at it. There is potential for an MMR system here too.

# Build and Deploy
```
make build
make run-all
```

# How to connect

If you want to connect over VNC, go to `http://$SERVER:<8000 + $PLAYER_NUM>/vnc.html` to use the web client.

Or connect using a traditional VNC client, like Screen Sharing or VNC Viewer (recommended) and connect to `$SERVER:<5900 + $PLAYER_NUM>`

# Super Smash Bros

The docker container starts up with the super smash bros rom. Have fun!

# Unanswered Questions

Context: mupen64plus.cfg allows for 4 users, and they can either use a joystick or keyboard. In the context
of using a keyboard, keys cannot be reused, so it may be difficult to map 4 users to a single keyboard.<br>
Q1: How can I get several users to play at once on the same server?<br>
Ideas:
One idea is for all users to choose their own keys to play with, and map them onto a non-used key on the
server. That way several players can reuse the same keys - in the common case, they will all use wasd, ijkl, and
arrow keys for dpad, cpad, and joystick directions.

Q2: How to get joysticks to work?<br>
Ideas:
If configured for joystick input, mupen64plus will look on /dev/input/jsX (X is the joystick number) and
it will read the events from there. But the server and the client are most likely on different filesystems. An idea to
get around this is to mount via ssh (using sshfs) the user's joystick input directory to the docker container as a volume.
This could be tricky - which user is which joystick number, and how do you handle part joystick, part keyboard configs?
Seems that this could be up to some matchmaking software.


Context: Seems like MacOS does not have traditional linux /dev/input devices for keyboard, so trying to do keyboard remapping is difficult in this sense<br>
Q4: How tf can you remap keys??<br>
Ideas: To remap the key events sent over VNC (using the RFB - remote fram buffer protocol), one can modify the bytes over the network. Check here for a specification: <https://github.com/rfbproto/rfbproto/blob/master/rfbproto.rst#744keyevent>. I've come across a tool called netsed which can be used as such: [NetSed and iptables proxying](https://serverfault.com/a/321671). The client connects to netsed on the client side, which acts as a proxy and modifies the tcp packets and sends them to the server. In specific, check Q1 in the answered question for how to deal with different key code types.<br>

Q5: How can this be abstracted for more emulators in the future?<br>
Ideas: Great question... TBD!

# Answered Questions
Q1: Wtf is the difference between SDL Keycodes, SDL Scan codes, and X11 Keysyms? Why should I care??<br>
A: It's a mouthful, I know... When we remap VNC KeyEvents (which use X11 Keysyms),
we also need to configure the mupen server... which configures each key in mupen64plus.cfg by calling
key(sdl key code)  to get the SDL Scan code. (see `util/sdl_key_convert.c` for definitions of scan codes).
And how do SDL Keycodes map to VNC KeyEvents? We'll just have to have a look up table, where the keycodes are
mapped to each other by the keyboard button it represents - this will allow us to both configure the client proxy and the mupen server's config. <br>

Q2: How can this support several different environments that clients are connecting from?<br>
The noVNC client allows you to use the browser to play - that is environment agnostic!

# Roadmap
- NoVNC working (p0)
  - [x] Container that runs NoVNC webserver
- Good way of provisioning / deploying / serving for scale : (p0)
  - [ ] Draw architecture diagram
- Nintendo Switch controllers to work (p1)
  - [ ] Need to make sure vnc client / server accept gii, which allows joystick
  - [ ] Play locally, not sending key events over VNC
- Matchmaking (p1)
  o There's two modes: matchmake, and share link. Version 0 includes just sharing a link to play
- Performance monitoring / why did I choose noVNC (p0.5)
