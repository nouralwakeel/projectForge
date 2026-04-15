<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SuccessEstimationResource extends JsonResource
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
            'success_probability' => round($this->success_probability * 100, 2),
            'calculated_at' => $this->calculated_at?->format('Y-m-d H:i:s'),
            'factors' => json_decode($this->factors_log, true),
            'project' => new ProjectResource($this->whenLoaded('project')),
            'team' => new TeamResource($this->whenLoaded('team')),
            'user' => new UserResource($this->whenLoaded('user')),
        ];
    }
}
