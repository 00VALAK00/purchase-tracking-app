import os
from pathlib import Path

import pytest
from dotenv import load_dotenv


def test_mysql_connection_and_simple_query():
    # Load env from backend/.env if present
    env_path = Path(__file__).resolve().parents[1] / "backend" / ".env"
    if env_path.exists():
        load_dotenv(env_path)

    # Defaults match backend/docker-compose.yml
    host = os.getenv("MYSQL_HOST", "127.0.0.1")
    port = int(os.getenv("MYSQL_PORT", "3306"))
    user = os.getenv("MYSQL_USER", "user")
    password = os.getenv("MYSQL_PASSWORD", "password")
    database = os.getenv("MYSQL_DATABASE", "purchase_tracking")

    try:
        import mysql.connector  # type: ignore
    except Exception as exc:  # pragma: no cover
        pytest.skip(f"mysql-connector-python not installed: {exc}")

    conn = mysql.connector.connect(
        host="localhost",
        port=3306,
        user=user,
        password=password,
        database=database,
        connection_timeout=5,
    )
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1")
            row = cur.fetchone()
            assert row is not None and row[0] == 1
    finally:
        conn.close()


