ARG POSTGRES_VERSION=16
FROM postgres:${POSTGRES_VERSION}

ENV POSTGRES_VERSION=16
ENV DUCKDB_VERSION=0.9.2

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake

RUN apt-get install -y postgresql-server-dev-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION} wget unzip

RUN git clone -b pg${POSTGRES_VERSION} https://github.com/alitrack/duckdb_fdw.git  \
   && cd duckdb_fdw \
   && wget -c https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/libduckdb-linux-amd64.zip \
   && unzip -d . libduckdb-linux-amd64.zip \
   && cp libduckdb.so $(pg_config --libdir)  \
   && make USE_PGXS=1 \
   && make install USE_PGXS=1

ENV POSTGRES_HOST_AUTH_METHOD='trust'
USER postgres
