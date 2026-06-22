<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProjectResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'type' => new ProjectTypeResource($this->whenLoaded('type')),
            'type_id' => $this->type_id,
            'difficulty_level' => $this->difficulty_level,
            'academic_year' => $this->academic_year,
            'semester' => $this->semester,
            'status' => $this->status,
            'supervisor' => new UserResource($this->whenLoaded('supervisor')),
            'skills' => SkillResource::collection($this->whenLoaded('skills')),
            'milestones' => MilestoneResource::collection($this->whenLoaded('milestones')),
            'risks' => RiskResource::collection($this->whenLoaded('risks')),
            'teams' => TeamResource::collection($this->whenLoaded('teams')),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }
}
