<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MajorSeeder extends Seeder
{
    public function run(): void
    {
        $majors = [
            ['name' => 'هندسة البرمجيات', 'code' => 'SE'],
            ['name' => 'علوم الحاسب', 'code' => 'CS'],
            ['name' => 'نظم المعلومات', 'code' => 'IS'],
            ['name' => 'تقنية المعلومات', 'code' => 'IT'],
            ['name' => 'الذكاء الاصطناعي', 'code' => 'AI'],
            ['name' => 'أمن المعلومات', 'code' => 'CYB'],
            ['name' => 'هندسة الحاسب', 'code' => 'CE'],
            ['name' => 'علوم البيانات', 'code' => 'DS'],
        ];

        foreach ($majors as $major) {
            DB::table('majors')->updateOrInsert(
                ['code' => $major['code']],
                ['name' => $major['name'], 'created_at' => now(), 'updated_at' => now()]
            );
        }
    }
}
