<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Team extends Model
{
    protected $fillable = [
        'name',
        'project_id',
        'is_approved',
        'supervisor_status',
    ];

    protected $casts = [
        'is_approved' => 'boolean',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }

    public function members()
    {
        return $this->belongsToMany(Student::class, 'team_members')
            ->withPivot('role_in_team')
            ->withTimestamps();
    }

    public function successEstimations()
    {
        return $this->hasMany(SuccessEstimation::class);
    }
}
