<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuccessEstimation extends Model
{
    protected $fillable = [
        'team_id',
        'student_id',
        'project_id',
        'success_probability',
        'calculated_at',
        'factors_log',
    ];

    protected $casts = [
        'success_probability' => 'decimal:2',
        'calculated_at' => 'datetime',
        'factors_log' => 'array',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}
