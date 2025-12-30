FROM testbase AS builder

FROM cgr.dev/chainguard/static:latest

WORKDIR /app

COPY --from=builder /build/testfile .

COPY file .
