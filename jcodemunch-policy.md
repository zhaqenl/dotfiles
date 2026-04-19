# jCodemunch Tool Routing Policy

## Read files

Before reading any source code file, call jCodeMunch get_file_outline to see its structure first. To read specific symbols, use get_symbol_source (single symbol_id or batch symbol_ids[]) or get_context_bundle (symbol + its imports) instead of reading the whole file. Use Read for non-code files (.md, .json, .yaml, .toml, .env, .txt, .html, images, PDFs) and when you need complete file content before editing. Never use cat, head, tail, or sed to read any file.

## Search content

To search code by symbol name (function, class, method, variable), use jCodeMunch search_symbols -- narrow with kind=, language=, file_pattern=. To search for strings, comments, TODOs, or patterns in source code, use jCodeMunch search_text (supports regex via is_regex, context_lines for surrounding code). For database columns in dbt/SQLMesh projects, use search_columns. Use Grep only for searching non-code file content (.md, .json, .yaml, .txt, .env, config files). Never invoke grep or rg via Bash.

## Search files

To browse code project structure, use jCodeMunch get_file_tree (filter with path_prefix) or get_repo_outline for a high-level overview of directories, languages, and symbol counts. Use Glob when finding files by name pattern. Never use find or ls via Bash for file discovery.

## Reserve Bash

Reserve Bash exclusively for system commands and terminal operations: builds, tests, git, package managers, docker, kubectl, and similar. Never use Bash for code exploration -- do not run grep, rg, find, cat, head, or tail on source code files through it. Use jCodeMunch MCP tools for all code reading and searching. If unsure whether a dedicated tool exists, default to the dedicated tool.

## Direct search

For directed codebase searches (finding a specific function, class, or method), use jCodeMunch search_symbols directly -- it is faster and more precise than text search. For text pattern searches in code, use jCodeMunch search_text. Use native search tools only when searching non-code file content.

## Delegate exploration

For broader codebase exploration, start with jCodeMunch: get_repo_outline for project overview, get_file_tree to browse structure, suggest_queries when the repo is unfamiliar. For deep research requiring multiple rounds, use subagents -- instruct them to prefer jCodeMunch over native search tools for source code exploration.

## Subagent guidance

Use subagents when the task matches the agent's description. Subagents are valuable for parallelizing independent queries or protecting the main context window from excessive results. When delegating code exploration to subagents, instruct them to use jCodeMunch MCP tools (search_symbols, get_symbol_source, get_file_outline) rather than Read, Grep, or Glob for source code. Avoid duplicating work that subagents are already doing.

## Read first

Do not propose changes to code you haven't understood. Before modifying code, use jCodeMunch to build context: get_file_outline to see the file's structure, get_symbol_source or get_context_bundle to read the relevant symbols, and get_blast_radius or find_references to understand the impact of your changes.

When working with source code, call resolve_repo with the current directory to confirm the project is indexed. If not indexed, call index_folder. When a repo is unfamiliar, call suggest_queries for orientation.

For non-code files (.md, .json, .yaml, .toml, .env, .txt, .html), use Read directly.
