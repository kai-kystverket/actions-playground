FROM testbase AS builder

FROM scratch

WORKDIR /app

COPY --from=builder /build/testfile .

COPY file .







