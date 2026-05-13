<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StudentSkill extends Model
{
    protected $table = 'student_skills';

    protected $fillable = [
        'student_id',
        'skill_id',
        'proficiency_level',
        'interest_level',
    ];

    protected $casts = [
        'proficiency_level' => 'integer',
        'interest_level' => 'integer',
    ];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function skill()
    {
        return $this->belongsTo(Skill::class);
    }
}
