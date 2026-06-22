<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Guards the MCP endpoint with a static bearer token (services.mcp.token) so
 * external MCP clients can authenticate without a Sanctum session. The token is
 * accepted via the `Authorization: Bearer <token>` header or `X-MCP-Token`.
 */
class McpAuthMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $configured = (string) config('services.mcp.token', '');

        if ($configured === '') {
            return response()->json([
                'jsonrpc' => '2.0',
                'id' => null,
                'error' => [
                    'code' => -32000,
                    'message' => 'MCP server token is not configured (set MCP_SERVER_TOKEN).',
                ],
            ], 503);
        }

        $provided = $request->bearerToken() ?: $request->header('X-MCP-Token', '');

        if (! is_string($provided) || ! hash_equals($configured, $provided)) {
            return response()->json([
                'jsonrpc' => '2.0',
                'id' => null,
                'error' => [
                    'code' => -32001,
                    'message' => 'Unauthorized: invalid or missing MCP token.',
                ],
            ], 401);
        }

        return $next($request);
    }
}
