CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS repositories (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  source_type TEXT NOT NULL,
  source_url TEXT NOT NULL,
  default_branch TEXT NOT NULL DEFAULT 'main',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS indexing_runs (
  id BIGSERIAL PRIMARY KEY,
  repository_id BIGINT NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS file_chunks (
  id BIGSERIAL PRIMARY KEY,
  repository_id BIGINT NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  path TEXT NOT NULL,
  sha TEXT NOT NULL,
  start_line INT NOT NULL,
  end_line INT NOT NULL,
  content TEXT NOT NULL,
  embedding VECTOR(1536),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS review_runs (
  id BIGSERIAL PRIMARY KEY,
  repository_id BIGINT NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  diff_sha TEXT NOT NULL,
  status TEXT NOT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS review_findings (
  id BIGSERIAL PRIMARY KEY,
  review_run_id BIGINT NOT NULL REFERENCES review_runs(id) ON DELETE CASCADE,
  severity TEXT NOT NULL,
  category TEXT NOT NULL,
  file_path TEXT,
  line INT,
  title TEXT NOT NULL,
  detail TEXT NOT NULL,
  suggestion TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_sessions (
  id BIGSERIAL PRIMARY KEY,
  repository_id BIGINT NOT NULL REFERENCES repositories(id) ON DELETE CASCADE,
  user_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_messages (
  id BIGSERIAL PRIMARY KEY,
  session_id BIGINT NOT NULL REFERENCES chat_sessions(id) ON DELETE CASCADE,
  role TEXT NOT NULL,
  content TEXT NOT NULL,
  citations_json JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS prompt_templates (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  version TEXT NOT NULL,
  purpose TEXT NOT NULL,
  content TEXT NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS mcp_audit_logs (
  id BIGSERIAL PRIMARY KEY,
  tool_name TEXT NOT NULL,
  input_json JSONB,
  output_json JSONB,
  latency_ms INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_file_chunks_repo ON file_chunks(repository_id);
CREATE INDEX IF NOT EXISTS idx_review_runs_repo ON review_runs(repository_id);
CREATE INDEX IF NOT EXISTS idx_chat_sessions_repo ON chat_sessions(repository_id);
CREATE INDEX IF NOT EXISTS idx_mcp_audit_logs_tool ON mcp_audit_logs(tool_name);
CREATE INDEX IF NOT EXISTS idx_file_chunks_embedding ON file_chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
