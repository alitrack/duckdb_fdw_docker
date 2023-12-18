# Use an official PostgreSQL image as the base image
ARG POSTGRES_VERSION=16
FROM postgres:${POSTGRES_VERSION} AS builder

# Set default values for build arguments
ARG POSTGRES_VERSION=16
ARG DUCKDB_VERSION=0.9.2

# Install build dependencies
RUN apt-get update && apt-get install -y \
  git \
  build-essential \
  cmake \
  postgresql-server-dev-${POSTGRES_VERSION} \
  postgresql-client-${POSTGRES_VERSION} \
  wget \
  unzip

# Clone duckdb_fdw repository and build
RUN git clone  https://github.com/alitrack/duckdb_fdw.git \
   && cd duckdb_fdw \
   && wget -c https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/libduckdb-linux-amd64.zip \
   && unzip -o -d . libduckdb-linux-amd64.zip \
   && cp libduckdb.so $(pg_config --libdir) \
   && make USE_PGXS=1 \
   && make install USE_PGXS=1

# Set environment variables
ENV POSTGRES_HOST_AUTH_METHOD='trust'


# Switch to the postgres user
USER postgres

# Optionally, you might want to include additional configurations or initialization steps here

# Create the final image
FROM postgres:${POSTGRES_VERSION}
ARG POSTGRES_VERSION=16
# Copy duckdb_fdw artifacts from the builder stage
COPY --from=builder duckdb_fdw/duckdb_fdw.so /usr/lib/postgresql/${POSTGRES_VERSION}/lib/
COPY --from=builder duckdb_fdw/duckdb_fdw.control /usr/share/postgresql/${POSTGRES_VERSION}/extension/
COPY --from=builder duckdb_fdw/duckdb_fdw*.sql /usr/share/postgresql/${POSTGRES_VERSION}/extension/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libduckdb.so /usr/lib/x86_64-linux-gnu/
