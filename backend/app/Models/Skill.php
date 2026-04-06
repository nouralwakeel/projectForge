<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Skill extends Model
{
    protected $fillable = ['name', 'category'];

    public function users()
    {
        return $this->belongsToMany(User::class, 'user_skills')
            ->withPivot('proficiency_level')
            ->withTimestamps();
    }

    public function projects()
    {
        return $this->belongsToMany(Project::class, 'project_skills')
            ->withPivot('weight')
            ->withTimestamps();
    }
}
