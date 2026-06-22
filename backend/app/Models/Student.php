<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Student extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'stud_num',
        'first_name',
        'last_name',
        'gender',
        'date_of_birth',
        'major_id',
    ];

    protected $casts = [
        'date_of_birth' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function major()
    {
        return $this->belongsTo(Major::class);
    }

    public function skills()
    {
        return $this->belongsToMany(Skill::class, 'student_skills')
            ->withPivot('proficiency_level', 'interest_level')
            ->withTimestamps();
    }

    public function teams()
    {
        return $this->belongsToMany(Team::class, 'team_members')
            ->withPivot('role_in_team')
            ->withTimestamps();
    }

    public function successEstimations()
    {
        return $this->hasMany(SuccessEstimation::class);
    }
}
