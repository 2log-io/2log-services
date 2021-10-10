FROM frime/qt5-qtdeclarative
RUN ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
COPY . /
WORKDIR /
RUN qmake
RUN make -j12
ENTRYPOINT ["./LaserControl"]
