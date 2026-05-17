<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement('ALTER TABLE team_members DROP FOREIGN KEY team_members_user_id_foreign');
        DB::statement('ALTER TABLE team_members DROP FOREIGN KEY team_members_team_id_foreign');
        DB::statement('ALTER TABLE team_members DROP INDEX team_members_team_id_user_id_unique');
        DB::statement('ALTER TABLE team_members CHANGE user_id student_id BIGINT UNSIGNED NOT NULL');
        DB::statement('ALTER TABLE team_members ADD CONSTRAINT team_members_team_id_foreign FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE');
        DB::statement('ALTER TABLE team_members ADD CONSTRAINT team_members_student_id_foreign FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE');
        DB::statement('ALTER TABLE team_members ADD UNIQUE team_members_team_id_student_id_unique (team_id, student_id)');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE team_members DROP FOREIGN KEY team_members_student_id_foreign');
        DB::statement('ALTER TABLE team_members DROP FOREIGN KEY team_members_team_id_foreign');
        DB::statement('ALTER TABLE team_members DROP INDEX team_members_team_id_student_id_unique');
        DB::statement('ALTER TABLE team_members CHANGE student_id user_id BIGINT UNSIGNED NOT NULL');
        DB::statement('ALTER TABLE team_members ADD CONSTRAINT team_members_team_id_foreign FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE');
        DB::statement('ALTER TABLE team_members ADD CONSTRAINT team_members_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE');
        DB::statement('ALTER TABLE team_members ADD UNIQUE team_members_team_id_user_id_unique (team_id, user_id)');
    }
};
