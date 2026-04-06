<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $fillable = [
        'title',
        'description',
        'type',
        'difficulty_level',
        'advisor_id',
        'status',
    ];

    protected $casts = [
        'difficulty_level' => 'integer',
    ];

    public function advisor()
    {
        return $this->belongsTo(User::class, 'advisor_id');
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

    public function successEstimations()
    {
        return $this->hasMany(SuccessEstimation::class);
    }
}
