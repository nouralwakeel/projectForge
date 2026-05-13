<?php

namespace Database\Seeders;

use App\Models\ProjectType;
use Illuminate\Database\Seeder;

class ProjectTypeSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            ['name' => 'mobile_app'],
            ['name' => 'web_application'],
            ['name' => 'ai_system'],
        ];

        foreach ($types as $type) {
            ProjectType::create($type);
        }

        $this->command->info('ProjectTypeSeeder: Created project types.');
    }
}
