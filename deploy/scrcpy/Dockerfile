# ws-scrcpy: streams the android screen to the browser and sends touch/keys back.
FROM node:18-bookworm
RUN apt-get update \
 && apt-get install -y --no-install-recommends android-tools-adb git python3 build-essential \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /opt
RUN git clone --depth 1 https://github.com/NetrisTV/ws-scrcpy.git \
 && cd ws-scrcpy && npm install && npm run dist \
 && cd dist && npm install --omit=dev
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh
EXPOSE 8000
ENTRYPOINT ["/entry.sh"]
