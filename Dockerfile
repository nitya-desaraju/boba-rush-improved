FROM ubuntu:focal

RUN apt-get update && apt-get install -y libxcursor1 libxinerama1 libxrandr2 libxi6 libasound2 libpulse0 libglu1-mesa ca-certificates && rm -rf /var/lib/apt/lists/*

COPY . /app
WORKDIR /app

RUN chmod +x game.x86_64


EXPOSE 8080
CMD ["./game.x86_64", "--headless", "--", "--main-pack", "game.pck"]