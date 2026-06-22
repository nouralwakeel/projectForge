<?php

namespace App\Services\Assistant\Tools;

/**
 * Contract for a read-only "context tool" that the AI assistant (via Gemini
 * function-calling) and external MCP clients (via JSON-RPC) can both invoke.
 *
 * A single ToolRegistry exposes every implementation in two shapes — Gemini
 * functionDeclarations and MCP tools — and dispatches calls through handle().
 */
interface ToolInterface
{
    /** Machine name used by both Gemini functionDeclarations and MCP tools/call. */
    public function name(): string;

    /** Human/AI-facing description (Arabic) of what the tool does and when to use it. */
    public function description(): string;

    /**
     * JSON Schema (OpenAPI subset) describing the tool's arguments.
     * Must be an object schema: ['type' => 'object', 'properties' => [...], 'required' => [...]].
     */
    public function parameters(): array;

    /**
     * Execute the tool against the database and return a JSON-serializable array.
     *
     * @param  array<string, mixed>  $args
     * @return array<string, mixed>
     */
    public function handle(array $args): array;
}
