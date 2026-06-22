<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | AI Assistant (Google Gemini)
    |--------------------------------------------------------------------------
    |
    | Credentials and defaults for the in-app AI assistant. The assistant calls
    | the Google Generative Language API (generateContent) with function-calling
    | so the model can query the database through the shared ToolRegistry.
    |
    */
    'gemini' => [
        'key' => env('GEMINI_API_KEY'),
        'model' => env('GEMINI_MODEL', 'gemini-flash-latest'),
        'base_url' => env('GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'),
        'timeout' => (int) env('GEMINI_TIMEOUT', 60),
        'max_tool_turns' => (int) env('GEMINI_MAX_TOOL_TURNS', 5),
    ],

    /*
    |--------------------------------------------------------------------------
    | MCP Server
    |--------------------------------------------------------------------------
    |
    | The MCP endpoint exposes the same ToolRegistry over JSON-RPC 2.0 so any
    | external MCP client (e.g. Claude Desktop) can use the same tools. It is
    | guarded by a static bearer token instead of Sanctum.
    |
    */
    'mcp' => [
        'token' => env('MCP_SERVER_TOKEN'),
        'name' => env('MCP_SERVER_NAME', 'ProjectForge MCP'),
        'version' => env('MCP_SERVER_VERSION', '1.0.0'),
    ],

];
