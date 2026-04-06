<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Risk extends Model
{
    protected $fillable = [
        'project_id',
        'risk_description',
        'impact_level',
        'mitigation_plan',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}
