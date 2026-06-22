<?php

namespace App\Services\Assistant;

use App\Services\Assistant\Tools\FindSimilarProjectsTool;
use App\Services\Assistant\Tools\FindStudentTool;
use App\Services\Assistant\Tools\GetProjectDetailsTool;
use App\Services\Assistant\Tools\GetStatisticsTool;
use App\Services\Assistant\Tools\GetStudentWorkTool;
use App\Services\Assistant\Tools\ListProjectsTool;
use App\Services\Assistant\Tools\ListTeamsTool;
use App\Services\Assistant\Tools\SearchArchiveTool;
use App\Services\Assistant\Tools\ToolInterface;
use InvalidArgumentException;

/**
 * Single source of truth for the assistant's tools. The same registry feeds:
 *   - Gemini function-calling  (geminiDeclarations)
 *   - the MCP server           (mcpTools)
 * and dispatches every invocation through call().
 */
class ToolRegistry
{
    /** @var array<string, ToolInterface> */
    private array $tools = [];

    public function __construct()
    {
        $this->register(new ListProjectsTool);
        $this->register(new GetProjectDetailsTool);
        $this->register(new FindSimilarProjectsTool);
        $this->register(new FindStudentTool);
        $this->register(new GetStudentWorkTool);
        $this->register(new ListTeamsTool);
        $this->register(new SearchArchiveTool);
        $this->register(new GetStatisticsTool);
    }

    public function register(ToolInterface $tool): void
    {
        $this->tools[$tool->name()] = $tool;
    }

    public function has(string $name): bool
    {
        return isset($this->tools[$name]);
    }

    /** @return array<string, ToolInterface> */
    public function all(): array
    {
        return $this->tools;
    }

    /**
     * Gemini function declarations: [{name, description, parameters}].
     * Gemini rejects an empty `properties` object, so parameter-less tools omit
     * the parameters key entirely.
     */
    public function geminiDeclarations(): array
    {
        return array_values(array_map(function (ToolInterface $tool) {
            $declaration = [
                'name' => $tool->name(),
                'description' => $tool->description(),
            ];

            $params = $tool->parameters();
            if (! empty($params['properties'])) {
                $declaration['parameters'] = $params;
            }

            return $declaration;
        }, $this->tools));
    }

    /** MCP tools/list shape: [{name, description, inputSchema}]. */
    public function mcpTools(): array
    {
        return array_values(array_map(function (ToolInterface $tool) {
            $schema = $tool->parameters();

            // JSON Schema requires `properties` to be an object; an empty PHP
            // array would encode as [] — cast it so it serializes as {}.
            if (empty($schema['properties'])) {
                $schema['properties'] = (object) [];
            }

            return [
                'name' => $tool->name(),
                'description' => $tool->description(),
                'inputSchema' => $schema,
            ];
        }, $this->tools));
    }

    /**
     * Dispatch a tool call by name.
     *
     * @param  array<string, mixed>  $args
     * @return array<string, mixed>
     */
    public function call(string $name, array $args = []): array
    {
        if (! $this->has($name)) {
            throw new InvalidArgumentException("Unknown tool: {$name}");
        }

        return $this->tools[$name]->handle($args);
    }
}
