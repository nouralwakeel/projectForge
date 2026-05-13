<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TeamMember extends Model
{
    protected $fillable = [
        'team_id',
        'student_id',
        'role_in_team',
    ];

    public function team()
    {
        return $this->belongsTo(Team::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }
}
