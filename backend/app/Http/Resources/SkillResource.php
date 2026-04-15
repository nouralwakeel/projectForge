<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SkillResource extends JsonResource
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
            'category' => $this->category,
            'proficiency_level' => $this->whenPivotLoaded('user_skills', fn() => $this->pivot?->proficiency_level),
            'weight' => $this->whenPivotLoaded('project_skills', fn() => $this->pivot?->weight),
        ];
    }
}
