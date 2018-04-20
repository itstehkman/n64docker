FROM ubuntu

RUN apt-get update

RUN apt-get install -y x11vnc xvfb xserver-xorg-video-dummy xinit

RUN apt-get install -y mupen64plus-qt

RUN mkdir ~/.vnc

RUN x11vnc -storepasswd 1234 ~/.vnc/passwd

EXPOSE 5900

COPY smash.z64 /

RUN mkdir -p /etc/X11

COPY xorg.conf /etc/X11/xorg.conf

ENV DISPLAY :0

CMD startx & sleep 3 && \
    x11vnc -forever -usepw -shared & sleep 3 && \
    /usr/games/mupen64plus smash.z64
