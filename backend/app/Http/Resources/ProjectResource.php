<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProjectResource extends JsonResource
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
            'title' => $this->title,
            'description' => $this->description,
            'type' => $this->type,
            'difficulty_level' => $this->difficulty_level,
            'status' => $this->status,
            'advisor' => new UserResource($this->whenLoaded('advisor')),
            'skills' => SkillResource::collection($this->whenLoaded('skills')),
            'milestones' => MilestoneResource::collection($this->whenLoaded('milestones')),
            'risks' => RiskResource::collection($this->whenLoaded('risks')),
            'teams' => TeamResource::collection($this->whenLoaded('teams')),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }
}
