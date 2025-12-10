FROM python:3.11-alpine AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    libxml2-dev \
    libxslt-dev \
    postgresql-dev

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app

# Create non-root user for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=builder /install /usr/local

COPY --chown=appuser:appgroup . .

# Switch to non-root user
USER appuser

EXPOSE 5000

CMD ["python", "main.py"]

RUN useradd -m myuser
USER myuser
