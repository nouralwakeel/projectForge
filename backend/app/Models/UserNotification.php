<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Lightweight in-app notification (separate from Laravel's Notifiable
 * `notifications` table to keep a simple, app-specific JSON shape).
 */
class UserNotification extends Model
{
    protected $fillable = [
        'user_id',
        'type',
        'title',
        'body',
        'data',
        'read_at',
    ];

    protected $casts = [
        'data' => 'array',
        'read_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Create a notification for a user. Null user id is ignored so callers can
     * pass an optional recipient without guarding every call site.
     *
     * @param  array<string, mixed>  $data
     */
    public static function createFor(?int $userId, string $type, string $title, ?string $body = null, array $data = []): ?self
    {
        if (! $userId) {
            return null;
        }

        return self::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'body' => $body,
            'data' => $data ?: null,
        ]);
    }
}
