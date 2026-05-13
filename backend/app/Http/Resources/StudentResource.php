<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class StudentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'stud_num' => $this->stud_num,
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'full_name' => $this->first_name . ' ' . $this->last_name,
            'gender' => $this->gender,
            'date_of_birth' => $this->date_of_birth?->format('Y-m-d'),
            'major' => new MajorResource($this->whenLoaded('major')),
            'skills' => SkillResource::collection($this->whenLoaded('skills')),
            'user' => new UserResource($this->whenLoaded('user')),
            'created_at' => $this->created_at?->format('Y-m-d H:i:s'),
        ];
    }
}
