FROM alpine/git:2.47.2 AS source

ARG UPSTREAM_REPO=https://github.com/u2017310234/systemic-risk.git
ARG UPSTREAM_REF=main

RUN git clone --depth 1 --branch "${UPSTREAM_REF}" "${UPSTREAM_REPO}" /src

FROM python:3.12-slim

WORKDIR /app

COPY --from=source /src/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY --from=source /src/src ./src
COPY --from=source /src/mcp ./mcp
COPY --from=source /src/risk_mcp ./risk_mcp

ENV MCP_HOST=0.0.0.0 \
    MCP_PORT=8000 \
    DATA_DIR=/tmp/systemic-risk-data \
    GITHUB_REPO=u2017310234/systemic-risk \
    GITHUB_BRANCH=main \
    PYTHONUNBUFFERED=1

EXPOSE 8000

CMD ["uvicorn", "risk_mcp.server:app", "--host", "0.0.0.0", "--port", "8000"]
