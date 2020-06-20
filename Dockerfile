FROM alpine:3.12 as builder
RUN apk add --no-cache build-base cmake ninja python3 \
      binutils-dev curl-dev elfutils-dev
WORKDIR /root
ENV KCOV=https://github.com/SimonKagstrom/kcov/archive/v38.tar.gz
RUN wget -q $KCOV -O - | tar xz -C ./ --strip-components 1
RUN mkdir build && cd build \
 && CXXFLAGS="-D__ptrace_request=int" cmake -G Ninja .. \
 && cmake --build . --target install

FROM alpine:3.12
RUN apk add --no-cache bash python3 binutils-dev curl-dev elfutils-libelf
COPY --from=builder /usr/local/bin/kcov* /usr/local/bin/
COPY --from=builder /usr/local/share/doc/kcov /usr/local/share/doc/kcov
CMD ["/usr/local/bin/kcov"]
