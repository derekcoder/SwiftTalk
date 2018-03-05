FROM swift:4.0.3

WORKDIR /app

COPY Package.swift ./
RUN swift package resolve

COPY Sources ./Sources

RUN swift build
CMD ./.build/debug/swift-server
