<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Milestone extends Model
{
    protected $fillable = [
        'project_id',
        'title',
        'description',
        'estimated_days',
        'order_sequence',
    ];

    protected $casts = [
        'estimated_days' => 'integer',
        'order_sequence' => 'integer',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}
