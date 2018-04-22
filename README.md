# n64 docker server

Play n64 with others online. The north star of this project is to matchmake players online who want to play a specific game,
spin up an n64 server anywhere (whether that be AWS, locally, or somewhere else) with that rom loaded,
and let them have at it. There is potential for an MMR system here too.

# Build and Deploy
```
make build
make run
```

# How to connect

Connect over VNC to $SERVER_ADDR:5900 to view the n64 display and interact with it!

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

Q3: How can this support several different environments that clients are connecting from?<br>
Ideas:
One might be connecting from MacOS, Linux, Windows, something else, or any specific flavor of these.
An idea to get around this is to make clients connect via a docker container - that way all clients have the same interface,
and no environment-specific software or configuration is needed. This docker container could do the keyboard mapping, connect to
VNC for you, and have any specific client logic needed. Sounds good I think!<br>

Context: Seems like MacOS does not have traditional linux /dev/input devices for keyboard, so trying to do keyboard remapping is difficult in this sense<br>
Q4: How tf can you remap keys??<br>
Ideas: To remap the key events sent over VNC (using the RFB - remote fram buffer protocol). Check here for a specification: <https://github.com/rfbproto/rfbproto/blob/master/rfbproto.rst#744keyevent>. I'm thinking to use iptables and something like [NetSed and iptables proxying](https://serverfault.com/a/321671).
This may have to be done client side to map the players as specified in Q3. <br>

Q5: How can this be abstracted for more emulators in the future?<br>
Ideas: Great question... TBD!

# Roadmap
