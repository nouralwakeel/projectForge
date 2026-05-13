<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Skill extends Model
{
    protected $fillable = ['name', 'category'];

    public function students()
    {
        return $this->belongsToMany(Student::class, 'student_skills')
            ->withPivot('proficiency_level', 'interest_level')
            ->withTimestamps();
    }

    public function projects()
    {
        return $this->belongsToMany(Project::class, 'project_skills')
            ->withPivot('weight')
            ->withTimestamps();
    }
}
