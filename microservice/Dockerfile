#Build stage
FROM python:3.12-alpine3.22 AS builder

WORKDIR /app

COPY requirements.txt .

COPY app ./app

COPY run.py /app/run.py

COPY gunicorn_config.py /app/gunicorn_config.py

RUN pip install --target=/install/lib/python3.11/site-packages --no-cache-dir -r requirements.txt

RUN pip install gunicorn

RUN rm requirements.txt

#Production stage
FROM python:3.12-alpine3.22 AS production

ENV PYTHONPATH="/usr/local/lib/python3.11/site-packages"

RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

COPY --from=builder /install/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

COPY --from=builder /app .

COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

COPY --from=builder /usr/local/lib/python3.12/site-packages/gunicorn /usr/local/lib/python3.12/site-packages/gunicorn 

RUN chown -R appuser:appuser /app

EXPOSE 5000

USER appuser

CMD ["gunicorn","--config","gunicorn_config.py","run:app"]
