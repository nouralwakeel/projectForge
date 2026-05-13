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
            'student_id' => $this->student_id,
            'team_id' => $this->team_id,
            'role_in_team' => $this->role_in_team,
            'student' => new StudentResource($this->whenLoaded('student')),
        ];
    }
}
