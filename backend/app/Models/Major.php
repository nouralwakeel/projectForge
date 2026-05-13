<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Major extends Model
{
    protected $fillable = ['name', 'code'];

    public function students()
    {
        return $this->hasMany(Student::class);
    }
}
