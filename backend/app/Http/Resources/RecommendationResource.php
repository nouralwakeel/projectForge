<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RecommendationResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'project' => new ProjectResource($this['project']),
            'match_score' => $this['match_score'],
            'match_percentage' => $this['match_percentage'],
        ];
    }
}
