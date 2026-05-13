<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('team_members', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->dropUnique(['team_id', 'user_id']);
            $table->renameColumn('user_id', 'student_id');
            $table->foreign('student_id')->references('id')->on('students')->onDelete('cascade');
            $table->unique(['team_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::table('team_members', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->dropUnique(['team_id', 'student_id']);
            $table->renameColumn('student_id', 'user_id');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->unique(['team_id', 'user_id']);
        });
    }
};
