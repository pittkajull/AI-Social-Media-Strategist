# Example Workflows

Dokumen ini berisi contoh konfigurasi workflow untuk n8n.

---

## Workflow 1: Generate & Publish Content

**Schedule:** Daily at 08:00 WIB (01:00 UTC)

### Nodes Configuration

#### 1. Cron Trigger
```json
{
  "node": "Schedule Trigger",
  "type": "n8n-nodes-base.scheduleTrigger",
  "parameters": {
    "rule": {
      "interval": [
        {
          "field": "cronExpression",
          "expression": "0 1 * * *"
        }
      ]
    }
  }
}
```

#### 2. Fetch Knowledge Base
```json
{
  "node": "Get Knowledge",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM knowledge ORDER BY created_at DESC",
    "options": {}
  },
  "credentials": {
    "postgres": "Supabase"
  }
}
```

#### 3. Fetch Ideas Backlog
```json
{
  "node": "Get Ideas",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM ideas WHERE status = 'pending' ORDER BY priority DESC",
    "options": {}
  },
  "credentials": {
    "postgres": "Supabase"
  }
}
```

#### 4. Strategist AI
```json
{
  "node": "Strategist AI",
  "type": "@n8n/n8n-nodes-langchain.googleGemini",
  "parameters": {
    "model": "gemini-1.5-pro",
    "prompt": "Kamu adalah Content Strategist bernama Nara...\n\nKnowledge Base:\n{{ $json.knowledge }}\n\nIdeas:\n{{ $json.ideas }}",
    "options": {
      "temperature": 0.7,
      "maxOutputTokens": 1024
    }
  },
  "credentials": {
    "googleGeminiApi": "Gemini API"
  }
}
```

#### 5. Writer AI
```json
{
  "node": "Writer AI",
  "type": "@n8n/n8n-nodes-langchain.googleGemini",
  "parameters": {
    "model": "gemini-1.5-pro",
    "prompt": "Kamu adalah Content Writer bernama Nara...\n\nStrategy:\n{{ $json.strategist_output }}\n\nKnowledge:\n{{ $json.knowledge }}",
    "options": {
      "temperature": 0.8,
      "maxOutputTokens": 1024
    }
  }
}
```

#### 6. Editor AI
```json
{
  "node": "Editor AI",
  "type": "@n8n/n8n-nodes-langchain.googleGemini",
  "parameters": {
    "model": "gemini-1.5-pro",
    "prompt": "Kamu adalah Content Editor bernama Nara...\n\nDraft:\n{{ $json.draft_content }}\n\nPersona Guidelines:\n{{ $json.persona }}",
    "options": {
      "temperature": 0.5,
      "maxOutputTokens": 1024
    }
  }
}
```

#### 7. Publish to Buffer
```json
{
  "node": "Buffer Publish",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "POST",
    "url": "https://api.bufferapp.com/1/updates/create.json",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpQueryAuth",
    "bodyParameters": {
      "parameters": [
        {
          "name": "text",
          "value": "={{ $json.final_content }}"
        },
        {
          "name": "profile_ids[]",
          "value": "{{ $env.BUFFER_PROFILE_ID }}"
        },
        {
          "name": "now",
          "value": true
        }
      ]
    }
  },
  "credentials": {
    "httpQueryAuth": "Buffer API"
  }
}
```

#### 8. Save to History
```json
{
  "node": "Save History",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "insert",
    "table": "history",
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "topic": "={{ $json.topic }}",
        "angle": "={{ $json.angle }}",
        "content": "={{ $json.final_content }}",
        "status": "published",
        "buffer_post_id": "={{ $json.buffer_response.id }}"
      }
    }
  }
}
```

---

## Workflow 2: Track Performance

**Schedule:** Daily at 20:00 WIB (13:00 UTC)

### Nodes Configuration

#### 1. Get Published Posts
```json
{
  "node": "Get Published Posts",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT id, buffer_post_id FROM history WHERE status = 'published' AND buffer_post_id IS NOT NULL"
  }
}
```

#### 2. Loop Through Posts (Split in Batches)
```json
{
  "node": "Split in Batches",
  "type": "n8n-nodes-base.splitInBatches",
  "parameters": {
    "batchSize": 1,
    "options": {}
  }
}
```

#### 3. Get Analytics from Buffer
```json
{
  "node": "Get Analytics",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "GET",
    "url": "=https://api.bufferapp.com/1/updates/{{ $json.buffer_post_id }}/analytics.json",
    "authentication": "genericCredentialType",
    "genericAuthType": "httpQueryAuth"
  }
}
```

#### 4. Save Metrics
```json
{
  "node": "Save Metrics",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "insert",
    "table": "metrics",
    "columns": {
      "mappingMode": "defineBelow",
      "value": {
        "history_id": "={{ $json.history_id }}",
        "impressions": "={{ $json.analytics.impressions }}",
        "likes": "={{ $json.analytics.likes }}",
        "replies": "={{ $json.analytics.replies }}",
        "reposts": "={{ $json.analytics.reposts }}",
        "buffer_post_id": "={{ $json.buffer_post_id }}"
      }
    }
  }
}
```

---

## Workflow 3: Backup Knowledge

**Schedule:** Weekly on Sunday at 00:00 WIB (Saturday 17:00 UTC)

### Nodes Configuration

#### 1. Fetch All Knowledge
```json
{
  "node": "Get All Knowledge",
  "type": "n8n-nodes-base.postgres",
  "parameters": {
    "operation": "executeQuery",
    "query": "SELECT * FROM knowledge ORDER BY created_at"
  }
}
```

#### 2. Format as Markdown
```json
{
  "node": "Format Markdown",
  "type": "n8n-nodes-base.code",
  "parameters": {
    "jsCode": "// Format knowledge as markdown\nconst knowledge = $input.all();\nlet markdown = '# Knowledge Base Backup\\n\\n';\nmarkdown += `Generated: ${new Date().toISOString()}\\n\\n---\\n\\n`;\n\nfor (const item of knowledge) {\n  markdown += `## ${item.json.title}\\n\\n`;\n  markdown += `**Category:** ${item.json.category}\\n\\n`;\n  markdown += `**Tags:** ${item.json.tags?.join(', ') || 'none'}\\n\\n`;\n  markdown += `${item.json.content}\\n\\n---\\n\\n`;\n}\n\nreturn [{ json: { markdown } }];"
  }
}
```

#### 3. Commit to GitHub
```json
{
  "node": "GitHub Commit",
  "type": "n8n-nodes-base.httpRequest",
  "parameters": {
    "method": "PUT",
    "url": "https://api.github.com/repos/{{ $env.GITHUB_REPO }}/contents/knowledge_backup.md",
    "authentication": "predefinedCredentialType",
    "nodeCredentialType": "githubApi",
    "bodyParameters": {
      "parameters": [
        {
          "name": "message",
          "value": "=Weekly knowledge backup: {{ $now.toISO() }}"
        },
        {
          "name": "content",
          "value": "={{ Buffer.from($json.markdown).toString('base64') }}"
        },
        {
          "name": "sha",
          "value": "={{ $json.current_sha }}"
        }
      ]
    }
  }
}
```

---

## Error Handling

All workflows should include error handling:

```json
{
  "node": "Error Trigger",
  "type": "n8n-nodes-base.errorTrigger",
  "parameters": {},
  "outputs": ["Error Handler"]
}
```

Error handler can:
- Log to database
- Send notification to Telegram
- Retry failed nodes

---

## Environment Variables Required

```bash
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Gemini API
GEMINI_API_KEY=AIza...

# Buffer API
BUFFER_ACCESS_TOKEN=1/xxxxx...
BUFFER_PROFILE_ID=5fxxxxx...

# GitHub
GITHUB_TOKEN=ghp_xxxxx...
GITHUB_REPO=username/repo-name
```

---

*These are example configurations. Actual implementation may vary based on n8n version and specific requirements.*
