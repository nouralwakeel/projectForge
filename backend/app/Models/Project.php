<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = [
        'title',
        'description',
        'type_id',
        'difficulty_level',
        'academic_year',
        'semester',
        'supervisor_id',
        'status',
    ];

    protected $casts = [
        'difficulty_level' => 'integer',
    ];

    public function supervisor()
    {
        return $this->belongsTo(User::class, 'supervisor_id');
    }

    public function type()
    {
        return $this->belongsTo(ProjectType::class, 'type_id');
    }

    public function skills()
    {
        return $this->belongsToMany(Skill::class, 'project_skills')
            ->withPivot('weight')
            ->withTimestamps();
    }

    public function teams()
    {
        return $this->hasMany(Team::class);
    }

    public function milestones()
    {
        return $this->hasMany(Milestone::class)->orderBy('order_sequence');
    }

    public function risks()
    {
        return $this->hasMany(Risk::class);
    }

    public function todos()
    {
        return $this->hasMany(ProjectTodo::class)->orderBy('order_sequence');
    }

    public function successEstimations()
    {
        return $this->hasMany(SuccessEstimation::class);
    }
}
