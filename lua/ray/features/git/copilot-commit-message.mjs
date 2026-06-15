import { execFileSync } from "node:child_process";
import crypto from "node:crypto";
import path from "node:path";
import { DatabaseSync } from "node:sqlite";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);

const TOKEN_URL = "https://api.github.com/copilot_internal/v2/token";
const CHAT_URL = "https://api.githubcopilot.com/chat/completions";
const TIMEOUT = 15000;
const MAX_DIFF = 20000;

const [configPath, copilotRoot] = process.argv.slice(2);
const keytarPath = path.join(copilotRoot, "copilot", "js", "compiled", process.platform, process.arch, "keytar.node");
const { getPassword } = require(keytarPath);

function decrypt(row, masterKey) {
  const ciphertext = Buffer.from(row.token_ciphertext);

  if (row.token_schema_version === 0) {
    return ciphertext.toString("utf8");
  }

  const decipher = crypto.createDecipheriv(
    "aes-256-gcm",
    Buffer.from(masterKey, "base64"),
    ciphertext.subarray(0, 12),
  );

  decipher.setAuthTag(ciphertext.subarray(-16));

  return Buffer.concat([
    decipher.update(ciphertext.subarray(12, -16)),
    decipher.final(),
  ]).toString("utf8");
}

function oauthToken(masterKey) {
  const db = new DatabaseSync(path.join(configPath, "github-copilot", "auth.db"));

  try {
    const row = db.prepare(`
      SELECT t.token_ciphertext, t.token_schema_version
      FROM oauth_tokens t
      LEFT JOIN active_sessions s ON s.token_id = t.token_id AND s.editor_id = 'vim'
      ORDER BY (s.editor_id IS NOT NULL) DESC, t.last_used_at DESC, t.token_id DESC
      LIMIT 1
    `).get();

    return row && decrypt(row, masterKey);
  } finally {
    db.close();
  }
}

function stagedDiff() {
  const diff = execFileSync("git", ["diff", "--cached", "--no-ext-diff", "--diff-algorithm=minimal"], {
    encoding: "utf8",
    env: { ...process.env, GIT_MASTER: "1" },
  });

  if (!diff.trim()) {
    throw new Error("No staged changes to summarize");
  }

  return diff;
}

async function copilotToken(oauth) {
  const response = await fetch(TOKEN_URL, {
    signal: AbortSignal.timeout(TIMEOUT),
    headers: {
      Accept: "application/json",
      Authorization: `Token ${oauth}`,
    },
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(body.message || body.error?.message || `Copilot token request failed (HTTP ${response.status})`);
  }
  if (!body.token) {
    throw new Error("Copilot token response missing token");
  }

  return body.token;
}

function prompt(diff) {
  if (diff.length > MAX_DIFF) {
    diff = `${diff.slice(0, MAX_DIFF)}\n\n[Diff truncated.]`;
  }

  return `Generate exactly one commit message for this staged git diff.

Rules:
- Output only the commit message, no markdown or explanation.
- Use Conventional Commits: <type>(<scope>): <description>.
- Use a scope only when it is obvious.
- Keep the subject under 72 characters.

Staged diff:
${diff}`;
}

async function commitMessage(bearer, diff) {
  const response = await fetch(CHAT_URL, {
    method: "POST",
    signal: AbortSignal.timeout(TIMEOUT),
    headers: {
      Authorization: `Bearer ${bearer}`,
      "Content-Type": "application/json",
      "Copilot-Integration-Id": "vscode-chat",
      "User-Agent": "GitHubCopilotChat/0.26.7",
    },
    body: JSON.stringify({
      model: "gpt-4o",
      stream: false,
      max_tokens: 200,
      temperature: 0.2,
      messages: [
        { role: "system", content: "You write concise Conventional Commit messages." },
        { role: "user", content: prompt(diff) },
      ],
    }),
  });

  const body = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(body.message || body.error?.message || `Copilot chat request failed (HTTP ${response.status})`);
  }

  return (body.choices?.[0]?.message?.content || "").trim();
}

const masterKey = await getPassword("copilot-language-server", "oauth-token-key");
const oauth = masterKey && oauthToken(masterKey);
const message = oauth && await commitMessage(await copilotToken(oauth), stagedDiff());

if (!message) {
  throw new Error("Copilot returned no commit message");
}

process.stdout.write(message);
