<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_skills', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropUnique(['user_id', 'skill_id']);
            $table->renameColumn('user_id', 'student_id');
        });

        Schema::rename('user_skills', 'student_skills');

        Schema::table('student_skills', function (Blueprint $table) {
            $table->foreign('student_id')->references('id')->on('students')->onDelete('cascade');
            $table->unique(['student_id', 'skill_id']);
        });
    }

    public function down(): void
    {
        Schema::table('student_skills', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->dropUnique(['student_id', 'skill_id']);
            $table->renameColumn('student_id', 'user_id');
        });

        Schema::rename('student_skills', 'user_skills');

        Schema::table('user_skills', function (Blueprint $table) {
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->unique(['user_id', 'skill_id']);
        });
    }
};
