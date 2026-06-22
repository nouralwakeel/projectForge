<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\Assistant\ToolRegistry;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Minimal MCP (Model Context Protocol) server over JSON-RPC 2.0 / HTTP.
 *
 * Exposes the same ToolRegistry as the in-app assistant so any external MCP
 * client (e.g. Claude Desktop) can discover and call the tools. Implements the
 * core methods: initialize, tools/list, tools/call, ping. Authentication is
 * handled by the `mcp.auth` middleware (static bearer token), not Sanctum.
 */
class McpController extends Controller
{
    private const PROTOCOL_VERSION = '2025-06-18';

    private const JSONRPC = '2.0';

    public function __construct(private ToolRegistry $registry) {}

    public function handle(Request $request): JsonResponse
    {
        $body = $request->json()->all();

        if (! is_array($body) || empty($body)) {
            return response()->json($this->error(null, -32700, 'Parse error'), 400);
        }

        // JSON-RPC batch (a list of requests) vs a single request object.
        $isBatch = array_is_list($body);
        $messages = $isBatch ? $body : [$body];

        $responses = [];
        foreach ($messages as $message) {
            $response = $this->dispatch(is_array($message) ? $message : []);
            if ($response !== null) {
                $responses[] = $response;
            }
        }

        // Notifications only -> no response body (202 Accepted per MCP spec).
        if (empty($responses)) {
            return response()->json(null, 202);
        }

        return response()->json($isBatch ? $responses : $responses[0]);
    }

    /**
     * Route a single JSON-RPC message. Returns null for notifications (no id).
     *
     * @param  array<string, mixed>  $message
     * @return array<string, mixed>|null
     */
    private function dispatch(array $message): ?array
    {
        $id = $message['id'] ?? null;
        $method = $message['method'] ?? null;
        $params = (array) ($message['params'] ?? []);

        // Notifications carry no id and expect no response.
        $isNotification = ! array_key_exists('id', $message);

        if (! is_string($method) || $method === '') {
            return $isNotification ? null : $this->error($id, -32600, 'Invalid Request');
        }

        if ($isNotification) {
            // e.g. notifications/initialized — acknowledge silently.
            return null;
        }

        return match ($method) {
            'initialize' => $this->result($id, $this->initialize($params)),
            'ping' => $this->result($id, (object) []),
            'tools/list' => $this->result($id, ['tools' => $this->registry->mcpTools()]),
            'tools/call' => $this->toolsCall($id, $params),
            default => $this->error($id, -32601, "Method not found: {$method}"),
        };
    }

    /**
     * @param  array<string, mixed>  $params
     * @return array<string, mixed>
     */
    private function initialize(array $params): array
    {
        $clientProtocol = $params['protocolVersion'] ?? self::PROTOCOL_VERSION;

        return [
            'protocolVersion' => is_string($clientProtocol) ? $clientProtocol : self::PROTOCOL_VERSION,
            'capabilities' => [
                'tools' => (object) [],
            ],
            'serverInfo' => [
                'name' => (string) config('services.mcp.name', 'ProjectForge MCP'),
                'version' => (string) config('services.mcp.version', '1.0.0'),
            ],
        ];
    }

    /**
     * @param  array<string, mixed>  $params
     * @return array<string, mixed>
     */
    private function toolsCall(mixed $id, array $params): array
    {
        $name = $params['name'] ?? null;
        $arguments = (array) ($params['arguments'] ?? []);

        if (! is_string($name) || $name === '') {
            return $this->error($id, -32602, 'Invalid params: tool name is required');
        }

        if (! $this->registry->has($name)) {
            return $this->error($id, -32602, "Unknown tool: {$name}");
        }

        try {
            $result = $this->registry->call($name, $arguments);
        } catch (\Throwable $e) {
            // Tool-level failures are reported via isError, not a protocol error.
            return $this->result($id, [
                'content' => [['type' => 'text', 'text' => 'Tool error: '.$e->getMessage()]],
                'isError' => true,
            ]);
        }

        return $this->result($id, [
            'content' => [[
                'type' => 'text',
                'text' => json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT),
            ]],
            'structuredContent' => $result,
            'isError' => false,
        ]);
    }

    /**
     * @param  array<string, mixed>  $result
     * @return array<string, mixed>
     */
    private function result(mixed $id, array|object $result): array
    {
        return [
            'jsonrpc' => self::JSONRPC,
            'id' => $id,
            'result' => $result,
        ];
    }

    /** @return array<string, mixed> */
    private function error(mixed $id, int $code, string $message): array
    {
        return [
            'jsonrpc' => self::JSONRPC,
            'id' => $id,
            'error' => [
                'code' => $code,
                'message' => $message,
            ],
        ];
    }
}
