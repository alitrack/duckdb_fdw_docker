FROM postgres

RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake

RUN git clone https://github.com/cwida/duckdb.git \
  && cd duckdb \
  && make

RUN apt-get install -y postgresql-server-dev-14 postgresql-client-14

RUN git clone https://github.com/alitrack/duckdb_fdw.git  \
   && cd duckdb_fdw \
   && cp /duckdb/build/release/tools/sqlite3_api_wrapper/libsqlite3_api_wrapper.so $(pg_config --libdir)  \
   && cp /duckdb/build/release/src/libduckdb.so $(pg_config --libdir)  \
   && cp /duckdb/tools/sqlite3_api_wrapper/include/sqlite3.h .  \
   && make USE_PGXS=1 \
   && make install USE_PGXS=1

ENV POSTGRES_HOST_AUTH_METHOD='trust'