<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProjectTodo extends Model
{
    protected $fillable = [
        'project_id',
        'title',
        'description',
        'is_done',
        'risk_weight',
        'order_sequence',
    ];

    protected $casts = [
        'is_done' => 'boolean',
        'risk_weight' => 'integer',
        'order_sequence' => 'integer',
    ];

    public function project()
    {
        return $this->belongsTo(Project::class);
    }
}
