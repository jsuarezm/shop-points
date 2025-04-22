# frozen_string_literal: true

require "socket"
require "json"
require "timeout"

class TcpDbGuard
  DEFAULT_PG_PORT = 5432
  CONNECT_TIMEOUT = 0.4 # seconds

  def initialize(app)
    @app = app
  end

  def call(env)
    # 1.  Quick TCP ping ----------------------------------------------------
    host, port = db_host_port
    if host && !tcp_open?(host, port)
      return disconnected_response(env)            # << early return
    end

    # 2.  DB port open → run the rest of the stack (may still fail
    #     later if credentials are wrong, but the TCP layer is alive).
    @app.call(env)

  # 3.  Catch any *runtime* connection errors that still bubble up ------
  rescue PG::ConnectionBad,
         ActiveRecord::DatabaseConnectionError,
         ActiveRecord::ConnectionNotEstablished
    disconnected_response(env)
  end

  # ------------------------------------------------------------------------
  # helpers
  # ------------------------------------------------------------------------
  private

  # 🔹 TCP probe (non‑blocking, safe)
  def tcp_open?(host, port)
    Timeout.timeout(CONNECT_TIMEOUT) do
      Socket.tcp(host, port, connect_timeout: CONNECT_TIMEOUT) { |_| true }
    end
  rescue StandardError
    false
  end

  # 🔹 Extract host / port from database.yml or ENV
  def db_host_port
    cfg   = Rails.configuration.database_configuration.fetch(Rails.env, {})
    host  = ENV["PGHOST"] || cfg["host"] || "localhost"
    port  = (ENV["PGPORT"] || cfg["port"] || DEFAULT_PG_PORT).to_i
    [host, port]
  rescue StandardError
    [nil, nil]                                   # nothing configured
  end

  # 🔹 JSON reply identical to your spec
  def disconnected_response(env)
    root      = env["PATH_INFO"] == "/"
    body_hash = { db: "disconnected" }
    body_hash[:tag] = ENV.fetch("TAG", "undefined") if root

    body = body_hash.to_json
    [
      root ? 200 : 503,
      { "Content-Type"   => "application/json",
        "Content-Length" => body.bytesize.to_s },
      [body]
    ]
  end
end