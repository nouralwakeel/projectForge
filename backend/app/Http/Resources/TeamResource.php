<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class TeamResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'project_id' => $this->project_id,
            'is_approved' => $this->is_approved,
            'project' => new ProjectResource($this->whenLoaded('project')),
            'members' => TeamMemberResource::collection($this->whenLoaded('members')),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }
}
