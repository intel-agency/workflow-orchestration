---
description: Project instructions for coding agents
scope: repository
role: Workflow Launch Queue Agent
---

<instructions>
  <purpose>
    <summary>
      This project runs an Agno `AgentOS` workflow that:
      1. Reads app requests from Notion.
      2. Generates planning docs.
      3. Creates a GitHub repo from a template and pushes docs.
    </summary>
    <guidance>
      Use this file as the default operating guide for coding agents working in this repo.
    </guidance>
  </purpose>

  <tech_stack>
    <item>Python `3.12` (managed with `uv`)</item>
    <item>Agno / AgentOS</item>
    <item>FastAPI app exposure via AgentOS</item>
    <item>Notion API via `notion-client`</item>
    <item>GitHub API via `PyGithub` and local `git`</item>
    <item>Optional Next.js UI in `agent-ui/`</item>
  </tech_stack>

  <repository_map>
    <entry>
      <path>app/main.py</path>
      <description>Primary AgentOS app entrypoint (`app.main:app`)</description>
    </entry>
    <entry>
      <path>agents.py</path>
      <description>Agent definitions (`notion_agent`, `plan_docs_agent`, `gh_repo_agent`)</description>
    </entry>
    <entry>
      <path>team.py</path>
      <description>Team orchestration (`workflow_team`)</description>
    </entry>
    <entry>
      <path>tools/notion_api_toolkit.py</path>
      <description>Notion search + page content tools</description>
    </entry>
    <entry>
      <path>tools/github_toolkit.py</path>
      <description>GitHub create/clone/push utilities</description>
    </entry>
    <entry>
      <path>db.py</path>
      <description>Postgres connectivity + SQLite fallback</description>
    </entry>
    <entry>
      <path>models.py</path>
      <description>LLM provider/model wiring and disabled-model reasons</description>
    </entry>
    <entry>
      <path>plan_doc_templates/</path>
      <description>Prompt + markdown templates consumed by plan-docs flow</description>
    </entry>
    <entry>
      <path>deploy/compose.yml</path>
      <description>Local container orchestration (postgres, pgvector, workflow, agentui)</description>
    </entry>
    <entry>
      <path>tests/</path>
      <description>Unit/integration-style tests and smoke scripts</description>
    </entry>
  </repository_map>

  <environment_setup>
    <step order="1">
      <title>Create env file</title>
      <instruction>Copy `.env.example` to `.env` and set required values.</instruction>
    </step>
    <step order="2">
      <title>Install deps</title>
      <instruction>`uv sync --dev`</instruction>
    </step>
    <step order="3">
      <title>Important env vars</title>
      <instruction>Required for Notion flow: `WLQ_NOTION_API_KEY`, `WLQ_NOTION_DATABASE_ID`</instruction>
      <instruction>Required for GitHub flow: `GH_AGNO_TOOLS_TOKEN`</instruction>
      <instruction>Common model keys (pick one working provider): `CLOUD_CODE_GEMINI_CODE_ASSIST_API_KEY`, `OPENROUTER_AGNO_API_KEY`, `ZAI_API_KEY`, etc.</instruction>
      <instruction>DB defaults are in `db.py`; Postgres is preferred, SQLite fallback is automatic.</instruction>
      <instruction>Use an async DB URL when pointing to Postgres from app runtime/tests: `DATABASE_URL=postgresql+asyncpg://&lt;user&gt;:&lt;pass&gt;@&lt;host&gt;:&lt;port&gt;/&lt;db&gt;`</instruction>
    </step>
  </environment_setup>

  <runbook>
    <run>
      <name>Local app run</name>
      <command>`uv run python -m app.main`</command>
      <note>Service listens on port `7777` in local mode.</note>
    </run>
    <run>
      <name>Docker compose run</name>
      <command>`docker compose -f deploy/compose.yml up --build`</command>
      <note>Workflow app is exposed at `http://localhost:7777`.</note>
    </run>
    <run>
      <name>Agent UI (optional)</name>
      <command>`cd agent-ui`</command>
      <command>`npm run dev` (or `pnpm dev` / `bun run dev` depending on your local tooling)</command>
      <note>UI default port is `3000`.</note>
    </run>
  </runbook>

  <testing_guidance>
    <guidance>Use `uv` to run Python tooling (plain `pytest` may not be on PATH).</guidance>
    <commands>
      <command>Run all tests: `uv run python -m pytest`</command>
      <command>Run focused tests: `uv run python -m pytest tests/test_notion_api_toolkit.py -q`</command>
      <command>Run focused tests: `uv run python -m pytest tests/test_github_toolkit.py -q`</command>
    </commands>
    <known_state date="2026-02-07">
      <item>`tests/test_notion_api_toolkit.py` has 2 failing assertions expecting `NotionClient(auth=...)` only.</item>
      <item>Implementation now calls `NotionClient(auth=..., notion_version="2025-09-03")`.</item>
      <item>If you touch Notion toolkit init behavior, update those assertions accordingly.</item>
    </known_state>
  </testing_guidance>

  <coding_conventions>
    <rule>Keep changes minimal and targeted to the requested behavior.</rule>
    <rule>Prefer typed Python (`dict[str, Any]`, etc.) and keep function signatures explicit.</rule>
    <rule>Reuse existing patterns in `agents.py`, `team.py`, and toolkit classes.</rule>
    <rule>Avoid broad refactors unless the task explicitly requires them.</rule>
    <rule>Do not hardcode secrets/tokens.</rule>
    <rule>Keep template and prompt file edits in `plan_doc_templates/` backward compatible when possible.</rule>
  </coding_conventions>

  <agent_specific_guardrails>
    <rule>Preserve workflow sequencing:
      1. Notion retrieval
      2. Planning doc generation
      3. GitHub repo creation + commit/push
    </rule>
    <rule>Keep file-path handling explicit in GitHub operations:
      - Save generated docs inside cloned repo path.
      - Use repo-relative paths when committing existing files.
    </rule>
    <rule>Maintain DB fallback behavior in `db.py` unless explicitly asked to change it.</rule>
    <rule>If changing model defaults in `models.py`, keep `MODEL_INIT_ERRORS` and disabled-reason tracking intact.</rule>
  </agent_specific_guardrails>

  <validation_before_handoff>
    <step order="1">Run focused tests for touched modules.</step>
    <step order="2">
      Run at least one smoke check for imports/startup:
      PowerShell:
      `$env:DATABASE_URL='postgresql+asyncpg://postgres:postgres@localhost:5432/workflow'; uv run python -c "import app.main; print('ok')"`
    </step>
    <step order="3">
      Summarize:
      - What changed
      - What was validated
      - Any remaining risk (especially credential-dependent integration paths)
    </step>
  </validation_before_handoff>

  <tool_use_instructions>
    <instruction id="querying_microsoft_documentation">
      <applyTo>**</applyTo>
      <title>Querying Microsoft Documentation</title>
      <tools>
        <tool>microsoft_docs_search</tool>
        <tool>microsoft_docs_fetch</tool>
        <tool>microsoft_code_sample_search</tool>
      </tools>
      <guidance>
        These MCP tools can search and fetch Microsoft's latest official documentation and code samples, which may be newer or more detailed than model training data.
      </guidance>
      <guidance>
        For specific and narrowly defined questions involving native Microsoft technologies (C#, F#, ASP.NET Core, Microsoft.Extensions, NuGet, Entity Framework, and the dotnet runtime), use these tools for research.
        When writing code, prioritize using information retrieved from these tools to ensure accuracy and up-to-date practices, especially for newer features or libraries.
        Before writing any code involving Microsoft technologies, always check for relevant documentation or code samples using these tools to ensure the most current and accurate information is being used.
      </guidance>
    </instruction>

    <instruction id="sequential_thinking_default_usage">
      <applyTo>*</applyTo>
      <title>Sequential Thinking for Complex Problem Solving</title>
      <tools>
        <tool>sequential_thinking</tool>
      </tools>
      <guidance>
        Use sequential thinking for all requests except the most trivial, single-step requests (for example, minimal formatting changes or direct one-line lookups).
      </guidance>
      <guidance>
        The sequential_thinking tool enables structured, step-by-step problem analysis with the ability to revise, branch, and adjust reasoning paths dynamically.
        Use this tool when:
        - Breaking down complex problems into manageable steps
        - Planning and design work that may require revision
        - Analyzing situations where the full scope is unclear initially
        - Conducting analysis that might need course correction
        - Making architectural or design decisions
        - Encountering unexpected issues or errors that require systematic debugging
        - Filtering out irrelevant information while maintaining context
        - Working through tasks that need to maintain context over multiple steps
      </guidance>
      <guidance>
        The tool supports dynamic thinking processes by allowing you to:
        - Revise previous thoughts when new understanding emerges
        - Branch into alternative reasoning paths
        - Adjust the estimated total number of thoughts as complexity becomes apparent
        - Mark when additional thinking steps are needed beyond original estimates
      </guidance>
    </instruction>

    <instruction id="memory_default_usage">
      <applyTo>*</applyTo>
      <title>Knowledge Graph Memory for Context Persistence</title>
      <tools>
        <tool>create_entities</tool>
        <tool>create_relations</tool>
        <tool>add_observations</tool>
        <tool>delete_entities</tool>
        <tool>delete_observations</tool>
        <tool>delete_relations</tool>
        <tool>read_graph</tool>
        <tool>search_nodes</tool>
        <tool>open_nodes</tool>
      </tools>
      <guidance>
        Use memory for all requests except the most trivial, single-step requests, and persist relevant user/project context when it helps future task continuity.
      </guidance>
      <guidance>
        The memory MCP server provides a persistent knowledge graph for storing and retrieving context across conversations.
        Store information about:
        - User preferences, communication styles, and working patterns
        - Project-specific configurations, patterns, and conventions
        - Technical decisions, rationale, and architectural choices
        - Recurring challenges, solutions, and workarounds discovered
        - Team members, their roles, and areas of expertise
        - Tool configurations, CLI paths, authentication mechanisms
        - Build patterns, deployment strategies, and environment setups
      </guidance>
      <guidance>
        Knowledge graph concepts:
        - **Entities**: Primary nodes with a name, type (e.g., "person", "project", "tool"), and observations
        - **Relations**: Directed connections between entities in active voice (e.g., "works_at", "depends_on", "configures")
        - **Observations**: Atomic facts stored as strings attached to entities (one fact per observation)
      </guidance>
      <guidance>
        Tool usage patterns:
        - Use create_entities to establish new concepts, people, projects, or tools
        - Use create_relations to connect related entities and build context
        - Use add_observations to record facts, preferences, or discoveries about entities
        - Use search_nodes to find relevant context based on keywords across names, types, and observations
        - Use open_nodes to retrieve specific entities by name for detailed information
        - Use read_graph to get a complete view of all stored knowledge when planning or reviewing
        - Use delete operations to clean up outdated or incorrect information
      </guidance>
      <guidance>
        At the start of complex tasks, search or read relevant memory to leverage previous learnings.
        After completing significant work, update memory with new patterns, configurations, or insights discovered.
      </guidance>
    </instruction>
  </tool_use_instructions>
</instructions>
