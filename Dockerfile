FROM postgres

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake

RUN git clone https://github.com/cwida/duckdb.git \
  && cd duckdb \
  && make

RUN apt-get install -y postgresql-server-dev-15 postgresql-client-15 wget unzip

RUN git clone -b pg15 https://github.com/alitrack/duckdb_fdw.git  \
   && cd duckdb_fdw \
   && wget -c https://github.com/duckdb/duckdb/releases/latest/download/libduckdb-linux-amd64.zip \
   && unzip -d . libduckdb-linux-amd64.zip
   && cp libduckdb.so $(pg_config --libdir)  \
   && make USE_PGXS=1 \
   && make install USE_PGXS=1

ENV POSTGRES_HOST_AUTH_METHOD='trust'
USER postgres
RUN  /duckdb/build/release/duckdb -unsigned -c "install '/duckdb/build/release/extension/parquet/parquet.duckdb_extension'"
