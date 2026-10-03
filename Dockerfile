# Builds Salam Press inside the published Salam image.
#
#   docker build -t salam-press .
#   docker run --rm -v "$PWD/site:/app/site" salam-press
FROM basemax/salam:0.4.4

WORKDIR /app
COPY . .
RUN salam build src/main.salam --output=/app/salam-press --log-level=error

ENTRYPOINT ["/app/salam-press"]
CMD ["--out=/app/site"]
