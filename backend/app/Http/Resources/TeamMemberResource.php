<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeamMemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'role_in_team' => $this->whenPivotLoaded('team_members', fn () => $this->pivot->role_in_team),
            'student' => [
                'id' => $this->id,
                'full_name' => trim(($this->first_name ?? '').' '.($this->last_name ?? '')),
                'user' => new UserResource($this->whenLoaded('user')),
            ],
        ];
    }
}
